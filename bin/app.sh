#!/bin/bash

function usage {
cat >&2 <<EOS
アプリ起動コマンド

[usage]
 $0 [options]

[options]
 -h | --help:
   ヘルプを表示
 -e | --env <ENV_PATH>:
   環境変数ファイルのパスを指定 (default: ${CONTAINER_PROJECT_ROOT}/env/local.env)
EOS
exit 1
}

source $CONTAINER_PROJECT_ROOT/bin/lib/setting.sh

ENV_PATH="${CONTAINER_PROJECT_ROOT}/env/local.env"
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help  ) usage;;
    -e | --env   ) shift; ENV_PATH=$1 ;;
    -* | --*     ) echo "$1 : 不正なオプションです" >&2; exit 1 ;;
    *            ) args+=("$1") ;;
  esac
  shift
done

[ "${#args[@]}" != 0 ] && usage
MODE="${args[0]}"

ENV_ABS_PATH=$(cd $(dirname $ENV_PATH); pwd)/$(basename $ENV_PATH)
if [ ! -f "$ENV_ABS_PATH" ]; then
  echo "$ENV_ABS_PATH が存在しません" >&2
  exit 1
fi

export $(cat $ENV_ABS_PATH | grep -v '^#' | xargs)

cd ${CONTAINER_PROJECT_ROOT}/app
python3.12 manage.py runserver 0.0.0.0:8008