#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    if ! command -v npm > /dev/null; then
        echo "npm is not installed"
        exit 1
    fi

    npm config set prefix $HOME/.npm_global

    local OS_DIST=$( awk -F = '$1 == "ID" { print $2 }' /etc/os-release )
    if [[ $OS_DIST == msys2 ]]; then
        npm config set script-shell C:/msys64/usr/bin/bash.exe
    fi
}

main "$@"
