#!/bin/bash
# Start backend server

cd `dirname $0`/..
export BASE_DIR=`pwd`
echo $BASE_DIR

# check the nohup.out log output file
if [ ! -f "${BASE_DIR}/log/backend.log" ]; then
  touch "${BASE_DIR}/log/backend.log"
echo "create file  ${BASE_DIR}/log/backend.log"
fi

nohup python cli.py run-uvicorn >> "${BASE_DIR}/log/backend.log" 2>&1 &

echo "backend is starting，you can check the ${BASE_DIR}/log/backend.log"
