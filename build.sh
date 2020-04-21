#!/usr/bin/env bash

read -r -d '' USAGE <<- EOM
    \n
    Usage: ./build.sh [OPTIONS]\n
    \n
    Options:\n
    -u, --update \t Update git submodules before build\n
    -lp --local-push \t Push to a local repository\n
    -l, --latest \t Tag image as latest
    -p, --push \t Push image to docker hub\n
    -h, --help \t Print usage description\n
EOM

set -e

IMAGE_NAME=redex
IMAGE=warnyul/$IMAGE_NAME
LOCAL_IMAGE=localhost:5000/$IMAGE_NAME
LOCAL_PUSH=false
LATEST=false
PUSH=false
UPDATE_REDEX=false
STABLE=true
VERSION_PREFIX=stable

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--master)
            STABLE=false
        ;;
        -u|--update)
            UPDATE_REDEX=true
        ;;
        -lp|--local-push)
            LOCAL_PUSH=true
        ;;
        -l|--latest)
            LATEST=true
        ;;
        -p|--push)
            PUSH=true
        ;;
        -h|--help|*)
            echo -e "\n Unknown argument: '$1'.\n See './build.sh --help'.\n"
            echo -e ${USAGE}
            exit 1
        ;;
    esac
    shift
done

if [[ ${STABLE} ]]; then
    git submodule set-branch -b stable redex 
else
    git submodule set-branch -b master redex 
fi

git submodule update --init

if [[ ${UPDATE_REDEX} ]]; then
    git submodule update --recursive --remote
fi

# Build
COMMIT_HASH=$(git ls-tree master redex | cut -f 1 | cut -f 3 -d' ')
VERSION=${VERSION_PREFIX}-${COMMIT_HASH}
docker build -t "${IMAGE}:${VERSION}" .

# Publish to a local repo
if ${LOCAL_PUSH}; then
    docker run -d -p 5000:5000 --restart=always --name registry registry 2> /dev/null
    docker tag "${IMAGE}:${VERSION}" "${LOCAL_IMAGE}:${VERSION}"
    docker tag "${IMAGE}:${VERSION}" ${LOCAL_IMAGE}
    docker push ${LOCAL_IMAGE}
fi

if [[ $LATEST ]]; then
    docker tag "${IMAGE}:${VERSION}" "${IMAGE}:latest"
fi

# Publish to Docker Hub
if ${PUSH}; then
    docker push warnyul/redex
fi