const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const {
  FLIGHT_TIMES,
  CABIN_CLASSES,
  START_DATE,
  END_DATE,
  AGGREGATORS,
  DOMESTIC_CITIES,
  INTERNATIONAL_CITIES,
  buildAllRoutePairs,
  priceRangeForRoute,
  randomBetween,
  cabinMultiplier,
  eachDate,
} = require("./seed-data");

const prisma = new PrismaClient();
const BATCH_SIZE = 5000;

const COUNTRIES = [
  { nameEn: "Kazakhstan", nameRu: "Казахстан", code: "KZ" },
  { nameEn: "Turkey", nameRu: "Турция", code: "TR" },
  { nameEn: "United Arab Emirates", nameRu: "ОАЭ", code: "AE" },
  { nameEn: "China", nameRu: "Китай", code: "CN" },
  { nameEn: "South Korea", nameRu: "Южная Корея", code: "KR" },
  { nameEn: "Thailand", nameRu: "Таиланд", code: "TH" },
  { nameEn: "Georgia", nameRu: "Грузия", code: "GE" },
  { nameEn: "Malaysia", nameRu: "Малайзия", code: "MY" },
  { nameEn: "Russia", nameRu: "Россия", code: "RU" },
  { nameEn: "Kyrgyzstan", nameRu: "Кыргызстан", code: "KG" },
  { nameEn: "Egypt", nameRu: "Египет", code: "EG" },
  { nameEn: "Netherlands", nameRu: "Нидерланды", code: "NL" },
];

const CITY_COUNTRY = {
  Almaty: "KZ", Astana: "KZ", Shymkent: "KZ", Aktau: "KZ", Atyrau: "KZ",
  Aktobe: "KZ", Karaganda: "KZ", Pavlodar: "KZ", Semey: "KZ", Oskemen: "KZ",
  Kostanay: "KZ", Kyzylorda: "KZ", Turkestan: "KZ", Uralsk: "KZ", Taraz: "KZ",
  Taldykorgan: "KZ", Baikonur: "KZ",
  Istanbul: "TR", Antalya: "TR", Dubai: "AE", Beijing: "CN", Seoul: "KR",
  Bangkok: "TH", Phuket: "TH", Tbilisi: "GE", "Kuala Lumpur": "MY", Moscow: "RU",
  Bishkek: "KG", "Sharm El Sheikh": "EG", Amsterdam: "NL",
};

const CITY_RU = {
  Almaty: "Алматы", Astana: "Астана", Shymkent: "Шымкент", Aktau: "Актау",
  Atyrau: "Атырау", Aktobe: "Актобе", Karaganda: "Караганда", Pavlodar: "Павлодар",
  Semey: "Семей", Oskemen: "Усть-Каменогорск", Kostanay: "Костанай",
  Kyzylorda: "Кызылорда", Turkestan: "Туркестан", Uralsk: "Уральск", Taraz: "Тараз",
  Taldykorgan: "Талдыкорган", Baikonur: "Байконур",
  Istanbul: "Стамбул", Antalya: "Анталья", Dubai: "Дубай", Beijing: "Пекин",
  Seoul: "Сеул", Bangkok: "Бангкок", Phuket: "Пхукет", Tbilisi: "Тбилиси",
  "Kuala Lumpur": "Куала-Лумпур", Moscow: "Москва", Bishkek: "Бишкек",
  "Sharm El Sheikh": "Шарм-эль-Шейх", Amsterdam: "Амстердам",
};

const FAQ = [
  {
    questionRu: "Что такое SmartFly?",
    answerRu: "SmartFly сравнивает цены на авиабилеты от Kaspi Travel, Freedom Travel, Tickets.kz и Trip.",
    category: "general",
    sortOrder: 1,
  },
  {
    questionRu: "Чем отличаются классы обслуживания?",
    answerRu: "Economy — самый доступный. Comfort — больше комфорта. Business — максимальный сервис и цена.",
    category: "classes",
    sortOrder: 2,
  },
  {
    questionRu: "Как считается цена для нескольких пассажиров?",
    answerRu: "Итоговая цена = цена за одного пассажира × количество пассажиров.",
    category: "pricing",
    sortOrder: 3,
  },
  {
    questionRu: "Что означает baggageIncluded?",
    answerRu: "Если true — багаж включён в стоимость билета.",
    category: "baggage",
    sortOrder: 4,
  },
  {
    questionRu: "Как найти самый дешёвый билет?",
    answerRu: "Используйте поиск или спросите AI-ассистента. Endpoint /api/flights/cheapest показывает лучшую цену по каждому рейсу.",
    category: "search",
    sortOrder: 5,
  },
];

function parseTimeOnDate(date, timeStr) {
  const [h, m] = timeStr.split(":").map(Number);
  const d = new Date(date);
  d.setUTCHours(h, m, 0, 0);
  return d;
}

function estimateDuration(origin, dest) {
  const intl = INTERNATIONAL_CITIES.includes(dest) || INTERNATIONAL_CITIES.includes(origin);
  if (intl) return randomBetween(180, 480);
  return randomBetween(55, 150);
}

async function main() {
  console.log("SmartFly seed started...");

  const existingOffers = await prisma.flightOffer.count();
  if (existingOffers > 100000) {
    console.log(`Skipping flight generation — ${existingOffers} offers already exist.`);
    return;
  }

  if (existingOffers > 0) {
    console.log("Clearing existing flight offers for re-seed...");
    await prisma.flightOffer.deleteMany();
  }

  await prisma.favorite.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.recommendation.deleteMany();
  await prisma.searchHistory.deleteMany();
  await prisma.userRoutePreference.deleteMany();

  for (const c of COUNTRIES) {
    await prisma.country.upsert({
      where: { code: c.code },
      update: {},
      create: c,
    });
  }
  console.log("countries created");

  const countries = await prisma.country.findMany();
  const countryByCode = Object.fromEntries(countries.map((c) => [c.code, c.id]));

  const allCityNames = [...DOMESTIC_CITIES, ...INTERNATIONAL_CITIES];
  for (const nameEn of allCityNames) {
    const code = CITY_COUNTRY[nameEn];
    const countryId = countryByCode[code];
    const cityType = DOMESTIC_CITIES.includes(nameEn) ? "domestic" : "international";
    const existing = await prisma.city.findFirst({ where: { nameEn } });
    if (!existing) {
      await prisma.city.create({
        data: {
          countryId,
          nameEn,
          nameRu: CITY_RU[nameEn] || nameEn,
          cityType,
        },
      });
    }
  }
  console.log("cities created");

  const cities = await prisma.city.findMany();
  const cityId = Object.fromEntries(cities.map((c) => [c.nameEn, c.id]));

  for (const agg of AGGREGATORS) {
    await prisma.aggregator.upsert({
      where: { name: agg.name },
      update: { isActive: true },
      create: {
        name: agg.name,
        website: `https://${agg.name.toLowerCase().replace(/\s/g, "")}.kz`,
        description: `${agg.name} travel aggregator`,
        isActive: true,
      },
    });
  }
  console.log("aggregators created");

  const aggregators = await prisma.aggregator.findMany();
  const aggByName = Object.fromEntries(aggregators.map((a) => [a.name, a]));

  const { domestic, international } = buildAllRoutePairs();
  const allPairs = [...domestic, ...international];
  const routeRecords = [];

  for (const [origin, dest] of allPairs) {
    if (!cityId[origin] || !cityId[dest]) continue;
    const routeType = INTERNATIONAL_CITIES.includes(dest) ? "international" : "domestic";
    const existing = await prisma.route.findUnique({
      where: {
        originCityId_destinationCityId: {
          originCityId: cityId[origin],
          destinationCityId: cityId[dest],
        },
      },
    });
    if (!existing) {
      const r = await prisma.route.create({
        data: {
          originCityId: cityId[origin],
          destinationCityId: cityId[dest],
          routeType,
          isActive: true,
        },
      });
      routeRecords.push({ route: r, origin, dest });
    } else {
      routeRecords.push({ route: existing, origin, dest });
    }
  }
  console.log(`routes created: ${routeRecords.length}`);

  const dates = eachDate(START_DATE, END_DATE);
  let totalOffers = 0;
  let batch = [];

  for (const { route, origin, dest } of routeRecords) {
    const [minP, maxP] = priceRangeForRoute(origin, dest);
    const baseEconomy = randomBetween(minP, maxP);
    const duration = estimateDuration(origin, dest);

    let flightIdx = 0;
    for (const date of dates) {
      for (let t = 0; t < FLIGHT_TIMES.length; t++) {
        const time = FLIGHT_TIMES[t];
        const departureAt = parseTimeOnDate(date, time);
        const arrivalAt = new Date(departureAt.getTime() + duration * 60000);
        const flightCode = `SF${route.id}${String(flightIdx).padStart(3, "0")}`;
        flightIdx++;

        for (const agg of AGGREGATORS) {
          const aggregatorId = aggByName[agg.name].id;
          const aggMult = agg.multiplier * (0.99 + Math.random() * 0.02);

          for (const cabin of CABIN_CLASSES) {
            const cm = cabinMultiplier(cabin);
            const basePrice = Math.round(baseEconomy * cm * aggMult);
            const discountPercent = Math.random() < 0.15 ? randomBetween(5, 20) : 0;
            const finalPrice = Math.round(basePrice * (100 - discountPercent) / 100);

            batch.push({
              routeId: route.id,
              aggregatorId,
              flightCode,
              departureAt,
              arrivalAt,
              durationMinutes: duration,
              cabinClass: cabin,
              basePrice,
              discountPercent,
              finalPrice,
              currency: "KZT",
              seatsLeft: randomBetween(3, 45),
              baggageIncluded: cabin !== "economy" || Math.random() > 0.4,
              refundable: cabin === "business" || Math.random() > 0.6,
              transferType: Math.random() > 0.75 ? "direct" : "1 stop",
              status: "available",
            });

            if (batch.length >= BATCH_SIZE) {
              await prisma.flightOffer.createMany({ data: batch, skipDuplicates: true });
              totalOffers += batch.length;
              batch = [];
              if (totalOffers % 50000 === 0) {
                console.log(`flight offers created: ${totalOffers}`);
              }
            }
          }
        }
      }
    }
  }

  if (batch.length > 0) {
    await prisma.flightOffer.createMany({ data: batch, skipDuplicates: true });
    totalOffers += batch.length;
  }
  console.log(`flight offers created: ${totalOffers}`);

  for (const faq of FAQ) {
    const exists = await prisma.faqArticle.findFirst({
      where: { questionRu: faq.questionRu },
    });
    if (!exists) await prisma.faqArticle.create({ data: faq });
  }
  console.log("FAQ created");

  const adminHash = await bcrypt.hash("admin123", 10);
  await prisma.user.upsert({
    where: { email: "admin@smartfly.kz" },
    update: { role: "admin" },
    create: {
      fullName: "SmartFly Admin",
      email: "admin@smartfly.kz",
      passwordHash: adminHash,
      phoneNumber: "+77001112233",
      preferredLanguage: "ru",
      role: "admin",
    },
  });
  console.log("Admin user: admin@smartfly.kz / admin123");

  const demoHash = await bcrypt.hash("123456", 10);
  await prisma.user.upsert({
    where: { email: "user@gmail.com" },
    update: {},
    create: {
      fullName: "Demo User",
      email: "user@gmail.com",
      passwordHash: demoHash,
      phoneNumber: "+77000000000",
      preferredLanguage: "ru",
      role: "user",
    },
  });
  console.log("Demo user: user@gmail.com / 123456");

  console.log("SmartFly seed completed.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
