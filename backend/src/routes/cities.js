const express = require("express");
const prisma = require("../lib/prisma");

const router = express.Router();

router.get("/cities", async (req, res) => {
  try {
    const cities = await prisma.city.findMany({
      include: { country: true },
      orderBy: { nameEn: "asc" },
    });
    res.json(cities);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
