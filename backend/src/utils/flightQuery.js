const prisma = require("../lib/prisma");
const { mapFlightOffer } = require("./flightFormatters");

async function findCityByName(name) {
  if (!name?.trim()) return null;
  const trimmed = name.trim();
  let c = await prisma.city.findFirst({
    where: { nameEn: { equals: trimmed, mode: "insensitive" } },
  });
  if (c) return c;
  return prisma.city.findFirst({
    where: { nameRu: { equals: trimmed, mode: "insensitive" } },
  });
}

async function resolveRoute(from, to) {
  const origin = await findCityByName(from);
  const destination = await findCityByName(to);
  if (!origin || !destination) return null;
  const route = await prisma.route.findFirst({
    where: {
      originCityId: origin.id,
      destinationCityId: destination.id,
      isActive: true,
    },
    include: { originCity: true, destinationCity: true },
  });
  return route ? { route, origin, destination } : null;
}

function parseSearchDate(dateStr) {
  const start = new Date(`${dateStr}T00:00:00.000Z`);
  const end = new Date(`${dateStr}T23:59:59.999Z`);
  return { start, end };
}

async function findMatchingOffers({ from, to, date, cabinClass, passengers }) {
  const resolved = await resolveRoute(from, to);
  if (!resolved) return { error: "Route not found", status: 404 };
  const { route } = resolved;
  const passengersCount = Math.max(1, parseInt(passengers, 10) || 1);
  const { start, end } = parseSearchDate(date);

  const offers = await prisma.flightOffer.findMany({
    where: {
      routeId: route.id,
      cabinClass: cabinClass || "economy",
      status: "available",
      seatsLeft: { gte: passengersCount },
      departureAt: { gte: start, lte: end },
    },
    include: {
      aggregator: true,
      route: { include: { originCity: true, destinationCity: true } },
    },
    orderBy: [{ flightCode: "asc" }, { finalPrice: "asc" }],
  });

  return {
    route,
    passengersCount,
    offers: offers.map((o) => mapFlightOffer(o, passengersCount)),
  };
}

/**
 * Все доступные предложения на маршруте за ближайшие daysAhead дней (для чата без конкретной даты).
 */
async function findOffersOnRoute({
  from,
  to,
  cabinClass,
  passengers,
  daysAhead = 150,
  maxOffers = 120,
}) {
  const resolved = await resolveRoute(from, to);
  if (!resolved) return { error: "Route not found" };
  const { route, origin, destination } = resolved;
  const passengersCount = Math.max(1, parseInt(passengers, 10) || 1);
  const now = new Date();
  const end = new Date(now.getTime() + daysAhead * 24 * 60 * 60 * 1000);

  const offers = await prisma.flightOffer.findMany({
    where: {
      routeId: route.id,
      cabinClass: cabinClass || "economy",
      status: "available",
      seatsLeft: { gte: passengersCount },
      departureAt: { gte: now, lte: end },
    },
    include: {
      aggregator: true,
      route: { include: { originCity: true, destinationCity: true } },
    },
    orderBy: [{ finalPrice: "asc" }, { departureAt: "asc" }],
    take: maxOffers,
  });

  return {
    route,
    passengersCount,
    offers: offers.map((o) => mapFlightOffer(o, passengersCount)),
    originEn: origin.nameEn,
    destEn: destination.nameEn,
  };
}

function groupCheapestOffers(offers) {
  const groups = new Map();
  for (const offer of offers) {
    const key = `${offer.flightCode}|${offer.cabinClass}`;
    const existing = groups.get(key);
    if (!existing || offer.finalPrice < existing.finalPrice) {
      groups.set(key, offer);
    }
  }
  return Array.from(groups.values()).sort((a, b) => {
    if (a.flightCode !== b.flightCode) return a.flightCode.localeCompare(b.flightCode);
    return a.finalPrice - b.finalPrice;
  });
}

module.exports = {
  findCityByName,
  resolveRoute,
  parseSearchDate,
  findMatchingOffers,
  findOffersOnRoute,
  groupCheapestOffers,
};
