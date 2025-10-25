# 🚀 Interval Timer - Simple Startup Scripts

## Local start script

- **start_local.sh**: Runs `npm start` in backend-api and `python main.py` in telegram-bot - fully setup backend for local debug purposes

## Requirements

1. **Node.js** installed (used v20.16.0 during development)
2. **Python** installed (used v3.12.10 during development)
3. **Flutter installed** (used v3.35.6 during development)
4. **Dependencies installed**:
   ```bash
   cd backend-api && npm install
   cd ../telegram-bot && pip install -r requirements.txt
   ```

## Setup

1. Create `.env` files with your tokens
2. Run the start script
3. Done!
