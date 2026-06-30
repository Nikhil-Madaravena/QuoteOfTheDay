const express = require('express');
const router = express.Router();
const {
  getDailyQuote,
  regenerateQuote,
  getQuoteHistory,
  addFavorite,
  getFavorites,
  removeFavorite,
  getStreak,
} = require('../controllers/quoteController');
const { protect } = require('../middleware/authMiddleware');
const { quoteLimiter } = require('../middleware/rateLimiter');

router.route('/daily').get(protect, quoteLimiter, getDailyQuote);
router.route('/regenerate').post(protect, quoteLimiter, regenerateQuote);
router.route('/history').get(protect, getQuoteHistory);
router.route('/favorites').get(protect, getFavorites).post(protect, addFavorite);
router.route('/favorites/:id').delete(protect, removeFavorite);
router.route('/streak').get(protect, getStreak);

module.exports = router;
