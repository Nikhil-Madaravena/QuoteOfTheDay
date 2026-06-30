const { generateQuote } = require('../services/geminiService');
const Preference = require('../models/Preference');
const DailyQuote = require('../models/DailyQuote');
const FavoriteQuote = require('../models/FavoriteQuote');
const QuotePool = require('../models/QuotePool');
const Streak = require('../models/Streak');

const getOrCreateStreak = async (userId) => {
  let streak = await Streak.findOne({ user: userId });
  if (!streak) {
    streak = await Streak.create({
      user: userId,
      currentStreak: 0,
      longestStreak: 0,
    });
  }
  return streak;
};

const updateStreak = async (userId) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  let streak = await Streak.findOne({ user: userId });
  if (!streak) {
    streak = await Streak.create({
      user: userId,
      currentStreak: 1,
      longestStreak: 1,
      lastActiveDate: today,
    });
    return streak;
  }

  if (!streak.lastActiveDate) {
    streak.currentStreak = 1;
    streak.longestStreak = Math.max(streak.longestStreak, 1);
    streak.lastActiveDate = today;
    await streak.save();
    return streak;
  }

  const lastActive = new Date(streak.lastActiveDate);
  lastActive.setHours(0, 0, 0, 0);

  const diffTime = Math.abs(today - lastActive);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 0) {
    return streak;
  } else if (diffDays === 1) {
    streak.currentStreak += 1;
    streak.longestStreak = Math.max(streak.longestStreak, streak.currentStreak);
  } else {
    streak.currentStreak = 1;
  }

  streak.lastActiveDate = today;
  await streak.save();
  return streak;
};


// @desc    Get daily quote
// @route   GET /api/quotes/daily
// @access  Private
const getDailyQuote = async (req, res) => {
  try {
    const userId = req.user._id;

    // 1. Caching: Check if we already have a quote for today for this user
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let existingQuote = await DailyQuote.findOne({
      user: userId,
      date: { $gte: today },
    });

    if (existingQuote) {
      const streakRecord = await getOrCreateStreak(userId);
      return res.json({
        id: existingQuote._id,
        quote: existingQuote.quoteText,
        category: existingQuote.topic,
        explanation: existingQuote.explanation || 'Retrieved from cache.',
        hasRegenerated: existingQuote.hasRegenerated,
        isCached: true,
        streak: streakRecord.currentStreak,
      });
    }

    // 2. Get user preferences
    const preferences = await Preference.findOne({ user: userId }) || {};
    const preferredTopics = preferences.topics || [];

    // 3. Search for an available quote in the QuotePool
    let poolQuote;
    if (preferredTopics.length > 0) {
      poolQuote = await QuotePool.findOne({
        topic: { $in: preferredTopics }, // Match any preferred topic
        usedBy: { $ne: userId }          // User has not seen it
      });
    } else {
      poolQuote = await QuotePool.findOne({
        usedBy: { $ne: userId }
      });
    }

    let generatedData;

    if (poolQuote) {
      // Use the pooled quote
      generatedData = {
        quote: poolQuote.quoteText,
        category: poolQuote.topic,
        explanation: poolQuote.explanation,
      };
      
      // Mark as used by this user
      poolQuote.usedBy.push(userId);
      await poolQuote.save();
    } else {
      // 4. Generate new quote via Gemini API
      generatedData = await generateQuote(preferences);
      
      // Save newly generated quote to the pool for others to use
      try {
        await QuotePool.create({
          quoteText: generatedData.quote,
          topic: generatedData.category || (preferredTopics[0] || 'General'),
          explanation: generatedData.explanation || '',
          usedBy: [userId],
        });
      } catch (err) {
        console.error('Failed to add quote to pool:', err.message);
      }
    }

    // 5. Save to database (DailyQuote)
    const newQuote = await DailyQuote.create({
      user: userId,
      quoteText: generatedData.quote,
      topic: generatedData.category || 'General',
      explanation: generatedData.explanation || '',
      date: new Date(),
    });

    const streakRecord = await updateStreak(userId);

    res.status(201).json({
      id: newQuote._id,
      ...generatedData,
      hasRegenerated: false,
      isCached: false,
      streak: streakRecord.currentStreak,
    });

  } catch (error) {
    console.error('Error generating quote:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Regenerate daily quote (once per day)
// @route   POST /api/quotes/regenerate
// @access  Private
const regenerateQuote = async (req, res) => {
  try {
    const userId = req.user._id;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let existingQuote = await DailyQuote.findOne({
      user: userId,
      date: { $gte: today },
    });

    if (!existingQuote) {
      return res.status(400).json({ message: 'No quote generated today yet. Get a daily quote first.' });
    }

    if (existingQuote.hasRegenerated) {
      return res.status(403).json({ message: 'You have already regenerated your quote for today.' });
    }

    const preferences = await Preference.findOne({ user: userId }) || {};
    const preferredTopics = preferences.topics || [];

    let poolQuote;
    if (preferredTopics.length > 0) {
      poolQuote = await QuotePool.findOne({
        topic: { $in: preferredTopics }, 
        usedBy: { $ne: userId }          
      });
    } else {
      poolQuote = await QuotePool.findOne({
        usedBy: { $ne: userId }
      });
    }

    let generatedData;

    if (poolQuote) {
      generatedData = {
        quote: poolQuote.quoteText,
        category: poolQuote.topic,
        explanation: poolQuote.explanation,
      };
      poolQuote.usedBy.push(userId);
      await poolQuote.save();
    } else {
      generatedData = await generateQuote(preferences);
      
      try {
        await QuotePool.create({
          quoteText: generatedData.quote,
          topic: generatedData.category || (preferredTopics[0] || 'General'),
          explanation: generatedData.explanation || '',
          usedBy: [userId],
        });
      } catch (err) {}
    }

    // Update the existing quote for today
    existingQuote.quoteText = generatedData.quote;
    existingQuote.topic = generatedData.category || 'General';
    existingQuote.explanation = generatedData.explanation || '';
    existingQuote.hasRegenerated = true;
    
    await existingQuote.save();

    const streakRecord = await getOrCreateStreak(userId);

    res.json({
      id: existingQuote._id,
      ...generatedData,
      hasRegenerated: true,
      isCached: false,
      streak: streakRecord.currentStreak,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user's quote history
// @route   GET /api/quotes/history
// @access  Private
const getQuoteHistory = async (req, res) => {
  try {
    const history = await DailyQuote.find({ user: req.user._id }).sort({ date: -1 });
    res.json(history);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Add a quote to favorites
// @route   POST /api/quotes/favorites
// @access  Private
const addFavorite = async (req, res) => {
  try {
    const { quoteText, author, topic } = req.body;

    const exists = await FavoriteQuote.findOne({ user: req.user._id, quoteText });
    if (exists) {
      return res.status(400).json({ message: 'Quote is already in favorites' });
    }

    const favorite = await FavoriteQuote.create({
      user: req.user._id,
      quoteText,
      author,
      topic,
    });
    res.status(201).json(favorite);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get favorite quotes
// @route   GET /api/quotes/favorites
// @access  Private
const getFavorites = async (req, res) => {
  try {
    const favorites = await FavoriteQuote.find({ user: req.user._id }).sort({ addedAt: -1 });
    res.json(favorites);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Remove a quote from favorites
// @route   DELETE /api/quotes/favorites/:id
// @access  Private
const removeFavorite = async (req, res) => {
  try {
    const favorite = await FavoriteQuote.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!favorite) {
      return res.status(404).json({ message: 'Favorite not found' });
    }

    res.json({ message: 'Quote removed from favorites' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user's current streak
// @route   GET /api/quotes/streak
// @access  Private
const getStreak = async (req, res) => {
  try {
    const streak = await Streak.findOne({ user: req.user._id });
    res.json({
      currentStreak: streak ? streak.currentStreak : 0,
      longestStreak: streak ? streak.longestStreak : 0,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getDailyQuote,
  regenerateQuote,
  getQuoteHistory,
  addFavorite,
  getFavorites,
  removeFavorite,
  getStreak,
};
