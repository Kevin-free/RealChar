#!/bin/bash
# Start web server

cd `dirname $0`/..
export BASE_DIR=`pwd`
echo $BASE_DIR

# check the nohup.out log output file
if [ ! -f "${BASE_DIR}/log/web.log" ]; then
  touch "${BASE_DIR}/log/web.log"
echo "create file  ${BASE_DIR}/log/web.log"
fi

cd client/web
npm install
npm start >> "${BASE_DIR}/log/web.log" 2>&1 &  # Redirect both stdout and stderr to the log file

echo "web is starting，you can check the ${BASE_DIR}/log/web.log"
