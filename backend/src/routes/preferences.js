const express = require("express");
const prisma = require("../lib/prisma");
const { authMiddleware } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/preferences/personalized-routes", authMiddleware, async (req, res) => {
  try {
    const limit = Math.min(20, Math.max(1, parseInt(req.query.limit, 10) || 8));
    const prefs = await prisma.userRoutePreference.findMany({
      where: { userId: req.user.id },
      orderBy: { interestScore: "desc" },
      take: limit,
      include: {
        route: { include: { originCity: true, destinationCity: true } },
      },
    });

    if (prefs.length === 0) {
      return res.json({ routes: [] });
    }

    const routeIds = prefs.map((p) => p.routeId);
    const now = new Date();

    const minPrices = await prisma.flightOffer.groupBy({
      by: ["routeId"],
      where: {
        routeId: { in: routeIds },
        status: "available",
        cabinClass: "economy",
        seatsLeft: { gte: 1 },
        departureAt: { gte: now },
      },
      _min: { finalPrice: true },
    });

    const priceByRoute = new Map(
      minPrices.map((m) => [m.routeId, m._min.finalPrice != null ? Number(m._min.finalPrice) : null])
    );

    const routes = prefs.map((p) => ({
      originCity: p.route.originCity.nameEn,
      destinationCity: p.route.destinationCity.nameEn,
      interestScore: p.interestScore,
      searchCount: p.searchCount,
      favoriteCount: p.favoriteCount,
      bookingCount: p.bookingCount,
      minPrice: priceByRoute.get(p.routeId) ?? null,
      currency: "KZT",
    }));

    res.json({ routes });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
