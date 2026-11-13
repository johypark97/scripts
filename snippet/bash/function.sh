#!/usr/bin/env bash

check_command()
{
    command -v "$1" > /dev/null || {
        printf 'command not found: %s\n' "$1" >&2
        return 1
    }
}

check_root_permission()
{
    (( !EUID )) || {
        printf 'must be run as root\n' >&2
        return 1
    }
}

confirm_yes_no()
{
    local prompt=${1:?prompt is required}
    while :; do
        read -erp "$prompt (y/N): " value
        local value=${value:-N}
        case $value in
            Y | y) return 0 ;;
            N | n) return 1 ;;
            *) printf 'invalid input: %s\n' "$value" >&2 ;;
        esac
    done
}

# https://stackoverflow.com/a/5032641
strindex()
{
    local x=${1%%"$2"*}
    [[ $x == "$1" ]] && printf '%d' -1 || printf '%d' "${#x}"
}
