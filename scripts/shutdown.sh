#!/bin/bash

cd `dirname $0`/..
export BASE_DIR=`pwd`
pid=`ps ax | grep -i cli.py | grep "${BASE_DIR}" | grep python | grep -v grep | awk '{print $1}'`
if [ -z "$pid" ] ; then
        echo "No BackendServer running."
        exit -1;
fi

echo "The BackendServer(${pid}) is running..."

kill ${pid}

echo "Send shutdown request to BackendServer(${pid}) OK"
