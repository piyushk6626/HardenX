#!/usr/bin/env bash

awk -F'=' '
/^[[:space:]]*SystemMaxUse=/ {
    # Trim leading/trailing whitespace from the value part ($2)
    gsub(/^[ \t]+|[ \t]+$/, "", $2);
    val = $2;

    # Check for Gigabytes suffix (case-insensitive)
    if (tolower(val) ~ /g$/) {
        sub(/[gG]$/, "", val);
        print val * 1024;
    }
    # Check for Megabytes suffix (case-insensitive)
    else if (tolower(val) ~ /m$/) {
        sub(/[mM]$/, "", val);
        print val;
    }
}' /etc/systemd/journald.conf