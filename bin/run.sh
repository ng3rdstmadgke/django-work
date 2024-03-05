#!/bin/bash -l

function usage {
cat >&2 <<EOS
コンテナ起動コマンド

[usage]
 $0 <MODE> [options]

[args]
  MODE:
    app    : アプリを起動
    shell  : コンテナにshellでログイン
    jupyter: JupyterLabを起動

[options]
 -h | --help:
   ヘルプを表示
 -e | --env <ENV_PATH>:
   環境変数ファイルのパスを指定 (default: ${ROOT_DIR}/app/local.env)
 -u | --uid <USER_ID>:
   ユーザーidを指定 (default: $(id -u))
 -g | --gid <GROUP_ID>:
   グループidを指定 (default: $(id -g))
EOS
exit 1
}

ROOT_DIR="$(cd $(dirname $0)/..; pwd)"
source $ROOT_DIR/bin/lib/setting.sh

ENV_PATH="${ROOT_DIR}/env/local.env"
MODE=
USER_ID=$(id -u)
GROUP_ID=$(id -g)
PROFILE_OPTIONS=
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help  ) usage;;
    -e | --env   ) shift; ENV_PATH=$1 ;;
    -u | --uid   ) shift; USER_ID=$1 ;;
    -g | --gid   ) shift; GROUP_ID=$1 ;;
    --profile    ) shift; PROFILE_OPTIONS="--profile $1" ;;
    -* | --*     ) echo "$1 : 不正なオプションです" >&2; exit 1 ;;
    *            ) args+=("$1") ;;
  esac
  shift
done

[ "${#args[@]}" != 1 ] && usage
MODE="${args[0]}"

if [[ ! "$MODE" =~ ^(app|shell|jupyter)$ ]]; then
  echo "--mode には app, shell, jupyter のいずれかを指定してください" >&2
  exit 1
fi

ENV_ABS_PATH=$(cd $(dirname $ENV_PATH); pwd)/$(basename $ENV_PATH)
if [ ! -f "$ENV_ABS_PATH" ]; then
  echo "$ENV_ABS_PATH が存在しません" >&2
  exit 1
fi


set -e
cd "$ROOT_DIR"

LOCAL_IMAGE_NAME="${PROJECT_NAME}/${USER_ID}-${GROUP_ID}-app:latest"

################################
# Docker build
################################
docker build \
  --build-arg host_uid=$USER_ID \
  --build-arg host_gid=$GROUP_ID \
  --rm \
  -f docker/app/Dockerfile \
  -t $LOCAL_IMAGE_NAME \
  .

################################
# Docker run
################################
OPTIONS=
if [ "$MODE" = "shell" ]; then
  CMD="su - app"
elif [ "$MODE" = "jupyter" ]; then
  CMD="jupyter lab --ip=* --port 8887 --no-browser --notebook-dir /opt/app/"
  OPTIONS="-p 8887:8887 --name ${PROJECT_NAME}-jupyter"
else
  CMD="python manage.py runserver 0.0.0.0:8008"
  OPTIONS="-p 8008:8008 --name ${PROJECT_NAME}-app"
fi

if [ -n "$PROFILE_OPTIONS" ]; then
  AWS_ACCESS_KEY_ID=$(aws $PROFILE_OPTIONS configure get aws_access_key_id)
  AWS_SECRET_ACCESS_KEY=$(aws $PROFILE_OPTIONS configure get aws_secret_access_key)
fi

docker run --rm -ti \
  $OPTIONS \
  --env-file "$ENV_ABS_PATH" \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -v ${ROOT_DIR}/app:/opt/app \
  $LOCAL_IMAGE_NAME \
  $CMD