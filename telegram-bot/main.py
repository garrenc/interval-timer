# main.py
import asyncio
import aiohttp
from aiogram import Bot, Dispatcher
from aiogram.filters import CommandStart, Command
from aiogram.types import Message
from dotenv import load_dotenv
import os
from datetime import datetime, timedelta

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8080")
USER_ID = os.getenv("USER_ID", "default_user")

if not BOT_TOKEN:
    raise RuntimeError("Missing BOT_TOKEN in .env")

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

def format_time(seconds):
    """Format seconds into MM:SS or HH:MM:SS format"""
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    secs = seconds % 60
    
    if hours > 0:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    else:
        return f"{minutes:02d}:{secs:02d}"

def get_phase_emoji(phase):
    """Get emoji for timer phase"""
    if phase == "work":
        return "🎯"
    elif phase == "shortBreak":
        return "☕"
    elif phase == "longBreak":
        return "🏆"
    return "⏰"

def get_phase_name(phase):
    """Get human readable phase name"""
    if phase == "work":
        return "Work"
    elif phase == "shortBreak":
        return "Short Break"
    elif phase == "longBreak":
        return "Long Break"
    return "Unknown"

@dp.message(CommandStart())
async def start(message: Message):
    await message.answer(
        "👋 <b>Interval Timer Bot</b>\n\n"
        "Available commands:\n"
        "/status - Check current pause status\n"
        "/help - Show this help message",
        parse_mode="HTML"
    )

@dp.message(Command("help"))
async def help_command(message: Message):
    await message.answer(
        "🤖 <b>Interval Timer Bot Help</b>\n\n"
        "<b>Commands:</b>\n"
        "/start - Start the bot\n"
        "/status - Check current pause status\n"
        "/help - Show this help message\n\n"
        "<b>Features:</b>\n"
        "• Get notifications when pauses end\n"
        "• Check remaining time for active pauses\n\n"
        "The bot automatically sends notifications when:\n"
        "• Short breaks finish\n"
        "• Long breaks finish",
        parse_mode="HTML"
    )

@dp.message(Command("status"))
async def status_command(message: Message):
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{API_BASE_URL}/api/pause/status") as response:
                if response.status == 200:
                    data = await response.json()
                    
                    if not data.get("active", False):
                        await message.answer("📭 No active pause found.")
                        return
                    
                    pause_type = data["type"]
                    remaining_seconds = data["remainingSeconds"]
                    remaining_time = format_time(remaining_seconds)
                    
                    phase_emoji = get_phase_emoji(pause_type)
                    phase_name = get_phase_name(pause_type)
                    
                    response_text = (
                        f"{phase_emoji} <b>{phase_name}</b>\n"
                        f"Remaining: {remaining_time}\n"
                        f"Status: Active"
                    )
                    
                    await message.answer(response_text, parse_mode="HTML")
                else:
                    await message.answer("❌ Failed to get pause status. Please try again later.")
    except Exception as e:
        print(f"Error in status command: {e}")
        await message.answer("❌ Error occurred while getting pause status.")


async def main():
    print("Bot started…")
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())