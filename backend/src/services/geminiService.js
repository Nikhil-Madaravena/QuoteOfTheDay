const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Model fallback chain: verified available models ordered by free-tier quota
const MODEL_CHAIN = [
  'gemini-2.0-flash-lite',  // Highest free quota
  'gemini-2.5-flash-lite',  // Fallback
  'gemini-2.0-flash',       // Final paid/quota attempt
];

const buildPrompt = (preferences) => `
You are an expert quote generator.
Generate ONE completely original inspirational quote based on the following preferences:
Goal: ${preferences.goal || 'General inspiration'}
Tone: ${preferences.tone || 'Uplifting'}
Topics: ${preferences.topics && preferences.topics.length > 0 ? preferences.topics.join(', ') : 'Life'}
Preferred Length: ${preferences.quoteLength || 'medium'}
Language: ${preferences.language || 'en'}

Return ONLY a valid JSON object in the following format, with NO markdown, NO backticks, NO extra text:
{
  "quote": "The quote text here",
  "author": "Author name (can be 'Unknown' or a relevant philosopher/thinker)",
  "category": "The main topic",
  "explanation": "A short 1-2 sentence explanation of why this quote is relevant"
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

  if (!parsed.quote || !parsed.author || !parsed.category) {
    throw new Error('Invalid response structure from Gemini');
  }

  return parsed;
};

const generateQuote = async (preferences, modelIndex = 0, retries = 2) => {
  if (modelIndex >= MODEL_CHAIN.length) {
    // All models exhausted — return a static fallback quote so the app doesn't crash
    console.warn('All Gemini models exhausted quota. Using static fallback quote.');
    return {
      quote: 'Every day is a new beginning. Take a deep breath and start again.',
      author: 'Unknown',
      category: preferences.topics?.[0] || 'Inspiration',
      explanation:
        'A gentle reminder that each day offers a fresh opportunity to grow and improve.',
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
