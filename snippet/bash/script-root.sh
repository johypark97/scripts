#!/usr/bin/env bash

: # for line-specific ShellCheck suppression

# shellcheck disable=SC2155
readonly SCRIPT_ROOT=$( dirname "$( realpath "${BASH_SOURCE[0]}" )" )

printf 'SCRIPT_ROOT: %s\n' "$SCRIPT_ROOT"
