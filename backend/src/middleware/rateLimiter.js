const rateLimit = require('express-rate-limit');

/**
 * General API rate limiter — 100 requests per 15 minutes per IP.
 * Applies to all /api routes.
 */
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    message: 'Too many requests from this IP, please try again after 15 minutes.',
  },
});

/**
 * Strict limiter for auth routes (login / register) — 10 attempts per 15 minutes.
 * Prevents brute-force attacks on credentials.
 */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    message: 'Too many login attempts. Please try again after 15 minutes.',
  },
});

/**
 * Quote generation limiter — 20 requests per hour per IP.
 * Protects Gemini API quota from accidental or malicious overuse.
 */
const quoteLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    message: 'Quote generation limit reached. Please try again in an hour.',
  },
});

module.exports = { apiLimiter, authLimiter, quoteLimiter };
