#!/bin/bash

# ==========================
# -------- function --------
# ==========================

function confirmYesNo()
{
    local value
    while :; do
        read -p "$1 (y/N): " value
        value=${value:-n}
        case $value in
            Y | y) return $( true ) ;;
            N | n) return $( false ) ;;
            *) echo "invalid input: $value" ;;
        esac
    done
}

function setGitConfig()
{

    local value=$( $COMMAND $1 )
    [[ $value == $2 ]] && return

    if [[ -n $value ]]; then
        echo
        echo "'$1' is already set to '$value'"

        confirmYesNo "overwirte it to '$2'?" || return
    fi

    $COMMAND $1 $2
}

# ======================
# -------- main --------
# ======================

function main()
{
    local GIT_CONFIG_COMMAND="git config --global"

    if ! command -v git > /dev/null; then
        echo "git is not installed"
        exit 1
    fi

    declare -A map
    map[core.autocrlf]=input
    map[core.editor]=vi
    map[core.filemode]=true
    map[credential.helper]=store
    map[init.defaultBranch]=main
    map[pull.ff]=only
    map[pull.rebase]=false
    map[user.email]=""
    map[user.name]=""

    local key
    for key in ${!map[@]}; do
        local value=${map[$key]}

        local currentConfig=$( $GIT_CONFIG_COMMAND $key )
        if [[ -n $currentConfig ]]; then
            [[ $currentConfig == $value ]] && continue

            local message="overwirte it"
            [[ -n $value ]] && message+=" to '$value'"
            message+=?

            echo "'$key' is already set to '$currentConfig'"
            confirmYesNo "$message" || continue
        fi

        if [[ -z $value ]]; then
            while :; do
                local input
                read -p "enter a value for '$key': " input
                if [[ -n $input ]]; then
                    value=$input
                    break
                fi
                echo "invalid input"
            done
        fi

        $GIT_CONFIG_COMMAND $key $value
    done
}

main "$@"
