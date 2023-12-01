#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    if ! command -v git > /dev/null; then
        echo "git is not installed"
        exit 1
    fi

    local i
    for i in email name; do
        while :; do
            local input
            read -p "enter user $i: " input
            if [[ -n $input ]]; then
                git config --global user.$i $input
                break
            fi
            echo "invalid input"
        done
    done

    git config --global core.editor vi
    git config --global credential.helper store
    git config --global init.defaultBranch main
    git config --global pull.ff only
    git config --global pull.rebase false
}

main "$@"
