#!/bin/bash

ROOT_DIR="$(cd $(dirname $0)/..; pwd)"
source $ROOT_DIR/bin/lib/setting.sh

cd $ROOT_DIR
jupyter lab --ip=* --port 8887 --no-browser --notebook-dir ${CONTAINER_PROJECT_ROOT}/app
