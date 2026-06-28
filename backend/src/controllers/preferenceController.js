const Preference = require('../models/Preference');

// @desc    Get user preferences
// @route   GET /api/preferences
// @access  Private
const getPreferences = async (req, res) => {
  try {
    const preferences = await Preference.findOne({ user: req.user._id });

    if (!preferences) {
      return res.status(404).json({ message: 'Preferences not found' });
    }

    res.json(preferences);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create or update preferences
// @route   POST /api/preferences
// @access  Private
const savePreferences = async (req, res) => {
  const {
    goal,
    tone,
    favoriteAuthors,
    quoteLength,
    topics,
    language,
    notificationTime,
    dailyReminder,
  } = req.body;

  // Simple validation
  if (!topics || !Array.isArray(topics) || topics.length < 1) {
    return res.status(400).json({ message: 'Please provide at least one topic' });
  }

  try {
    let preferences = await Preference.findOne({ user: req.user._id });

    if (preferences) {
      // Update
      preferences.goal = goal || preferences.goal;
      preferences.tone = tone || preferences.tone;
      preferences.favoriteAuthors = favoriteAuthors || preferences.favoriteAuthors;
      preferences.quoteLength = quoteLength || preferences.quoteLength;
      preferences.topics = topics || preferences.topics;
      preferences.language = language || preferences.language;
      preferences.notificationTime = notificationTime || preferences.notificationTime;
      if (dailyReminder !== undefined) {
        preferences.dailyReminder = dailyReminder;
      }

      const updatedPreferences = await preferences.save();
      res.json(updatedPreferences);
    } else {
      // Create
      preferences = await Preference.create({
        user: req.user._id,
        goal,
        tone,
        favoriteAuthors,
        quoteLength,
        topics,
        language,
        notificationTime,
        dailyReminder,
      });

      res.status(201).json(preferences);
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getPreferences,
  savePreferences,
};
