const express = require("express");
const testRoutes = require("./test");
const citiesRoutes = require("./cities");
const authRoutes = require("./auth");
const flightsRoutes = require("./flights");
const favoritesRoutes = require("./favorites");
const bookingsRoutes = require("./bookings");
const recommendationsRoutes = require("./recommendations");
const preferencesRoutes = require("./preferences");
const chatRoutes = require("./chat");
const adminRoutes = require("./admin");

const router = express.Router();

router.use(testRoutes);
router.use(citiesRoutes);
router.use(authRoutes);
router.use(flightsRoutes);
router.use(favoritesRoutes);
router.use(bookingsRoutes);
router.use(recommendationsRoutes);
router.use(preferencesRoutes);
router.use(chatRoutes);
router.use(adminRoutes);

module.exports = router;
