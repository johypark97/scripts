#!/usr/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    # make an install command
    local install
    if command -v apt-get > /dev/null; then
        install="apt-get install"
    elif command -v yum > /dev/null; then
        install="yum install"
    else
        echo "supported package manager is not detected. cannot proceed."
        exit 1
    fi

    # install
    local packages=( bash-completion curl git unzip zip )
    $install ${packages[@]}
}

main "$@"
