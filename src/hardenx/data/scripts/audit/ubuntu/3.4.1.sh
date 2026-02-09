#!/bin/bash

CONF_FILE="/etc/systemd/timesyncd.conf"

if [[ ! -f "$CONF_FILE" ]]; then
    exit 0
fi

awk '/^NTP=/ {
    sub(/^NTP=/, "");
    sub(/^[[:space:]]*/, "");
    sub(/[[:space:]]*$/, "");
    print;
    exit
}' "$CONF_FILE"