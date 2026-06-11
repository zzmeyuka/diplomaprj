const express = require("express");
const prisma = require("../lib/prisma");
const { authMiddleware } = require("../middleware/authMiddleware");
const { mapFlightOffer, flightInclude } = require("../utils/flightFormatters");

const router = express.Router();

const RELATED_DESTINATIONS = {
  Istanbul: ["Antalya", "Dubai", "Tbilisi", "Moscow"],
  Antalya: ["Istanbul", "Dubai", "Tbilisi"],
  Dubai: ["Istanbul", "Antalya", "Tbilisi", "Bangkok"],
  Beijing: ["Seoul", "Bangkok", "Kuala Lumpur"],
  Seoul: ["Beijing", "Bangkok", "Tokyo"],
  Bangkok: ["Phuket", "Kuala Lumpur", "Dubai"],
  Phuket: ["Bangkok", "Kuala Lumpur"],
  Tbilisi: ["Istanbul", "Antalya", "Dubai", "Moscow"],
  Moscow: ["Istanbul", "Tbilisi", "Bishkek"],
  Bishkek: ["Moscow", "Tbilisi", "Istanbul"],
  "Sharm El Sheikh": ["Antalya", "Dubai"],
  Amsterdam: ["Istanbul", "Dubai", "Moscow"],
  "Kuala Lumpur": ["Bangkok", "Phuket", "Dubai"],
};

router.get("/recommendations", authMiddleware, async (req, res) => {
  try {
    const passengersCount = Math.max(1, parseInt(req.query.passengers, 10) || 1);
    const cabinClass = req.query.cabinClass || "economy";

    const prefs = await prisma.userRoutePreference.findMany({
      where: { userId: req.user.id },
      orderBy: { interestScore: "desc" },
      take: 5,
      include: {
        route: { include: { originCity: true, destinationCity: true } },
      },
    });

    if (prefs.length === 0) {
      const popular = await prisma.flightOffer.findMany({
        where: {
          status: "available",
          cabinClass,
          seatsLeft: { gte: passengersCount },
          discountPercent: { gt: 0 },
        },
        include: flightInclude,
        orderBy: { finalPrice: "asc" },
        take: 10,
      });
      return res.json({
        message: "Popular discounted flights",
        passengersCount,
        recommendations: popular.map((o) => ({
          ...mapFlightOffer(o, passengersCount),
          reason: "Popular discount",
        })),
      });
    }

    const top = prefs[0];
    const originName = top.route.originCity.nameEn;
    const destName = top.route.destinationCity.nameEn;
    const related = RELATED_DESTINATIONS[destName] || ["Antalya", "Dubai", "Tbilisi"];

    const originCity = await prisma.city.findFirst({
      where: { nameEn: originName },
    });

    const destCities = await prisma.city.findMany({
      where: { nameEn: { in: related } },
    });

    const routeIds = [];
    for (const dest of destCities) {
      const r = await prisma.route.findFirst({
        where: {
          originCityId: originCity.id,
          destinationCityId: dest.id,
          isActive: true,
        },
      });
      if (r) routeIds.push(r.id);
    }
    routeIds.push(top.routeId);

    const offers = await prisma.flightOffer.findMany({
      where: {
        routeId: { in: routeIds },
        cabinClass,
        status: "available",
        seatsLeft: { gte: passengersCount },
      },
      include: flightInclude,
      orderBy: [{ discountPercent: "desc" }, { finalPrice: "asc" }],
      take: 20,
    });

    const seen = new Set();
    const recommendations = [];
    for (const o of offers) {
      const key = `${o.routeId}-${o.flightCode}-${o.cabinClass}`;
      if (seen.has(key)) continue;
      seen.add(key);
      const reason =
        o.route.destinationCity.nameEn === destName
          ? `Based on your interest in ${originName} → ${destName}`
          : `Similar from ${originName} to ${o.route.destinationCity.nameEn}`;
      recommendations.push({
        ...mapFlightOffer(o, passengersCount),
        reason,
        interestScore: top.interestScore,
      });
      if (recommendations.length >= 12) break;
    }

    res.json({
      message: "Based on your searches and saved tickets",
      passengersCount,
      cabinClass,
      recommendations,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
