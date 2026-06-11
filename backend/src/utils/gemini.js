const { GoogleGenAI } = require("@google/genai");

const FALLBACK =
  "Gemini API key is not configured yet. The chat message was saved, and after adding GEMINI_API_KEY the assistant will be able to answer using AI.";

async function generateAssistantReply(systemPrompt, userPrompt) {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) {
    return FALLBACK;
  }
  try {
    const ai = new GoogleGenAI({ apiKey });
    const response = await ai.models.generateContent({
      model: process.env.GEMINI_MODEL || "gemini-2.5-flash",
      contents: `${systemPrompt}\n\n${userPrompt}`,
    });
    return response.text || FALLBACK;
  } catch (err) {
    console.error("Gemini error:", err.message);
    return FALLBACK;
  }
}

module.exports = { generateAssistantReply, FALLBACK };
