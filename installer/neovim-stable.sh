#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    # check build prerequisites
    local check
    local packages=( autoconf automake cmake curl gettext git libtool ninja-build unzip )

    if command -v dpkg > /dev/null; then
        check="dpkg -l"
        packages+=( doxygen g++ libtool-bin pkg-config )
    elif command -v rpm > /dev/null; then
        check="rpm -q"
        packages+=( gcc gcc-c++ make patch pkgconfig )
    else
        echo "supported package manager is not detected. cannot proceed."
        exit 1
    fi

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
    local WORKING_DIR=$HOME/build-neovim

    if [[ -d $WORKING_DIR ]]; then
        echo "working directory '$WORKING_DIR' is exists. cannot proceed."
        exit 1
    fi

    git clone $GIT_URL $WORKING_DIR
    cd $WORKING_DIR
    git checkout stable
    make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$PREFIX
}

main "$@"
