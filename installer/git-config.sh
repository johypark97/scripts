#!/usr/bin/env bash

confirm_yes_no()
{
    local prompt=${1:?prompt is required}
    while :; do
        read -erp "$prompt (y/N): " value || return 1
        local value=${value:-N}
        case $value in
            Y | y) return 0 ;;
            N | n) return 1 ;;
            *) printf 'invalid input: %s\n' "$value" >&2 ;;
        esac
    done
}

main()
{
    local -r GIT_CONFIG_COMMAND="git config --global"

    command -v git > /dev/null || {
        printf 'git is not installed\n' >&2
        return 1
    }

    local -A map=(
        [core.autocrlf]=input
        [core.editor]=vi
        [core.filemode]=true
        [credential.helper]=store
        [init.defaultBranch]=main
        [pull.ff]=only
        [pull.rebase]=false
        [user.email]=""
        [user.name]=""
    )

    local key
    for key in "${!map[@]}"; do
        local value=${map[$key]}

        local current_config
        current_config=$( $GIT_CONFIG_COMMAND "$key" )
        if [[ -n $current_config ]]; then
            [[ $current_config == "$value" ]] && continue

            local message="overwirte it"
            [[ -n $value ]] && message+=" to '$value'"
            message+=\?

            printf '%s is already set to %s\n' "'$key'" "'$current_config'"
            confirm_yes_no "$message" || continue
        fi

        if [[ -z $value ]]; then
            while :; do
                local input
                read -erp "enter a value for '$key': " input || return 1
                if [[ -n $input ]]; then
                    value=$input
                    break
                fi
                printf 'invalid input\n' >&2
            done
        fi

        $GIT_CONFIG_COMMAND "$key" "$value"
    done
}

main "$@"
