#!/bin/bash
# Start web server

cd "$(dirname "$0")/.."
export BASE_DIR=$(pwd)
echo "$BASE_DIR"

# Create the log folder if it doesn't exist
if [ ! -d "${BASE_DIR}/log" ]; then
  mkdir -p "${BASE_DIR}/log"
  echo "Created log folder: ${BASE_DIR}/log"
fi

# Check the nohup.out log output file
if [ ! -f "${BASE_DIR}/log/web.log" ]; then
  touch "${BASE_DIR}/log/web.log"
  echo "Created file ${BASE_DIR}/log/web.log"
fi

cd client/web
npm install
npm start >> "${BASE_DIR}/log/web.log" 2>&1 &

echo "Web server is starting. You can check the ${BASE_DIR}/log/web.log"
