#!/bin/bash

# ======================
# -------- main --------
# ======================

function main()
{
    local OS_DIST=$( awk -F = '$1 == "ID" { print $2 }' /etc/os-release )
    local OS_DIST_FAMILY=$( awk -F = 'BEGIN { flag = 1; result = "" } $1 ~ /^ID(_LIKE)?$/ { if (flag) { result = $2; if ($1 == "ID_LIKE") flag = 0 } } END { print result }' /etc/os-release )

    echo "OS_DIST: $OS_DIST"
    echo "OS_DIST_FAMILY: $OS_DIST_FAMILY"
}

main "$@"
