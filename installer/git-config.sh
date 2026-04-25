#!/usr/bin/env bash

# ==========================
# -------- function --------
# ==========================

function confirmYesNo()
{
    local value
    while :; do
        read -ep "$1 (y/N): " value
        value=${value:-N}
        case $value in
            Y | y) true; return ;;
            N | n) false; return ;;
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

function findCredentialHelper()
{
    local -r WIN_GCM_PATH='/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe'

    if grep -iq WSL /proc/version; then
        if [[ -x $WIN_GCM_PATH ]]; then
            echo ${WIN_GCM_PATH/ /\\ }
            return
        fi
    fi

    echo store
}

# ======================
# -------- main --------
# ======================

function main()
{
    local -r GIT_CONFIG_COMMAND="git config --global"

    if ! command -v git > /dev/null; then
        echo "git is not installed"
        exit 1
    fi

    local -A map
    map[core.autocrlf]=input
    map[core.editor]=vi
    map[core.filemode]=true
    map[credential.helper]=$( findCredentialHelper )
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
            [[ $currentConfig == "$value" ]] && continue

            local message="overwirte it"
            [[ -n $value ]] && message+=" to '$value'"
            message+=?

            echo "'$key' is already set to '$currentConfig'"
            confirmYesNo "$message" || continue
        fi

        if [[ -z $value ]]; then
            while :; do
                local input
                read -ep "enter a value for '$key': " input
                if [[ -n $input ]]; then
                    value=$input
                    break
                fi
                echo "invalid input"
            done
        fi

        $GIT_CONFIG_COMMAND $key "$value"
    done
}

main "$@"
