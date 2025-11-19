#!/usr/bin/bash

# =======================
# -------- const --------
# =======================

BASE_COMMAND=git-filter-repo

CALLBACK_SCRIPT=$( cat << EOF
commit.committer_date = commit.author_date
EOF
)

# ========================
# -------- string --------
# ========================

STRING_HELP_INFO="Try '$( basename "$0" ) -h' for more information."

STRING_HELP=$( cat << EOF
  Reset the commit date to the author date by the specified number of commits
from HEAD.

Usage:
    $( basename "$0" ) [count] (arg...)

    count     set the number of commits to reset

Options:
    -h           print help messages

Args:
    Additional arguments to be passed to $BASE_COMMAND.
EOF
)

# ==========================
# -------- function --------
# ==========================

function getopts_printError()
{
    if [[ -n $2 ]]; then
        case $1 in
            :) echo "option requires an argument: -$2" ;;
            ?) echo "invalid option: -$2" ;;
            *) echo "unknown error" ;;
        esac
    fi
}

function checkWithEcho_command()
{
    command -v "$1" > /dev/null && return $( true )
    echo "cannot find command '$1'"
    return $( false )
}

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

# ======================
# -------- main --------
# ======================

function main()
{
    checkWithEcho_command git-filter-repo || exit 1

    OPTIND=1
    while getopts :h opt; do
        case $opt in
            h)
                echo "$STRING_HELP"
                exit 0
                ;;
            *)
                getopts_printError "$opt" "$OPTARG"
                echo "$STRING_HELP_INFO"
                exit 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    if (( ! $# )); then
        echo "requires a count"
        echo "$STRING_HELP_INFO"
        exit 1
    fi
    local count=$1
    shift 1

    local cmd=$BASE_COMMAND
    cmd+=" --refs HEAD~$count..HEAD"
    cmd+=" $@"

    echo "The following command will be executed if you continue."
    echo
    echo $cmd
    echo "    --commit-callback '$CALLBACK_SCRIPT'"
    echo
    confirmYesNo "Do you want to proceed?" || exit 0

    $cmd --commit-callback "$CALLBACK_SCRIPT"
}

main "$@"
