const express = require("express");
const prisma = require("../lib/prisma");
const { optionalAuth } = require("../middleware/authMiddleware");
const { mapFlightOffer, flightInclude } = require("../utils/flightFormatters");
const { findMatchingOffers, groupCheapestOffers } = require("../utils/flightQuery");
const { upsertRoutePreference } = require("../utils/routePreference");

const router = express.Router();

function validateSearchQuery(q) {
  const { from, to, date, cabinClass, passengers } = q;
  if (!from || !to || !date) {
    return { error: "from, to and date are required" };
  }
  const validCabins = ["economy", "comfort", "business"];
  if (cabinClass && !validCabins.includes(cabinClass)) {
    return { error: "Invalid cabinClass" };
  }
  return { from, to, date, cabinClass: cabinClass || "economy", passengers: passengers || 1 };
}

async function recordSearchHistory(user, route, params) {
  if (!user) return;
  await prisma.searchHistory.create({
    data: {
      userId: user.id,
      routeId: route.id,
      originCity: params.from,
      destinationCity: params.to,
      searchDate: new Date(`${params.date}T12:00:00.000Z`),
      cabinClass: params.cabinClass,
      passengers: parseInt(params.passengers, 10) || 1,
    },
  });
  await upsertRoutePreference(
    user.id,
    route.id,
    route.originCityId,
    route.destinationCityId,
    "searchCount"
  );
}

router.get("/flights/search", optionalAuth, async (req, res) => {
  try {
    const params = validateSearchQuery(req.query);
    if (params.error) return res.status(400).json({ error: params.error });

    const result = await findMatchingOffers(params);
    if (result.error) return res.status(result.status).json({ error: result.error });

    if (req.user) {
      await recordSearchHistory(req.user, result.route, params);
    }

    res.json({
      from: params.from,
      to: params.to,
      date: params.date,
      cabinClass: params.cabinClass,
      passengersCount: result.passengersCount,
      count: result.offers.length,
      offers: result.offers,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/flights/cheapest", optionalAuth, async (req, res) => {
  try {
    const params = validateSearchQuery(req.query);
    if (params.error) return res.status(400).json({ error: params.error });

    const result = await findMatchingOffers(params);
    if (result.error) return res.status(result.status).json({ error: result.error });

    if (req.user) {
      await recordSearchHistory(req.user, result.route, params);
    }

    const cheapest = groupCheapestOffers(result.offers);
    res.json({
      from: params.from,
      to: params.to,
      date: params.date,
      cabinClass: params.cabinClass,
      passengersCount: result.passengersCount,
      count: cheapest.length,
      offers: cheapest,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/flights/:id", async (req, res) => {
  try {
    const passengers = Math.max(1, parseInt(req.query.passengers, 10) || 1);
    const offer = await prisma.flightOffer.findUnique({
      where: { id: req.params.id },
      include: flightInclude,
    });
    if (!offer) return res.status(404).json({ error: "Flight offer not found" });
    res.json(mapFlightOffer(offer, passengers));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
