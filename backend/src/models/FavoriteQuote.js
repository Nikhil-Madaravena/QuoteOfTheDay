const mongoose = require('mongoose');

const favoriteQuoteSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  quoteText: { type: String, required: true },
  author: { type: String },
  topic: { type: String },
  addedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('FavoriteQuote', favoriteQuoteSchema);
