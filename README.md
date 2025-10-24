# 🚀 Interval Timer - Simple Startup Scripts

Just run the fucking commands! No bullshit.

## Quick Start

### Linux/Mac:

```bash
./start.sh
```

### Windows:

```cmd
start.bat
```

### Stop everything:

```bash
# Linux/Mac
./stop.sh

# Windows
stop.bat
```

## What it does

- **start.sh/start.bat**: Runs `npm start` in backend-api and `python main.py` in telegram-bot
- **stop.sh/stop.bat**: Kills all node and python processes

## Requirements

1. **Node.js** installed
2. **Python** installed
3. **Dependencies installed**:
   ```bash
   cd backend-api && npm install
   cd ../telegram-bot && pip install -r requirements.txt
   ```

## Setup

1. Create `.env` files with your tokens
2. Run the start script
3. Done!

That's it. No more complicated bullshit.
