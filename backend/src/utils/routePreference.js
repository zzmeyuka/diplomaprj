const prisma = require("../lib/prisma");

async function upsertRoutePreference(userId, routeId, originCityId, destinationCityId, field) {
  const existing = await prisma.userRoutePreference.findUnique({
    where: { userId_routeId: { userId, routeId } },
  });
  if (existing) {
    const data = { [field]: { increment: 1 } };
    const updated = await prisma.userRoutePreference.update({
      where: { id: existing.id },
      data,
    });
    const score =
      updated.searchCount * 1 + updated.favoriteCount * 2 + updated.bookingCount * 3;
    return prisma.userRoutePreference.update({
      where: { id: existing.id },
      data: { interestScore: score },
    });
  }
  const counts = { searchCount: 0, favoriteCount: 0, bookingCount: 0 };
  counts[field] = 1;
  const score = counts.searchCount + counts.favoriteCount * 2 + counts.bookingCount * 3;
  return prisma.userRoutePreference.create({
    data: {
      userId,
      routeId,
      originCityId,
      destinationCityId,
      ...counts,
      interestScore: score,
    },
  });
}

module.exports = { upsertRoutePreference };
