#!/usr/bin/env bash

read -r -d '' USAGE <<- EOM
    \n
    Usage: ./build.sh [OPTIONS]\n
    \n
    Options:\n
    -u, --update \t Update git submodules before build\n
    -lp --local-push \t Push to a local repository\n
    -p, --push \t Push image to docker hub\n
    -h, --help \t Print usage description\n
EOM

IMAGE_NAME=redex
IMAGE=warnyul/$IMAGE_NAME
LOCAL_IMAGE=localhost:5000/$IMAGE_NAME
LOCAL_PUSH=false
PUSH=false

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--update)
            git submodule update --init
        ;;
        -lp|--local-push)
            LOCAL_PUSH=true
        ;;
        -p|--push)
            PUSH=true
        ;;
        -h|--help|*)
            echo -e "\n Unknown argument: '$1'.\n See './build.sh --help'.\n"
            echo -e $USAGE
            exit 1
        ;;
    esac
    shift
done

# Build
COMMIT_HASH=$(git ls-tree master redex | cut -f 1 | cut -f 3 -d' ')
docker build -t "$IMAGE" .

# Publish to a local repo
if $LOCAL_PUSH; then
    docker run -d -p 5000:5000 --restart=always --name registry registry 2> /dev/null
    docker tag "$IMAGE:latest" $LOCAL_IMAGE
    docker push $LOCAL_IMAGE
fi

# Publish to Docker Hub
if $PUSH; then
    docker tag "$IMAGE:latest" "$IMAGE:$COMMIT_HASH"
    docker push warnyul/redex
fi