#!/bin/bash
# Start backend server

cd "$(dirname "$0")/.."
export BASE_DIR="$(pwd)"
echo "$BASE_DIR"

# Create the log folder if it doesn't exist
LOG_DIR="${BASE_DIR}/log"
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
  echo "Created directory: $LOG_DIR"
fi

# Check if the nohup.out log output file exists
LOG_FILE="${LOG_DIR}/backend.log"
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
  echo "Created file: $LOG_FILE"
fi

# Start the backend server in the background
nohup python cli.py run-uvicorn >> "$LOG_FILE" 2>&1 &

echo "Backend is starting, you can check the $LOG_FILE"
