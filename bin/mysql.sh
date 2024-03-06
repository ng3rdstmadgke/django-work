#!/bin/bash

ROOT_DIR="$(cd $(dirname $0)/..; pwd)"
source $ROOT_DIR/bin/lib/setting.sh

SECRET_STRING=$(aws --endpoint-url "$AWS_ENDPOINT_URL" secretsmanager get-secret-value --secret-id /${PROJECT_NAME}/local/db --query "SecretString" --output text)
DB_HOST=$(echo $SECRET_STRING | jq -r ".db_host")
DB_PASSWORD=$(echo $SECRET_STRING | jq -r ".db_password")
DB_PORT=$(echo $SECRET_STRING | jq -r ".db_port")
DB_USER=$(echo $SECRET_STRING | jq -r ".db_user")

echo MYSQL_PWD=$DB_PASSWORD mysql -h $DB_HOST -u $DB_USER -P $DB_PORT
MYSQL_PWD=$DB_PASSWORD mysql -h $DB_HOST -u $DB_USER -P $DB_PORT