#!/bin/bash

# ========================
# -------- string --------
# ========================

STRING_HELP_INFO="Try '$( basename "$0" ) -h' for more information."

STRING_HELP=$( cat << EOF
Usage:
    $( basename "$0" ) (option...) [task]

Tasks:
    help    print help messages

Options:
    -v    enable verbose
    -h    print help messages
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

# ======================
# -------- main --------
# ======================

function main()
{
    local filename
    local flagVerbose=0

    OPTIND=1
    while getopts :f:vh opt; do
        case $opt in
            f) filename=$OPTARG ;;
            v) flagVerbose=1 ;;
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
        echo "requires a task"
        echo "$STRING_HELP_INFO"
        exit 1
    fi

    local task=$1
    case $task in
        *)
            echo "invalid task: $task"
            echo "$STRING_HELP_INFO"
            exit 1
            ;;
    esac
}

main "$@"
