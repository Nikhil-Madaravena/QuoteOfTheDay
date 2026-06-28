const express = require('express');
const router = express.Router();
const {
  getDailyQuote,
  regenerateQuote,
  getQuoteHistory,
  addFavorite,
  getFavorites,
  removeFavorite,
} = require('../controllers/quoteController');
const { protect } = require('../middleware/authMiddleware');

router.route('/daily').get(protect, getDailyQuote);
router.route('/regenerate').post(protect, regenerateQuote);
router.route('/history').get(protect, getQuoteHistory);
router.route('/favorites').get(protect, getFavorites).post(protect, addFavorite);
router.route('/favorites/:id').delete(protect, removeFavorite);

module.exports = router;
