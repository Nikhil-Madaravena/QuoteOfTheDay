const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Model fallback chain: verified available models ordered by free-tier quota
const MODEL_CHAIN = [
  'gemini-2.0-flash-lite',  // Highest free quota
  'gemini-2.5-flash-lite',  // Fallback
  'gemini-2.0-flash',       // Final paid/quota attempt
];

const buildPrompt = (preferences) => `
You are an award-winning creative copywriter and a witty, unconventional life coach. 
Your goal is to write ONE extraordinarily unique, creative, and memorable quote that someone would want to write on a sticky note, tweet, or print on a card.

Goal: ${preferences.goal || 'General life advice'}
Tone: ${preferences.tone || 'Fun and uplifting'}
Topics: ${preferences.topics && preferences.topics.length > 0 ? preferences.topics.join(', ') : 'Everyday life'}
Preferred Length: ${preferences.quoteLength || 'short'}
Language: ${preferences.language || 'en'}

Core Directives for Award-Winning Copy:
1. NO CLICHES: Do not use common platitudes, fortune-cookie phrasing, or generic motivational setups ("Believe in yourself", "Every storm passes", etc.).
2. METAPHORICAL & CONCRETE: Use surprising, vivid daily life metaphors (e.g., comparing productivity to a bad Wi-Fi connection, self-care to software updates, or confidence to a jacket that only fits when you stop trying to adjust it).
3. WITTY & UNCONVENTIONAL: Add a pinch of healthy skepticism, playful self-deprecation, or a sudden perspective twist that makes the reader smile or think "Huh, that's incredibly true."
4. HIGH IMPACT: Keep it punchy, rhythmic, and masterfully crafted. Every word must earn its place.
5. NO AUTHOR: Do NOT include an author name — the quote must stand completely on its own.

Return ONLY a valid JSON object in the following format, with NO markdown, NO backticks, NO extra text:
{
  "quote": "The quote text here",
  "category": "The main topic (e.g. Motivation, Friendship, Humor, Growth, Self-care)",
  "explanation": "A short, sharp, witty one-sentence application tip"
}
`.trim();

const tryModel = async (modelName, preferences) => {
  const model = genAI.getGenerativeModel({ model: modelName });
  const result = await model.generateContent(buildPrompt(preferences));
  const response = await result.response;
  let text = response.text();

  // Strip potential markdown code fences
  text = text.replace(/```json/gi, '').replace(/```/g, '').trim();

  const parsed = JSON.parse(text);

  if (!parsed.quote || !parsed.category) {
    throw new Error('Invalid response structure from Gemini');
  }

  return parsed;
};

const generateQuote = async (preferences, modelIndex = 0, retries = 2) => {
  if (modelIndex >= MODEL_CHAIN.length) {
    // All models exhausted — return a static fallback quote so the app doesn't crash
    console.warn('All Gemini models exhausted quota. Using static fallback quote.');
    return {
      quote: 'Done is better than perfect. Start messy, improve as you go.',
      category: preferences.topics?.[0] || 'Motivation',
      explanation:
        'Stop waiting for the perfect moment — just begin. Progress beats waiting every single time.',
      isFallback: true,
    };
  }

  const modelName = MODEL_CHAIN[modelIndex];

  try {
    console.log(`Attempting generation with model: ${modelName}`);
    const result = await tryModel(modelName, preferences);
    console.log(`Successfully generated quote using ${modelName}`);
    return result;
  } catch (error) {
    const isQuotaError =
      error.message?.includes('429') ||
      error.message?.includes('quota') ||
      error.message?.includes('RESOURCE_EXHAUSTED');

    if (isQuotaError) {
      console.warn(`Model ${modelName} quota exceeded, trying next model...`);
      return await generateQuote(preferences, modelIndex + 1, retries);
    }

    if (retries > 0) {
      console.log(`Generation failed (${error.message}), retrying in 2s... (${retries} retries left)`);
      await new Promise((resolve) => setTimeout(resolve, 2000));
      return await generateQuote(preferences, modelIndex, retries - 1);
    }

    // Exhausted retries on this model — try the next one
    console.warn(`Model ${modelName} failed after retries, trying next model...`);
    return await generateQuote(preferences, modelIndex + 1, retries);
  }
};

module.exports = { generateQuote };
