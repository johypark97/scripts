#!/usr/bin/bash

# ==========================
# -------- function --------
# ==========================

function install()
{
    local OS_DIST=$( awk -F = '$1 == "ID" { print $2 }' /etc/os-release )
    if [[ $OS_DIST != debian ]]; then
        echo "currently only support debian distribution"
        return $( false )
    fi

    local link=$1
    if [[ -z $link ]]; then
        echo "link is not set. cannot proceed."
        return $( false )
    fi

    local name=${link##*/}

    local path=$2
    if [[ -z $path ]]; then
        echo "path is not set. cannot proceed."
        return $( false )
    elif [[ ! -e $path ]]; then
        echo "path ($path) is not exists. cannot proceed."
        return $( false )
    elif [[ ! -x $path ]]; then
        echo "path ($path) is not executable. cannot proceed."
        return $( false )
    fi

    local priority=${3:-0}

    # the exit code will always be zero if the local declaration and the command
    # substitution are not separated
    local query; query=$( update-alternatives --query $name 2>/dev/null )
    if (( $? == 0 )); then
        local alternatives=$( echo "$query" | awk '$1 == "Alternative:" { print $2 }' )

        local i
        for i in $alternatives; do
            if [[ $i == $path ]]; then
                echo "$name alternative ($i) is already installed"
                return $( true )
            fi
        done

        link=$( echo "$query" | awk '$1 == "Link:" { print $2 }' )
    else
        if [[ -e $link ]]; then
            echo "link ($link) is already exists. cannot proceed."
            return $( false )
        fi
    fi

    update-alternatives --install $link $name $path $priority
    return $?
}

# ======================
# -------- main --------
# ======================

function main()
{
    local link=/usr/bin/vi
    local path=/usr/local/programs/neovim/bin/nvim
    local priority=50
    install $link $path $priority
}

main "$@"
