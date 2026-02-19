#!/usr/bin/env bash

awk -F= '
/^\s*dictcheck/ {
    gsub(/[[:space:]]/, "", $2)
    val = $2
    found = 1
    exit
}
END {
    if (found) {
        print val
    } else {
        print "1"
    }
}
' /etc/security/pwquality.conf