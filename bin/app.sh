#!/bin/bash

source $CONTAINER_PROJECT_ROOT/bin/lib/setting.sh

cd ${CONTAINER_PROJECT_ROOT}/app
python3.12 manage.py runserver 0.0.0.0:8008