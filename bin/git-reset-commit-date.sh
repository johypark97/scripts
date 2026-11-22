#!/usr/bin/env bash

: # for line-specific ShellCheck suppression

readonly BASE_COMMAND=git-filter-repo

# shellcheck disable=SC2155
readonly CALLBACK_SCRIPT=$( cat << EOF
commit.committer_date = commit.author_date
EOF
)

# shellcheck disable=SC2155
readonly HELP_HINT="Try '$( basename "$0" ) -h' for more information."

# shellcheck disable=SC2155
readonly HELP_MAIN=$( cat << EOF
Reset the commit date to the author date by the specified number of commits
from HEAD.

Usage:
    $( basename "$0" ) COUNT [ARG]...

    count    set the number of commits to reset

Options:
    -h    display this help and exit

Args:
    Additional arguments to pass to $BASE_COMMAND.
EOF
)

confirm_yes_no()
{
    local prompt=${1:?prompt is required}
    while :; do
        read -erp "$prompt (y/N): " value || return 1
        local value=${value:-N}
        case $value in
            Y | y) return 0 ;;
            N | n) return 1 ;;
            *) printf 'invalid input: %s\n' "$value" >&2 ;;
        esac
    done
}

main()
{
    command -v "$BASE_COMMAND" > /dev/null || {
        printf '%s is not installed\n' "$BASE_COMMAND" >&2
        printf 'please install the %s using package manager or python3-pip\n' "$BASE_COMMAND" >&2
        return 1
    }

    local OPTIND=1 OPTARG opt
    while getopts :h opt; do
        case $opt in
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
        printf 'count is required\n' >&2
        printf '%s\n' "$HELP_HINT" >&2
        return 1
    }

    local count=$1
    shift

    [[ $count =~ ^[0-9]+$ ]] || {
        printf 'count is not numeric\n' >&2
        return 1
    }
    count=$(( 10#$count ))

    local cmd=$BASE_COMMAND
    cmd+=" --refs HEAD~$count..HEAD"
    cmd+=" $*"

    printf 'The following command will be executed if you continue.\n\n'
    printf '%s\n    --commit-callback %s\n\n' "$cmd" "'$CALLBACK_SCRIPT'"

    confirm_yes_no "Do you want to proceed?" || return 0

    $cmd --commit-callback "$CALLBACK_SCRIPT"
}

main "$@"
