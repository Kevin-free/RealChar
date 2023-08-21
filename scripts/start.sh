#!/bin/bash
# Server

cd `dirname $0`/..
export BASE_DIR=`pwd`
echo $BASE_DIR

# check the nohup.out log output file
if [ ! -f "${BASE_DIR}/log/server.log" ]; then
  touch "${BASE_DIR}/log/server.log"
echo "create file  ${BASE_DIR}/log/server.log"
fi

nohup python cli.py run-uvicorn & tail -f "${BASE_DIR}/log/server.log"

echo "BackendServer is starting，you can check the ${BASE_DIR}/log/server.log"
