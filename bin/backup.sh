#!/usr/bin/bash

# ========================
# -------- string --------
# ========================

STRING_HELP_INFO="Try '$( basename "$0" ) -h' for more information."

STRING_HELP=$( cat << EOF
Usage:
    $( basename "$0" ) (option...) [filename] [target...]

Options:
    -d    add date to filename
    -t    add time to filename
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

function checkWithEcho_command()
{
    command -v "$1" > /dev/null && return $( true )
    echo "cannot find command '$1'"
    return $( false )
}

# ======================
# -------- main --------
# ======================

function main()
{
    checkWithEcho_command zip || exit 1

    local flagDate=0
    local flagTime=0
    local flagVerbose=0

    OPTIND=1
    while getopts :dtvh opt; do
        case $opt in
            d) flagDate=1 ;;
            t) flagTime=1 ;;
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
        echo "requires a filename"
        echo "$STRING_HELP_INFO"
        exit 1
    fi

    local filename=$1
    shift 1
    (( flagDate )) && filename+=-$( date +%Y%m%d )
    (( flagTime )) && filename+=-$( date +%H%M%S )
    filename+=.zip

    if (( ! $# )); then
        echo "requires targets"
        echo "$STRING_HELP_INFO"
        exit 1
    fi

    local cmd="zip -r9"
    (( flagVerbose )) && cmd+=" -v"

    $cmd "$filename" "$@"
}

main "$@"
