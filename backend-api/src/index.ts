import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import axios from "axios";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Simple pause tracking
interface PauseTimer {
  endTime: Date;
  type: "shortBreak" | "longBreak";
  cycle: number;
  pauseNumber: number;
}

let currentPause: PauseTimer | null = null;

// Telegram bot configuration
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const TELEGRAM_CHAT_ID = process.env.TELEGRAM_CHAT_ID;

async function sendTelegramMessage(message: string) {
  if (!TELEGRAM_BOT_TOKEN || !TELEGRAM_CHAT_ID) {
    console.log("Telegram not configured, skipping notification:", message);
    return;
  }

  try {
    await axios.post(
      `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`,
      {
        chat_id: TELEGRAM_CHAT_ID,
        text: message,
        parse_mode: "HTML",
      }
    );
  } catch (error) {
    console.error("Failed to send Telegram message:", error);
  }
}

function getPauseMessage(pauseType: "shortBreak" | "longBreak"): string {
  return `${
    pauseType === "shortBreak" ? "☕ Short Break" : "🌳 Long Break"
  }<b>is finished!</b>\nTime to get back to work!`;
}

app.get("/", (_req, res) => {
  res.json({ ok: true, message: "API running" });
});

app.get("/api/health", (_req, res) => {
  res.json({ ok: true, uptime: process.uptime() });
});

// get a pause from desktop app and save it to variable - it will be used to check if the pause is completed on telegram side
app.post("/api/pause/start", (req, res) => {
  const { type, minutes, cycle, pauseNumber } = req.body;

  const endTime = new Date(Date.now() + minutes * 60 * 1000);
  currentPause = { endTime, type, cycle, pauseNumber };

  res.json({
    success: true,
    message: `${type} pause started for ${minutes} minutes`,
    endTime: endTime.toISOString(),
  });
});

// Start work session
app.post("/api/work/start", (req, res) => {
  sendTelegramMessage(
    `
    🎯 <b>Work session started!</b>
    ________________________________
    `
  );

  res.json({
    success: true,
    message: "Work session started",
  });
});

app.post("/api/work/end", (req, res) => {
  currentPause = null;

  res.json({
    success: true,
    message: "Work session ended",
  });
});

// End current pause timer
app.post("/api/pause/end", (req, res) => {
  const pauseType = req.body.pauseType as "shortBreak" | "longBreak";
  const message = getPauseMessage(pauseType);
  currentPause = null;
  sendTelegramMessage(message);

  res.json({
    success: true,
    message: "Pause cancelled",
  });
});

// Get current pause status
app.get("/api/pause/status", (_req, res) => {
  if (!currentPause) {
    return res.json({
      success: true,
      active: false,
      message: "No active pause",
    });
  }

  const now = new Date();
  const remainingMs = currentPause.endTime.getTime() - now.getTime();
  const remainingSeconds = Math.max(0, Math.floor(remainingMs / 1000));

  res.json({
    success: true,
    active: true,
    type: currentPause.type,
    remainingSeconds,
    endTime: currentPause.endTime.toISOString(),
  });
});

const PORT = Number(process.env.PORT || 8080);
app.listen(PORT, () => {
  console.log(`Backend API running on port ${PORT}`);
});
