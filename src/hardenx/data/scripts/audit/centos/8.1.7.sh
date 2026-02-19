#!/usr/bin/env bash

CONF_FILE="/etc/systemd/journald.conf"

if [[ ! -r "$CONF_FILE" ]]; then
    echo "yes"
    exit 0
fi

awk -F= '
/^\s*ForwardToSyslog\s*=/ {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
    val = $2
    found = 1
}
END {
    if (found) {
        print val
    } else {
        print "yes"
    }
}' "$CONF_FILE"