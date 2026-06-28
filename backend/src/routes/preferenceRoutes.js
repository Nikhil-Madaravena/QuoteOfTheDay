const express = require('express');
const router = express.Router();
const {
  getPreferences,
  savePreferences,
} = require('../controllers/preferenceController');
const { protect } = require('../middleware/authMiddleware');

router.route('/').get(protect, getPreferences).post(protect, savePreferences);

module.exports = router;
