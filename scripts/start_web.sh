#!/bin/bash

cd `dirname $0`/..
export BASE_DIR=`pwd`
echo $BASE_DIR

# check the nohup.out log output file
if [ ! -f "${BASE_DIR}/log/web.log" ]; then
  touch "${BASE_DIR}/log/web.log"
echo "create file  ${BASE_DIR}/log/web.log"
fi

python cli.py web-build
cd client/web
npm install
npm start
tail -f "${BASE_DIR}/log/web.log"

echo "web is starting，you can check the ${BASE_DIR}/log/web.log"
