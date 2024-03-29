#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    # prepare to check required packages
    local check
    local packages=( cmake curl gettext ninja-build unzip )

    if command -v dpkg > /dev/null; then
        check="dpkg -l"
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

    # prepare build environment
    local GIT_URL=https://github.com/neovim/neovim
    local PREFIX=/usr/local/programs/neovim
    local WORKING_DIR=$HOME/neovim-build

    if [[ -d $WORKING_DIR ]]; then
        echo "working directory '$WORKING_DIR' is exists. cannot proceed."
        exit 1
    fi

    # build
    git clone $GIT_URL $WORKING_DIR
    cd $WORKING_DIR
    git checkout stable
    make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$PREFIX
}

main "$@"
