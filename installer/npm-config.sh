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
}

main "$@"
