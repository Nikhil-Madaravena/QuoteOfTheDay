import os

files = {
    'backend/src/services/geminiService.js': '''const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || 'dummy_key');

const generateQuote = async (preferences, retries = 3) => {
  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    
    const prompt = `
      You are an expert quote generator.
      Generate ONE completely original inspirational quote based on the following preferences:
      Goal: ${preferences.goal || 'General inspiration'}
      Tone: ${preferences.tone || 'Uplifting'}
      Topics: ${preferences.topics && preferences.topics.length > 0 ? preferences.topics.join(', ') : 'Life'}
      Preferred Length: ${preferences.quoteLength || 'medium'}
      Language: ${preferences.language || 'en'}
      
      Return ONLY a valid JSON object in the following format, with no markdown formatting or backticks:
      {
        "quote": "The quote text here",
        "author": "Author name",
        "category": "The main topic",
        "explanation": "A short explanation"
      }
    `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    let text = response.text();
    
    // Clean up potential markdown formatting
    text = text.replace(/```json/g, '').replace(/```/g, '').trim();

    return JSON.parse(text);
  } catch (error) {
    if (retries > 0) {
      console.log(`Generation failed, retrying... (${retries} retries left)`);
      return await generateQuote(preferences, retries - 1);
    }
    throw new Error('Failed to generate quote from Gemini API');
  }
};

module.exports = { generateQuote };
''',
    'backend/src/controllers/quoteController.js': '''const { generateQuote } = require('../services/geminiService');
const Preference = require('../models/Preference');
const DailyQuote = require('../models/DailyQuote');

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
      return res.json({
        quote: existingQuote.quoteText,
        author: existingQuote.author,
        category: existingQuote.topic,
        explanation: 'Retrieved from cache.',
        isCached: true,
      });
    }

    // 2. Get user preferences
    const preferences = await Preference.findOne({ user: userId }) || {};

    // 3. Generate new quote via Gemini API
    const generatedData = await generateQuote(preferences);

    // 4. Save to database (Cache the response)
    const newQuote = await DailyQuote.create({
      user: userId,
      quoteText: generatedData.quote,
      author: generatedData.author || 'Unknown',
      topic: generatedData.category || 'General',
      date: new Date(),
    });

    res.status(201).json({
      ...generatedData,
      isCached: false,
    });

  } catch (error) {
    console.error('Error generating quote:', error);
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getDailyQuote };
''',
    'backend/src/routes/quoteRoutes.js': '''const express = require('express');
const router = express.Router();
const { getDailyQuote } = require('../controllers/quoteController');
const { protect } = require('../middleware/authMiddleware');

router.route('/daily').get(protect, getDailyQuote);

module.exports = router;
'''
}

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
