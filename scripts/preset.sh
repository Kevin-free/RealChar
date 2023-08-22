#!/bin/bash

export BASE_DIR=$(pwd)
echo "$BASE_DIR"

echo "Current branch/tag: ${GITHUB_REF}"
source $HOME/miniconda/bin/activate realchar-env
alembic upgrade head