#!/bin/bash

ROOT_DIR="$(cd $(dirname $0)/..; pwd)"
source $ROOT_DIR/bin/lib/setting.sh

cd ${ROOT_DIR}/app
python3.12 manage.py runserver 0.0.0.0:8008