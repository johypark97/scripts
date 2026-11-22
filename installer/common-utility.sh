#!/usr/bin/env bash

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

dpkg_is_installed() {
    [[ -n ${1-} ]] || return 1
    local status
    status=$( dpkg-query -W -f='${Status}' "$1" 2>/dev/null ) || return 1
    [[ $status == "install ok installed" ]]
}

main()
{
    local -ra PACKAGES=(
        bash-completion
        curl
        git
        unzip
        wget
        zip
    )

    local width=0

    local key
    for key in "${PACKAGES[@]}"; do
        local x=${#key}
        (( x > width )) && width=$x
    done
    (( width += 4 ))

    local not_found

    printf 'Checking packages:\n'
    local package
    for package in "${PACKAGES[@]}"; do
        printf "%${width}s: " "$package"

        if dpkg_is_installed "$package"; then
            printf 'Installed.\n'
        else
            printf 'Not installed.\n'
            not_found+=( "$package" )
        fi
    done

    if (( !${#not_found} )); then
        printf 'All packages are installed.\n'
        return 0
    fi

    printf 'Some packages are missing.\n'
    confirm_yes_no "Would you like to install the missing packages?" || return 0

    apt-get install "${not_found[@]}"
}

main "$@"
