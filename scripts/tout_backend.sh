#!/bin/bash
#View log of backend server

cd `dirname $0`/..
export BASE_DIR=`pwd`
echo $BASE_DIR

# check the nohup.out log output file
if [ ! -f "${BASE_DIR}/log/backend.log" ]; then
   echo "No file  ${BASE_DIR}/log/backend.log"
   exit -1;
fi

tail -f "${BASE_DIR}/log/backend.log"
