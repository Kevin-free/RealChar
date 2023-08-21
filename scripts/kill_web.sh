#!/bin/bash

# Find the process ID running on port 3000
pid=$(lsof -t -i :3000)

if [ -z "$pid" ]; then
    echo "No process running on port 3000."
    exit -1
fi

echo "Killing process ${pid} running on port 3000..."
kill "$pid"

echo "Process ${pid} killed."
