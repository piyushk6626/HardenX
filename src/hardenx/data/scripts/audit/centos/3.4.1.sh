#!/usr/bin/env bash

awk -F'=' '/^[[:space:]]*(NTP|FallbackNTP)=/ {
    val=$2;
    sub(/^[[:space:]]+/, "", val);
    sub(/[[:space:]]+$/, "", val);
    if (val) {
        servers=(servers ? servers " " : "") val
    }
}
END {
    if (servers) {
        print servers
    }
}' /etc/systemd/timesyncd.conf 2>/dev/null