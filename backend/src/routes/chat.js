const express = require("express");

const prisma = require("../lib/prisma");

const { authMiddleware } = require("../middleware/authMiddleware");

const { generateAssistantReply } = require("../utils/gemini");

const { findMatchingOffers, groupCheapestOffers } = require("../utils/flightQuery");

const {

  buildGlobalFlightContext,

  buildRouteScopedBlock,

  buildUserMentionedRouteContext,

  offerButtonLabel,

} = require("../utils/chatFlightContext");



const router = express.Router();



router.use(authMiddleware);



router.post("/chat/ask", async (req, res) => {

  try {

    const { message, sessionId, from, to, date, cabinClass, passengers } = req.body;

    if (!message?.trim()) {

      return res.status(400).json({ error: "message is required" });

    }



    let session = sessionId

      ? await prisma.chatSession.findFirst({

          where: { id: sessionId, userId: req.user.id },

        })

      : null;



    if (!session) {

      session = await prisma.chatSession.create({

        data: {

          userId: req.user.id,

          title: message.slice(0, 80),

        },

      });

    }



    await prisma.chatMessage.create({

      data: { sessionId: session.id, role: "user", content: message },

    });



    const cabin = cabinClass || "economy";

    const passe = passengers || 1;



    const global = await buildGlobalFlightContext(cabin, passe);

    const merged = {

      globalSample: JSON.parse(global.flightContext),

      routeSpecific: null,

      userMentionedRoute: null,

    };

    let offers = global.offers;



    if (from && to && date) {

      const result = await findMatchingOffers({

        from,

        to,

        date,

        cabinClass: cabin,

        passengers: passe,

      });

      if (!result.error && result.offers?.length) {

        merged.routeSpecific = buildRouteScopedBlock(result, from, to, date);

        const cheapest = groupCheapestOffers(result.offers).slice(0, 5);

        offers = cheapest.map((o) => ({

          id: o.id,

          label: offerButtonLabel(o),

        }));

      }

    }



    const userMentioned = await buildUserMentionedRouteContext(message.trim(), cabin, passe);

    if (userMentioned) {

      merged.userMentionedRoute = userMentioned.block;

      offers = userMentioned.offers;

    }



    const flightContext = JSON.stringify(merged, null, 2);



    const faqs = await prisma.faqArticle.findMany({

      where: { isActive: true },

      take: 15,

      orderBy: { sortOrder: "asc" },

    });

    const faqContext = faqs

      .map((f) => `Q: ${f.questionRu}\nA: ${f.answerRu}`)

      .join("\n\n");



    const systemPrompt = `Ты — ассистент SmartFly, приложения сравнения авиабилетов Казахстана.

Отвечай ТОЛЬКО на русском языке.

Сравнивай агрегаторы: Kaspi Travel, Freedom Travel, Tickets.kz, Trip.

Объясняй классы: economy, comfort, business.

НЕ придумывай билеты, которых нет в данных ниже.

Используй только предоставленные рейсы и FAQ.



Структура данных:

- globalSample — репрезентативная выборка по всей базе (много направлений; см. databaseOverview и routes).
- userMentionedRoute — если присутствует: направление и рейсы извлечены из ТЕКСТА вопроса пользователя (города из базы), это ПОЛНЫЕ данные по этому маршруту за ближайшие месяцы; отвечай и рекомендуй в первую очередь по полю cheapest.
- routeSpecific — опционально: точные варианты на конкретную дату из формы поиска в приложении.

Если есть userMentionedRoute — используй его как основной источник по направлению из вопроса. Иначе опирайся на globalSample; при наличии routeSpecific учитывай дату из формы.

Если в вопросе названы города, но блока userMentionedRoute нет, значит пару городов не удалось сопоставить с маршрутом в базе — не выдумывай рейсы.

Если город или направление отсутствуют в данных, не выдумывай цену — предложи поиск в приложении.



Если рекомендуешь конкретный рейс из cheapest или из routes, называй тот же flightCode и aggregatorName — под ответом появятся кнопки «Забронировать».



FAQ:

${faqContext}



Данные рейсов (JSON):

${flightContext}`;



    const userPrompt = `Вопрос пользователя: ${message}`;

    const answer = await generateAssistantReply(systemPrompt, userPrompt);



    await prisma.chatMessage.create({

      data: { sessionId: session.id, role: "assistant", content: answer },

    });



    res.json({ sessionId: session.id, answer, offers });

  } catch (err) {

    res.status(500).json({ error: err.message });

  }

});



router.get("/chat/sessions", async (req, res) => {

  try {

    const sessions = await prisma.chatSession.findMany({

      where: { userId: req.user.id },

      orderBy: { updatedAt: "desc" },

      take: 50,

      include: {

        messages: { orderBy: { createdAt: "desc" }, take: 1 },

      },

    });

    res.json(

      sessions.map((s) => ({

        id: s.id,

        title: s.title,

        updatedAt: s.updatedAt,

        lastMessage: s.messages[0]?.content?.slice(0, 120) ?? "",

      }))

    );

  } catch (err) {

    res.status(500).json({ error: err.message });

  }

});



router.get("/chat/history/:sessionId", async (req, res) => {

  try {

    const session = await prisma.chatSession.findFirst({

      where: { id: req.params.sessionId, userId: req.user.id },

      include: { messages: { orderBy: { createdAt: "asc" } } },

    });

    if (!session) return res.status(404).json({ error: "Session not found" });

    res.json(session);

  } catch (err) {

    res.status(500).json({ error: err.message });

  }

});



module.exports = router;

