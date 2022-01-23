#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    local install
    local packages=( gcc make perl )
    if command -v apt-get > /dev/null; then
        install="apt-get install"
        packages+=( linux-headers-$( uname -r ) )
    elif command -v yum > /dev/null; then
        install="yum install"
        packages+=( kernel-devel )
    else
        echo "supported package manager is not detected. cannot proceed."
        exit 1
    fi
    $install ${packages[@]}
}

main "$@"
