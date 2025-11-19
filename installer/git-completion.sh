#!/usr/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    if ! command -v curl > /dev/null; then
        echo "curl is not installed"
        exit 1
    fi

    local FILE=~/.git-completion.bash
    local URL=https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
    curl -o $FILE $URL
}

main "$@"
