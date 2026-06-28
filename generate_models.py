import os

models = {
    'Preference': '''const mongoose = require('mongoose');

const preferenceSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  topics: [{ type: String }],
  dailyReminder: { type: Boolean, default: true },
  reminderTime: { type: String, default: '08:00' },
});

module.exports = mongoose.model('Preference', preferenceSchema);
''',
    'DailyQuote': '''const mongoose = require('mongoose');

const dailyQuoteSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  quoteText: { type: String, required: true },
  author: { type: String },
  topic: { type: String },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('DailyQuote', dailyQuoteSchema);
''',
    'FavoriteQuote': '''const mongoose = require('mongoose');

const favoriteQuoteSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  quoteText: { type: String, required: true },
  author: { type: String },
  topic: { type: String },
  addedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('FavoriteQuote', favoriteQuoteSchema);
''',
    'Notification': '''const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  body: { type: String, required: true },
  read: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Notification', notificationSchema);
''',
    'Streak': '''const mongoose = require('mongoose');

const streakSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  currentStreak: { type: Number, default: 0 },
  longestStreak: { type: Number, default: 0 },
  lastActiveDate: { type: Date },
});

module.exports = mongoose.model('Streak', streakSchema);
'''
}

for name, content in models.items():
    with open(f'backend/src/models/{name}.js', 'w') as f:
        f.write(content)
