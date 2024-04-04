#!/usr/bin/env bash

function downloadTags() {
    local tags=""
    local page=1
    local -r pageSize=50
    local hasNext=true
    while [ "$hasNext" != "" ]; do
        local next="https://hub.docker.com/v2/namespaces/warnyul/repositories/redex/tags?page=$page&page_size=$pageSize"
        local tagsResponse=$(wget -q -O - "$next")
        tags+="$(echo "$tagsResponse" | grep -o '"name": *"[^"]*' | grep -o '[^"]*$') "
        hasNext=$(echo "$tagsResponse" | grep -o '"next":\s*"[^,"]*' | grep -o '[^"]*$')
        page=$((page+1))
    done
    echo $tags | tr ' ' '\n' | sort | head -n -1
}

function trim() {
    while read -r line; do
        echo "$line"
    done
}

function readBuildToolsVersions() {
    "$ANDROID_HOME"/cmdline-tools/latest/bin/sdkmanager --list | grep build-tools | cut -d'|' -f1 | cut -d';' -f2 | trim
}

#
# Returns a json array of items. Format of the items: "{redex-branch}@{agp-version}@{isLatest}"
#
function generateBuildMatrix() {
    local -r force="$1"
    local -r buildToolsVersions=$(readBuildToolsVersions | sort | uniq )
    local -r latest=$(echo "$buildToolsVersions" | grep -v '-' | tail -n 1)
    local -r channels=(stable main)
    local -r tags=$(downloadTags)
    local matrix=()

    for CHANNEL in ${channels[@]}; do
        local redexCommitHash=$(git submodule status | grep "redex_${CHANNEL}" | cut -d' ' -f2)
        while read -r line; do
            local dockerImageVersion="${CHANNEL}-${redexCommitHash}-androidbuildtools${line}-bionic-openjdk17"
            if [[ "$force" == "true" || "$(grep "\b${dockerImageVersion/-/\-}\b" <<< $tags)" == "" ]]; then
                local isLatest=false
                [[ "$line" == "$latest" && "$CHANNEL" == "stable" ]] && isLatest=true
                matrix+=("\"${CHANNEL}@${line}@${isLatest}\"")          
            fi
        done <<< "$buildToolsVersions"
    done
    echo -n "["
    local -r joined=$(printf ",%s" ${matrix[@]})
    echo -n ${joined:1}
    echo -n "]"
}

if [ -z $GITHUB_OUTPUT ]; then
    generateBuildMatrix $@
else
   echo "BUILD_MATRIX=$(generateBuildMatrix $@)" >> "$GITHUB_OUTPUT"
fi