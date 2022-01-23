#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    # prepare to check required packages
    local check
    local packages=( curl fontconfig unzip )

    if command -v dpkg > /dev/null; then
        check="dpkg -l"
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

    # download
    local GITHUB_USER=adobe-fonts
    local GITHUB_REPO=source-code-pro
    local GITHUB_API=https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest

    local request=$( curl $GITHUB_API )
    local status=$( echo "$request" | grep "Not Found" )
    if [[ -n $status ]]; then
        echo "github api request error"
        exit 1
    fi

    local downloadUrl=$( echo "$request" | grep browser_download_url | grep TTF | cut -d : -f 2- | tr -d \"[:space:] )

    # install
    local tempFile=$( mktemp --suffix=.zip )
    curl -L -o $tempFile $downloadUrl

    local FONTS_DIR=$HOME/.local/share/fonts
    if [[ ! -d $FONTS_DIR ]]; then
        mkdir -p $FONTS_DIR
    fi

    local INSTALL_PATH=$FONTS_DIR/SourceCodePro
    unzip $tempFile -d $INSTALL_PATH
    rm $tempFile

    fc-cache -f -v
}

main "$@"
