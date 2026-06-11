const express = require("express");
const prisma = require("../lib/prisma");
const { authMiddleware } = require("../middleware/authMiddleware");
const { mapFlightOffer, flightInclude } = require("../utils/flightFormatters");
const { upsertRoutePreference } = require("../utils/routePreference");

const router = express.Router();

router.use(authMiddleware);

router.post("/favorites", async (req, res) => {
  try {
    const { flightOfferId, passengers } = req.body;
    if (!flightOfferId) {
      return res.status(400).json({ error: "flightOfferId is required" });
    }
    const offer = await prisma.flightOffer.findUnique({
      where: { id: flightOfferId },
      include: flightInclude,
    });
    if (!offer) return res.status(404).json({ error: "Flight offer not found" });

    const existing = await prisma.favorite.findUnique({
      where: {
        userId_flightOfferId: { userId: req.user.id, flightOfferId },
      },
    });
    if (existing) {
      return res.status(409).json({ error: "Already in favorites" });
    }

    const favorite = await prisma.favorite.create({
      data: { userId: req.user.id, flightOfferId },
    });

    await upsertRoutePreference(
      req.user.id,
      offer.routeId,
      offer.route.originCityId,
      offer.route.destinationCityId,
      "favoriteCount"
    );

    const passengersCount = parseInt(passengers, 10) || 1;
    res.status(201).json({
      favorite,
      flight: mapFlightOffer(offer, passengersCount),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/favorites", async (req, res) => {
  try {
    const passengers = Math.max(1, parseInt(req.query.passengers, 10) || 1);
    const favorites = await prisma.favorite.findMany({
      where: { userId: req.user.id },
      include: {
        flightOffer: { include: flightInclude },
      },
      orderBy: { createdAt: "desc" },
    });
    res.json(
      favorites.map((f) => ({
        id: f.id,
        flightOfferId: f.flightOfferId,
        createdAt: f.createdAt,
        flight: mapFlightOffer(f.flightOffer, passengers),
      }))
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete("/favorites/:flightOfferId", async (req, res) => {
  try {
    await prisma.favorite.deleteMany({
      where: {
        userId: req.user.id,
        flightOfferId: req.params.flightOfferId,
      },
    });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
