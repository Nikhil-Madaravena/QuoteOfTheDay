const mongoose = require('mongoose');

const preferenceSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  goal: { type: String },
  tone: { type: String },
  favoriteAuthors: [{ type: String }],
  quoteLength: { type: String, enum: ['short', 'medium', 'long', 'any'], default: 'any' },
  topics: [{ type: String }],
  language: { type: String, default: 'en' },
  dailyReminder: { type: Boolean, default: true },
  notificationTime: { type: String, default: '08:00' },
});

module.exports = mongoose.model('Preference', preferenceSchema);
