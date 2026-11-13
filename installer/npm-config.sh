#!/usr/bin/env bash

command -v npm > /dev/null || {
    printf 'npm is not installed\n' >&2
    exit 1
}

npm config set prefix "$HOME/.npm_global"
