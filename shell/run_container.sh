# !/bin/bash

set -eu

# 引数の検証
if [ $# -ge 3 ]; then
    echo 'Usage: ./shell/run_container.sh {image_name} {container_name}'
    exit 1
fi

# docker環境の検証
if ! which docker > /dev/null 2>&1; then
    echo 'It is possible that Docker is not installed on the machine.'
    exit 1
fi

# 引数の取得
image_name=${1:-'ml_image'}
container_name=${2:-'ml_container'}

# イメージの存在を検証
if ! docker image inspect ${image_name} > /dev/null 2>&1; then
    echo "The image ${image_name} does not exists."
    exit 1
fi

# TODO: deviceをコマンドラインから指定できるように
docker container run -dit --rm \
    --name ${container_name} \
    --gpus '"device=0"' \
    ${image_name}

# これは不要ならコメントアウト可
docker exec -it ${container_name} /bin/bash