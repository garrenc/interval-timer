#!/bin/bash

echo "Starting Interval Timer System..."

# Start Backend API
echo "Starting Backend API..."
cd backend-api
npm run dev &
BACKEND_PID=$!
cd ..

# Wait a moment for backend to start
sleep 2

# Start Telegram Bot
echo "Starting Telegram Bot..."
cd telegram-bot
python main.py &
BOT_PID=$!
cd ..


echo "Starting flutter app..."
cd desktop-app
flutter run 
cd ..

echo "System started!"
echo "Backend API PID: $BACKEND_PID"
echo "Telegram Bot PID: $BOT_PID"
echo ""
echo "Press Ctrl+C to stop all processes"

# Wait for interrupt
trap 'echo "Stopping processes..."; kill $BACKEND_PID $BOT_PID 2>/dev/null; exit' INT
wait
