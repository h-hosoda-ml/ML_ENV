# !/bin/bash

set -eu

function usage() {
cat <<-EOF
    Usage: ./shell/run_container.sh {image_name} {container_name}
    ----args----
        image_name  Docker Image Name (Default: ml_image)
        container_name  Docker ContainerName (Default: ml_container)

    ---options----
    -h|--help   show help

EOF
}

function validation() {
    # 引数の検証
    if [ $# -ge 3 ]; then
        echo 'Too mant arguments!'
        usage
        exit 1
    fi

    # docker環境の検証
    if ! which docker > /dev/null 2>&1; then
        echo 'It is possible that Docker is not installed on the machine.'
        exit 1
    fi
}

validation "$@"

while [[ -n ${1:-} ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo 'Error: Invalid option. Use "--help"'
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

# 引数の取得
image_name=${1:-'ml_image'}
container_name=${2:-'ml_container'}

# TODO: deviceをコマンドラインから指定できるように
docker container run -dit --rm \
    --name ${container_name} \
    --gpus '"device=0"' \
    ${image_name}

# これは不要ならコメントアウト可
docker exec -it ${container_name} /bin/bash
