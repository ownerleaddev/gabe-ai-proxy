import express from "express";
import fetch from "node-fetch";

const app = express();
app.use(express.json({ limit: "2mb" }));

const OPENAI_KEY = process.env.OPENAI_KEY || "";
const GEMINI_KEY = process.env.GEMINI_KEY || "";

// Health check
app.get("/health", (req, res) => {
  res.json({ ok: true, service: "gabe-ai-proxy" });
});

// Ping check
app.get("/ping", (req, res) => {
  res.json({
    ok: true,
    openai_key_set: !!OPENAI_KEY,
    gemini_key_set: !!GEMINI_KEY
  });
});

// Chat endpoint
app.post("/chat", async (req, res) => {
  const { provider, model, messages } = req.body;

  try {
    if (provider === "openai") {
      const response = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${OPENAI_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model,
          messages,
          temperature: 0.7
        }),
      });

      const data = await response.json();
      return res.json({ ok: true, text: data.choices[0].message.content });
    }

    if (provider === "gemini") {
      const prompt = messages.map(m => m.content).join("\n");

      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_KEY}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }]
          }),
        }
      );

      const data = await response.json();
      const text = data?.candidates?.[0]?.content?.parts?.[0]?.text || "No response";
      return res.json({ ok: true, text });
    }

    res.json({ ok: false, error: "Invalid provider" });
  } catch (err) {
    res.json({ ok: false, error: err.message });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log("Proxy running on port", port));
