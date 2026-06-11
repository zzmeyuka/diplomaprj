const express = require("express");
const prisma = require("../lib/prisma");
const { authMiddleware } = require("../middleware/authMiddleware");
const { flightInclude } = require("../utils/flightFormatters");
const { upsertRoutePreference } = require("../utils/routePreference");

const router = express.Router();

router.use(authMiddleware);

router.post("/bookings", async (req, res) => {
  try {
    const { flightOfferId, passengersCount, passengers, paymentStatus } = req.body;
    if (!flightOfferId) {
      return res.status(400).json({ error: "flightOfferId is required" });
    }
    const count = Math.max(1, parseInt(passengersCount, 10) || 1);

    const result = await prisma.$transaction(async (tx) => {
      const offer = await tx.flightOffer.findUnique({
        where: { id: flightOfferId },
        include: flightInclude,
      });
      if (!offer) throw Object.assign(new Error("Flight offer not found"), { status: 404 });
      if (offer.status !== "available") {
        throw Object.assign(new Error("Flight not available"), { status: 400 });
      }
      if (offer.seatsLeft < count) {
        throw Object.assign(new Error("Not enough seats"), { status: 400 });
      }

      const finalPrice = Number(offer.finalPrice);
      const totalPrice = finalPrice * count;

      const booking = await tx.booking.create({
        data: {
          userId: req.user.id,
          flightOfferId,
          passengersCount: count,
          totalPrice,
          currency: offer.currency,
          bookingStatus: "confirmed",
        },
      });

      await tx.flightOffer.update({
        where: { id: flightOfferId },
        data: { seatsLeft: { decrement: count } },
      });

      const aggregatorName = offer.aggregator.name;
      const payment = await tx.payment.create({
        data: {
          bookingId: booking.id,
          amount: totalPrice,
          currency: offer.currency,
          paymentStatus: paymentStatus || "paid",
          paymentRedirectProvider:
            aggregatorName === "Kaspi Travel" ? "Kaspi Travel" : aggregatorName,
        },
      });

      if (Array.isArray(passengers) && passengers.length > 0) {
        for (const p of passengers) {
          await tx.passenger.create({
            data: {
              bookingId: booking.id,
              fullName: p.fullName || "Passenger",
              documentId: p.documentId || null,
              birthDate: p.birthDate ? new Date(p.birthDate) : null,
            },
          });
        }
      }

      return { booking, payment, offer, totalPrice };
    });

    await upsertRoutePreference(
      req.user.id,
      result.offer.routeId,
      result.offer.route.originCityId,
      result.offer.route.destinationCityId,
      "bookingCount"
    );

    res.status(201).json({
      booking: result.booking,
      payment: result.payment,
      totalPrice: result.totalPrice,
    });
  } catch (err) {
    const status = err.status || 500;
    res.status(status).json({ error: err.message });
  }
});

router.get("/bookings/my", async (req, res) => {
  try {
    const bookings = await prisma.booking.findMany({
      where: { userId: req.user.id },
      include: {
        flightOffer: { include: flightInclude },
        payments: true,
        passengers: true,
      },
      orderBy: { createdAt: "desc" },
    });
    res.json(
      bookings.map((b) => ({
        id: b.id,
        passengersCount: b.passengersCount,
        totalPrice: Number(b.totalPrice),
        bookingStatus: b.bookingStatus,
        currency: b.currency,
        createdAt: b.createdAt,
        flight: {
          id: b.flightOffer.id,
          flightCode: b.flightOffer.flightCode,
          departureAt: b.flightOffer.departureAt,
          arrivalAt: b.flightOffer.arrivalAt,
          cabinClass: b.flightOffer.cabinClass,
          aggregator: b.flightOffer.aggregator.name,
          origin: b.flightOffer.route.originCity.nameEn,
          destination: b.flightOffer.route.destinationCity.nameEn,
        },
        payments: b.payments,
      }))
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
