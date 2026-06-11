const prisma = require("../lib/prisma");
const { mapFlightOffer, flightInclude } = require("./flightFormatters");
const { groupCheapestOffers, findOffersOnRoute } = require("./flightQuery");

const CHEAP_ROUTE_SAMPLE = 28;
const RANDOM_ROUTE_SAMPLE = 27;

function shuffleInPlace(arr) {
  for (let i = arr.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function offerButtonLabel(o) {
  const from = o.originCity ?? "";
  const to = o.destinationCity ?? "";
  const route = from && to ? ` (${from}→${to})` : "";
  return `${o.aggregatorName} · ${o.flightCode} · ${Math.round(Number(o.finalPrice))} ${o.currency}${route}`;
}

/**
 * Representative slice of the whole DB: cheapest offer per route on many routes
 * (mix of lowest-price routes + random other routes for geographic coverage).
 */
async function buildGlobalFlightContext(cabinClass, passengers) {
  const passengersCount = Math.max(1, parseInt(passengers, 10) || 1);
  const cabin = cabinClass || "economy";
  const now = new Date();

  const where = {
    status: "available",
    cabinClass: cabin,
    seatsLeft: { gte: passengersCount },
    departureAt: { gte: now },
  };

  const [availableOffersCount, activeRoutesCount, grouped] = await Promise.all([
    prisma.flightOffer.count({ where }),
    prisma.route.count({ where: { isActive: true } }),
    prisma.flightOffer.groupBy({
      by: ["routeId"],
      where,
      _min: { finalPrice: true },
    }),
  ]);

  if (!grouped.length) {
    const empty = {
      scope: "global",
      databaseOverview: {
        availableOffersCount: 0,
        activeRoutesCount,
        sampleRoutesCount: 0,
        cabinClass: cabin,
        passengersAssumed: passengersCount,
      },
      note:
        "В базе нет доступных предложений для выбранного класса и числа пассажиров. Предложи изменить класс или дату в поиске приложения.",
      routes: [],
    };
    return { flightContext: JSON.stringify(empty, null, 2), offers: [] };
  }

  const withPrice = grouped.map((g) => ({
    routeId: g.routeId,
    minPrice: g._min.finalPrice,
  }));
  withPrice.sort((a, b) => Number(a.minPrice) - Number(b.minPrice));

  const cheapPick = withPrice.slice(0, CHEAP_ROUTE_SAMPLE);
  const rest = withPrice.slice(CHEAP_ROUTE_SAMPLE);
  shuffleInPlace(rest);
  const randomPick = rest.slice(0, RANDOM_ROUTE_SAMPLE);
  const selected = [...cheapPick, ...randomPick];

  const txResults = await prisma.$transaction(
    selected.map((s) =>
      prisma.flightOffer.findFirst({
        where: {
          ...where,
          routeId: s.routeId,
          finalPrice: s.minPrice,
        },
        include: flightInclude,
        orderBy: { departureAt: "asc" },
      })
    )
  );

  const offers = txResults.filter(Boolean).map((o) => mapFlightOffer(o, passengersCount));
  offers.sort((a, b) => a.finalPrice - b.finalPrice);

  const payload = {
    scope: "global",
    databaseOverview: {
      availableOffersCount,
      activeRoutesCount,
      sampleRoutesCount: offers.length,
      cabinClass: cabin,
      passengersAssumed: passengersCount,
    },
    note:
      "Это выборка по всей базе SmartFly: на каждом из отобранных направлений показан один из самых дешёвых доступных рейсов (будущие даты). Полный каталог больше — не придумывай цены и рейсы для городов, которых нет в routes. Если направления нет в выборке, честно скажи, что нужен поиск в приложении по конкретной дате.",
    routes: offers,
  };

  const topForButtons = offers.slice(0, 5);
  const offersPayload = topForButtons.map((o) => ({
    id: o.id,
    label: offerButtonLabel(o),
  }));

  return {
    flightContext: JSON.stringify(payload, null, 2),
    offers: offersPayload,
  };
}

function buildRouteScopedBlock(result, from, to, date) {
  if (!result?.offers?.length) return null;
  const cheapest = groupCheapestOffers(result.offers).slice(0, 6);
  return {
    scope: "route",
    from,
    to,
    date,
    allCount: result.offers.length,
    cheapest,
  };
}

const CITY_CACHE_TTL_MS = 5 * 60 * 1000;
let cityMatchCache = null;
let cityMatchCacheAt = 0;

function normalizeText(s) {
  return String(s || "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .replace(/ё/g, "е")
    .trim();
}

async function getCitiesForMatching() {
  if (cityMatchCache && Date.now() - cityMatchCacheAt < CITY_CACHE_TTL_MS) {
    return cityMatchCache;
  }
  const rows = await prisma.city.findMany({
    select: { id: true, nameEn: true, nameRu: true },
  });
  rows.sort(
    (a, b) =>
      Math.max(b.nameEn.length, b.nameRu.length) - Math.max(a.nameEn.length, a.nameRu.length)
  );
  cityMatchCache = rows;
  cityMatchCacheAt = Date.now();
  return rows;
}

function usableNameFragment(name) {
  const n = normalizeText(name);
  if (!n) return "";
  if (/^[a-z]/i.test(n)) return n.length >= 3 ? n : "";
  return n.length >= 2 ? n : "";
}

function firstOccurrenceIndex(normMsg, city) {
  const en = usableNameFragment(city.nameEn);
  const ru = usableNameFragment(city.nameRu);
  let idx = 1e9;
  if (en && normMsg.includes(en)) idx = Math.min(idx, normMsg.indexOf(en));
  if (ru && normMsg.includes(ru)) idx = Math.min(idx, normMsg.indexOf(ru));
  return idx;
}

function findMentionedCities(message, cities) {
  const normMsg = normalizeText(message);
  const seen = new Set();
  const found = [];
  for (const c of cities) {
    const en = usableNameFragment(c.nameEn);
    const ru = usableNameFragment(c.nameRu);
    const hit = (en && normMsg.includes(en)) || (ru && normMsg.includes(ru));
    if (hit && !seen.has(c.id)) {
      seen.add(c.id);
      found.push(c);
    }
  }
  return found;
}

/**
 * Из текста сообщения извлекаются города из БД; для подходящего направления подгружаются реальные офферы.
 */
async function buildUserMentionedRouteContext(message, cabinClass, passengers) {
  const cities = await getCitiesForMatching();
  const found = findMentionedCities(message, cities);
  if (found.length < 2) return null;

  const normMsg = normalizeText(message);
  found.sort((a, b) => firstOccurrenceIndex(normMsg, a) - firstOccurrenceIndex(normMsg, b));

  const take = found.slice(0, 4);
  const orderedPairs = [];
  for (let i = 0; i < take.length; i += 1) {
    for (let j = 0; j < take.length; j += 1) {
      if (i === j) continue;
      const ia = firstOccurrenceIndex(normMsg, take[i]);
      const ib = firstOccurrenceIndex(normMsg, take[j]);
      orderedPairs.push({
        fromEn: take[i].nameEn,
        toEn: take[j].nameEn,
        spread: Math.abs(ia - ib),
      });
    }
  }
  orderedPairs.sort((a, b) => a.spread - b.spread);

  let routeButNoOffers = null;

  for (const pair of orderedPairs) {
    const result = await findOffersOnRoute({
      from: pair.fromEn,
      to: pair.toEn,
      cabinClass,
      passengers,
      daysAhead: 150,
      maxOffers: 150,
    });
    if (result.error) continue;
    if (result.offers.length) {
      const grouped = groupCheapestOffers(result.offers);
      return {
        block: {
          scope: "userMentioned",
          from: result.originEn,
          to: result.destEn,
          dateHorizonDays: 150,
          offersInSample: result.offers.length,
          note:
            "Эти варианты извлечены из вопроса пользователя (названия городов); данные — из базы SmartFly по этому направлению.",
          cheapest: grouped.slice(0, 20),
        },
        offers: grouped.slice(0, 5).map((o) => ({
          id: o.id,
          label: offerButtonLabel(o),
        })),
      };
    }
    routeButNoOffers = { from: result.originEn, to: result.destEn };
  }

  if (routeButNoOffers) {
    return {
      block: {
        scope: "userMentioned",
        from: routeButNoOffers.from,
        to: routeButNoOffers.to,
        offersInSample: 0,
        note:
          "Маршрут между этими городами есть в базе, но нет доступных билетов на ближайшие месяцы для выбранного класса и числа мест.",
        cheapest: [],
      },
      offers: [],
    };
  }

  return null;
}

module.exports = {
  buildGlobalFlightContext,
  buildRouteScopedBlock,
  buildUserMentionedRouteContext,
  offerButtonLabel,
};
