#!/usr/bin/env bash

set -o pipefail

check_packages()
{
    : "${@:?argument is required}"

    local -a not_found

    local package
    for package in "$@"; do
        dpkg -l "$package" > /dev/null 2>&1 || not_found+=( "$package" )
    done

    (( !${#not_found[@]} )) || {
        printf 'following packages are required:\n' >&2
        printf -- '- %s\n' "${not_found[@]}" >&2
        return 1
    }
}

main()
{
    local -r GITHUB_API=https://api.github.com/repos/adobe-fonts/source-code-pro/releases/latest
    local -r INSTALL_PATH=$HOME/.local/share/fonts/SourceCodePro

    check_packages curl fontconfig unzip || return 1

    # download
    local response
    response=$( curl "$GITHUB_API" )
    if printf '%s' "$response" | grep "Not Found" > /dev/null; then
        printf 'github api request error\n' >&2
        return 1
    fi

    local download_url
    download_url=$(
        printf '%s' "$response" \
        | grep browser_download_url \
        | grep TTF \
        | cut -d : -f 2- \
        | tr -d '"[:space:]'
    )

    local download_path
    download_path=$( mktemp --suffix=.zip )
    curl -L -o "$download_path" "$download_url" || return 1

    # install
    mkdir -p "$INSTALL_PATH" || return 1
    unzip -d "$INSTALL_PATH" "$download_path" || return 1
    rm "$download_path"

    fc-cache -f -v
}

main "$@"
