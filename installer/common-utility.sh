#!/usr/bin/env bash

readonly PACKAGES=(
    bash-completion
    curl
    git
    unzip
    wget
    zip
)

apt-get install "${PACKAGES[@]}"
