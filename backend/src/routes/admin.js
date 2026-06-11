const express = require("express");
const prisma = require("../lib/prisma");
const { authMiddleware } = require("../middleware/authMiddleware");
const adminMiddleware = require("../middleware/adminMiddleware");

const router = express.Router();

router.use(authMiddleware, adminMiddleware);

router.get("/admin/stats", async (req, res) => {
  try {
    const [
      users,
      flights,
      bookings,
      favorites,
      searchHistory,
      chatMessages,
      adminLogs,
    ] = await Promise.all([
      prisma.user.count(),
      prisma.flightOffer.count(),
      prisma.booking.count(),
      prisma.favorite.count(),
      prisma.searchHistory.count(),
      prisma.chatMessage.count(),
      prisma.adminLog.count(),
    ]);
    res.json({
      users,
      flights,
      bookings,
      favorites,
      searchHistory,
      chatMessages,
      adminLogs,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/admin/users", async (req, res) => {
  const users = await prisma.user.findMany({
    select: {
      id: true,
      fullName: true,
      email: true,
      role: true,
      phoneNumber: true,
      createdAt: true,
    },
    orderBy: { createdAt: "desc" },
    take: 100,
  });
  res.json(users);
});

router.get("/admin/flights", async (req, res) => {
  const flights = await prisma.flightOffer.findMany({
    include: { aggregator: true, route: { include: { originCity: true, destinationCity: true } } },
    orderBy: { createdAt: "desc" },
    take: 50,
  });
  res.json(flights);
});

router.patch("/admin/flights/:id/status", async (req, res) => {
  try {
    const { status } = req.body;
    if (!status) return res.status(400).json({ error: "status is required" });
    const flight = await prisma.flightOffer.update({
      where: { id: req.params.id },
      data: { status },
    });
    await prisma.adminLog.create({
      data: {
        adminId: req.user.id,
        action: "UPDATE_FLIGHT_STATUS",
        entity: "FlightOffer",
        entityId: flight.id,
        details: JSON.stringify({ status }),
      },
    });
    res.json(flight);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/admin/bookings", async (req, res) => {
  const bookings = await prisma.booking.findMany({
    include: { user: { select: { email: true, fullName: true } } },
    orderBy: { createdAt: "desc" },
    take: 100,
  });
  res.json(bookings);
});

router.get("/admin/search-history", async (req, res) => {
  const history = await prisma.searchHistory.findMany({
    orderBy: { createdAt: "desc" },
    take: 100,
  });
  res.json(history);
});

router.get("/admin/chat-messages", async (req, res) => {
  const messages = await prisma.chatMessage.findMany({
    orderBy: { createdAt: "desc" },
    take: 100,
  });
  res.json(messages);
});

router.get("/admin/logs", async (req, res) => {
  const logs = await prisma.adminLog.findMany({
    include: { admin: { select: { email: true, fullName: true } } },
    orderBy: { createdAt: "desc" },
    take: 100,
  });
  res.json(logs);
});

module.exports = router;
