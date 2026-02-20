#!/bin/bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]] || [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

readonly TIMEOUT_VALUE="$1"
readonly TARGET_FILE="/etc/profile.d/autologout.sh"

if (printf "export TMOUT=%s\n" "$TIMEOUT_VALUE" > "$TARGET_FILE" && chmod 0644 "$TARGET_FILE"); then
    echo "true"
else
    echo "false"
fi