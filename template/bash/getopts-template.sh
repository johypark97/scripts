#!/usr/bin/env bash

: # for line-specific ShellCheck suppression

# shellcheck disable=SC2155
readonly HELP_HINT="Try '$( basename "$0" ) -h' for more information."

# shellcheck disable=SC2155
readonly HELP_MAIN=$( cat << EOF
getopts template

Usage:
    $( basename "$0" ) [OPTION]... COMMAND

Commands:
    help    display help information

Options:
    -v    enable verbose output
    -h    display this help and exit
EOF
)

main()
{
    local opt_filename
    local opt_verbose=0

    local OPTIND=1 OPTARG opt
    while getopts :f:vh opt; do
        case $opt in
            f) opt_filename=$OPTARG ;;
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
        printf 'command is required\n' >&2
        printf '%s\n' "$HELP_HINT" >&2
        return 1
    }

    local cmd=$1
    shift

    case $cmd in
        help)
            printf '%s\n' "$HELP_MAIN"
            return 0
            ;;
        *)
            printf 'invalid command: %s\n' "$cmd" >&2
            printf '%s\n' "$HELP_HINT" >&2
            return 1
            ;;
    esac
}

main "$@"
