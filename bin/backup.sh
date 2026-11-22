#!/usr/bin/env bash

: # for line-specific ShellCheck suppression

# shellcheck disable=SC2155
readonly HELP_HINT="Try '$( basename "$0" ) -h' for more information."

# shellcheck disable=SC2155
readonly HELP_MAIN=$( cat << EOF
Archive files and append timestamp to the filename.

Usage:
    $( basename "$0" ) [OPTION]... FILENAME TARGET...

Options:
    -d    add date to filename
    -t    add time to filename
    -g    compress the archive with gzip. it does not affect the -z option.
    -z    use zip instead tar
    -D    dry run
    -v    enable verbose output
    -h    display this help and exit
EOF
)

main()
{
    local opt_date=0
    local opt_time=0
    local opt_gzip=0
    local opt_zip=0
    local opt_dry_run=0
    local opt_verbose=0

    local OPTIND=1 OPTARG opt
    while getopts :dtgzDvh opt; do
        case $opt in
            d) opt_date=1 ;;
            t) opt_time=1 ;;
            g) opt_gzip=1 ;;
            z) opt_zip=1 ;;
            D) opt_dry_run=1 ;;
            v) opt_verbose=1 ;;
            h)
                printf '%s\n' "$HELP_MAIN"
                return 0
                ;;
            :)
                [[ -n $OPTARG ]] && \
                    printf 'option requires an argument: -%s\n' "$OPTARG" >&2
                printf '%s\n' "$HELP_HINT" >&2
                return 1
                ;;
            \?)
                [[ -n $OPTARG ]] && \
                    printf 'invalid option: -%s\n' "$OPTARG" >&2
                printf '%s\n' "$HELP_HINT" >&2
                return 1
                ;;
            *)
                printf 'unexpected error\n' >&2
                return 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    (( $# )) || {
        printf 'filename is required\n' >&2
        printf '%s\n' "$HELP_HINT" >&2
        return 1
    }

    local filename=$1
    shift

    (( $# )) || {
        printf 'target is required\n' >&2
        printf '%s\n' "$HELP_HINT" >&2
        return 1
    }

    local cmd
    if (( opt_zip )); then
        cmd="zip -r"
        (( opt_verbose )) && cmd+=v
    else
        cmd="tar -c"
        (( opt_gzip )) && cmd+=z
        (( opt_verbose )) && cmd+=v
        cmd+=f
    fi

    (( opt_date )) && filename+=-$( date +%Y%m%d )
    (( opt_time )) && filename+=-$( date +%H%M%S )

    if (( opt_zip )); then
        filename+=.zip
    elif (( opt_gzip )); then
        filename+=.tar.gz
    else
        filename+=.tar
    fi

    if (( opt_dry_run )); then
        printf '%s\n' "$cmd $filename $*"
    else
        $cmd "$filename" "$@"
    fi
}

main "$@"
