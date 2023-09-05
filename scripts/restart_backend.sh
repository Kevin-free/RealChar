#!/bin/bash
# Restart backend server

cd `dirname $0`/..
export BASE_DIR=`pwd`
echo "BASE_DIR=${BASE_DIR}"

# Call shutdown.sh to stop the running service
sh ${BASE_DIR}/scripts/kill_backend.sh

# Give some time for the process to terminate
sleep 3

# Call start.sh to start the service
sh ${BASE_DIR}/scripts/start_backend.sh