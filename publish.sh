#!/usr/bin/env bash

function publish() {
    local -r matrixItem="$1"
    local -r channel=$(echo "$matrixItem" | cut -d'@' -f1)
    local -r androidBuildToolsVersion=$(echo "$matrixItem" | cut -d'@' -f2)
    local -r isLatest=$(echo "$matrixItem" | cut -d'@' -f3)

    if [ "$isLatest" == "true" ]; then
        local latestArg="--latest"
    else
        local latestArg=""
    fi

    ./build.sh --update --push --channel="$channel" --build-tools-version="$androidBuildToolsVersion" $latestArg
}

publish "$@"