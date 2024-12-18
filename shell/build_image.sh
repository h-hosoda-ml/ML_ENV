# !/bin/bash

set -eu

function usage() {
cat <<-EOF
    Usage: ./shell/build_image.sh {image_name}
    ----args----
        image_name  Docker Image Name (Default: ml_image)

    ---options----
    -h|--help   show help

EOF
}

function validation() {
    # 引数の検証
    if [ $# -ge 2 ]; then
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
            exit 1
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

# 引数の取得 デフォルト'ml_image'
image_name=${1:-'ml_image'}

if docker image inspect ${image_name} > /dev/null 2>&1; then
    # 指定のイメージ名が存在する時
    read -p "The image ${image_name} already exists. Do you want to continue? (y/n): " choice
    case $choice in
        y|Y)
            echo "Continuing with the operation..."
            ;;
        n|N)
            echo "Operation aborted."
            exit 1
            ;;
        *)
            echo "Invalid input. Please enter 'y' or 'n'."
            exit 1
            ;;
    esac
fi

# TODO: pyenvのcurlに失敗した場合、再起処理 (たまに起こりうる)
docker image build -t ${image_name} .
