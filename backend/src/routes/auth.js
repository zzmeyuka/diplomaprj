const express = require("express");
const prisma = require("../lib/prisma");
const { hashPassword, comparePassword } = require("../utils/password");
const { signToken } = require("../utils/jwt");
const { authMiddleware } = require("../middleware/authMiddleware");

const router = express.Router();

function userResponse(user, token) {
  return {
    token,
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      preferredLanguage: user.preferredLanguage,
      role: user.role,
    },
  };
}

router.post("/auth/register", async (req, res) => {
  try {
    const { fullName, email, password, phoneNumber, preferredLanguage } = req.body;
    if (!fullName || !email || !password) {
      return res.status(400).json({ error: "fullName, email and password are required" });
    }
    const existing = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
    if (existing) {
      return res.status(409).json({ error: "Email already registered" });
    }
    const passwordHash = await hashPassword(password);
    const user = await prisma.user.create({
      data: {
        fullName,
        email: email.toLowerCase(),
        passwordHash,
        phoneNumber: phoneNumber || null,
        preferredLanguage: preferredLanguage || "ru",
        role: "user",
      },
    });
    const token = signToken({ userId: user.id, role: user.role });
    res.status(201).json(userResponse(user, token));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "email and password are required" });
    }
    const user = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const valid = await comparePassword(password, user.passwordHash);
    if (!valid) {
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const token = signToken({ userId: user.id, role: user.role });
    res.json(userResponse(user, token));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/auth/me", authMiddleware, async (req, res) => {
  const { passwordHash, ...safe } = req.user;
  res.json(safe);
});

module.exports = router;
