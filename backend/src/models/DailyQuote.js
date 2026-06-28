const mongoose = require('mongoose');

const dailyQuoteSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  quoteText: { type: String, required: true },
  author: { type: String },
  topic: { type: String },
  explanation: { type: String },
  date: { type: Date, default: Date.now },
  hasRegenerated: { type: Boolean, default: false },
});

module.exports = mongoose.model('DailyQuote', dailyQuoteSchema);
