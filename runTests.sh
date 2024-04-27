#!/usr/bin/env bash

set -eo pipefail

function setupDx() {
    local -r runTests="$1"

    if [ "${runTests}" = "true" ]; then
        if ! command -v dx >/dev/null 2>&1; then
            apt-get install -q --no-install-recommends -y dalvik-exchange && \
                ln -s /usr/bin/dalvik-exchange /usr/local/bin/dx
        fi
    fi
}

function runTests() {
    local -r runTests="$1"

    if [ "${runTests}" = "true" ]; then
        make check
    fi
}

setupDx "$@" && runTests "$@"