const mongoose = require('mongoose');

const QuotePoolSchema = new mongoose.Schema({
  quoteText: {
    type: String,
    required: true,
    unique: true,
  },
  author: {
    type: String,
    default: 'Unknown',
  },
  topic: {
    type: String,
    required: true,
    index: true,
  },
  explanation: {
    type: String,
    default: '',
  },
  usedBy: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    index: true,
  }],
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('QuotePool', QuotePoolSchema);
