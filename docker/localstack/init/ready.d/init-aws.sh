#!/bin/bash

# LocalStack - init-fooks: https://docs.localstack.cloud/references/init-hooks/
# デバッグコマンド: docker logs django-work_devcontainer-localstack-1  | less
set -ex

printenv

APP_NAME=django-work
REGION=ap-northeast-1

for STAGE in "local" "test"; do

# secretsmanager: db secret
db_secret_file=$(mktemp)
cat <<EOF > $db_secret_file
{
  "db_host": "${DB_HOST}",
  "db_password": "${DB_PASSWORD}",
  "db_port": "${DB_PORT}",
  "db_user": "${DB_USER}"
}
EOF
awslocal secretsmanager create-secret \
  --region ${REGION} \
  --name "/${APP_NAME}/${STAGE}/db" \
  --secret-string file://${db_secret_file}


# s3: app bucket
awslocal s3api create-bucket \
  --region ${REGION} \
  --bucket ${APP_NAME}-${STAGE}-app \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

done