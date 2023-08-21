#!/bin/bash
# Server

cd `dirname $0`/..
export BASE_DIR=`pwd`
echo $BASE_DIR

# check the nohup.out log output file
if [ ! -f "${BASE_DIR}/log/backend.log" ]; then
  touch "${BASE_DIR}/log/backend.log"
echo "create file  ${BASE_DIR}/log/backend.log"
fi

nohup python cli.py run-uvicorn & tail -f "${BASE_DIR}/log/backend.log"

echo "backend is starting，you can check the ${BASE_DIR}/log/backend.log"
