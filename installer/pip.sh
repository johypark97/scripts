#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    # check pip is installed
    if command -v pip > /dev/null; then
        echo "pip is alreadly installed"
        exit 0
    fi

    # prepare to check required packages
    local check
    local packages=( curl python3 )
    if command -v dpkg > /dev/null; then
        check="dpkg -l"
        packages+=( python3-distutils )
    elif command -v rpm > /dev/null; then
        check="rpm -q"
    else
        echo "supported package manager is not detected. cannot proceed."
        exit 1
    fi

    # check required packages
    local abort=0
    local notInstalled
    local i
    for i in ${packages[@]}; do
        if ! $check $i > /dev/null 2>&1; then
            notInstalled+=( $i )
            abort=1
        fi
    done

    if (( $abort )); then
        echo "following packages are required: ${notInstalled[@]}"
        exit 1
    fi

    # install
    local URL=https://bootstrap.pypa.io/get-pip.py
    local tempFile=$( mktemp )
    curl -o $tempFile $URL
    python3 $tempFile --user
    rm $tempFile
}

main "$@"
