#!/usr/bin/env bash

# ========================
# -------- string --------
# ========================

readonly STRING_HELP_INFO="Try '$( basename "$0" ) -h' for more information."

readonly STRING_HELP=$( cat << EOF
Compresses files and automatically appends the date and time.

Usage:
    $( basename "$0" ) (option...) [filename] [target...]

Options:
    -d    add date to filename
    -t    add time to filename
    -g    compress the archive with gzip. it does not affect the -z option.
    -z    use zip instead tar
    -D    dry run
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
    local flagDate=0
    local flagTime=0
    local flagGzip=0
    local flagZip=0
    local flagDryRun=0
    local flagVerbose=0

    OPTIND=1
    while getopts :dtgzDvh opt; do
        case $opt in
            d) flagDate=1 ;;
            t) flagTime=1 ;;
            g) flagGzip=1 ;;
            z) flagZip=1 ;;
            D) flagDryRun=1 ;;
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

    local archiveFilename=$1
    shift 1
    (( flagDate )) && archiveFilename+=-$( date +%Y%m%d )
    (( flagTime )) && archiveFilename+=-$( date +%H%M%S )

    if (( flagZip )); then
        archiveFilename+=.zip
    elif (( flagGzip )); then
        archiveFilename+=.tar.gz
    else
        archiveFilename+=.tar
    fi

    if (( ! $# )); then
        echo "requires targets"
        echo "$STRING_HELP_INFO"
        exit 1
    fi

    local verboseOption
    (( flagVerbose )) && verboseOption=v

    local archiveCommand
    if (( flagZip )); then
        archiveCommand="zip -r$verboseOption"
    elif (( flagGzip )); then
        archiveCommand="tar -cz${verboseOption}f"
    else
        archiveCommand="tar -c${verboseOption}f"
    fi

    if (( flagDryRun )); then
        echo "$archiveCommand $archiveFilename $@"
    else
        $archiveCommand "$archiveFilename" "$@"
    fi
}

main "$@"
