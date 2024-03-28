#!/usr/bin/env bash

read -r -d '' USAGE <<- EOM
    \n
    Usage: ./build.sh [OPTIONS]\n
    \n
    Options:\n
    --build-tools-version=VERSION \t Android build tools version. Default: 34.0.0\n
    --channel=CHANNEL \t Redex branch master or stable default stable. Default: stable
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
REDEX_BRANCH=stable
BUILD_TOOLS_VERSION=34.0.0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-tools-version=*)
            BUILD_TOOLS_VERSION="${1#*=}"
            if [ -z $BUILD_TOOLS_VERSION ]; then
                echo -e "\n --build-tools-version is required.\n See './build.sh --help'.\n"
                echo -e "$USAGE"
                exit 1
            fi
        ;;
        --channel=*)
            REDEX_BRANCH="${1#*=}"
            if [ -z $REDEX_BRANCH ]; then
                echo -e "\n --channel is required.\n See './build.sh --help'.\n"
                echo -e "$USAGE"
                exit 1
            fi
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
            echo -e "$USAGE"
            exit 1
        ;;
    esac
    shift
done

if [ "$UPDATE_REDEX" == "true" ]; then
    git submodule update --init
    git submodule update --remote
fi

# Build
COMMIT_HASH=$(git submodule status | grep "redex_${REDEX_BRANCH}" | cut -d' ' -f2)
BASE_IMAGE="warnyul/android-build-tools:${BUILD_TOOLS_VERSION}-bionic-openjdk17"
docker pull "$BASE_IMAGE"
docker tag "$BASE_IMAGE" base-image
VERSION="${REDEX_BRANCH}-${COMMIT_HASH}-androidbuildtools${BUILD_TOOLS_VERSION}-bionic-openjdk17"

docker build \
    --build-arg="${REDEX_BRANCH}" \
    --build-arg="${BUILD_TOOLS_VERSION}" \
    -t "${IMAGE}:${VERSION}" .

# Publish to a local repo
if [ "${LOCAL_PUSH}" == "true" ]; then
    docker run -d -p 5000:5000 --restart=always --name registry registry 2> /dev/null
    docker tag "${IMAGE}:${VERSION}" "${LOCAL_IMAGE}:${VERSION}"
    docker tag "${IMAGE}:${VERSION}" ${LOCAL_IMAGE}
    docker push ${LOCAL_IMAGE}
fi

if [ "$LATEST" == "true" ]; then
    docker tag "${IMAGE}:${VERSION}" "${IMAGE}:latest"
fi

# Publish to Docker Hub
if [ "$PUSH" == "true" ]; then
    docker image push --all-tags "$IMAGE"
fi