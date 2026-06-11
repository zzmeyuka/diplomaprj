const express = require("express");
const prisma = require("../lib/prisma");

const router = express.Router();

router.get("/test-db", async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    const counts = {
      users: await prisma.user.count(),
      cities: await prisma.city.count(),
      routes: await prisma.route.count(),
      flightOffers: await prisma.flightOffer.count(),
    };
    res.json({ ok: true, message: "Database connected", counts });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});

module.exports = router;
