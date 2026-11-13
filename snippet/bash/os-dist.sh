#!/usr/bin/env bash

: # enable line-specific shellcheck suppression

# shellcheck disable=SC2155
readonly OS_DIST=$( awk -F = '$1 == "ID" { print $2 }' /etc/os-release )

# shellcheck disable=SC2155
readonly OS_DIST_FAMILY=$( awk -F = 'BEGIN { flag = 1; result = "" } $1 ~ /^ID(_LIKE)?$/ { if (flag) { result = $2; if ($1 == "ID_LIKE") flag = 0 } } END { print result }' /etc/os-release )

printf 'OS_DIST: %s\n' "$OS_DIST"
printf 'OS_DIST_FAMILY: %s\n' "$OS_DIST_FAMILY"
