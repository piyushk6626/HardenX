#!/usr/bin/env bash

set -e

CONF_FILE="/etc/sudoers.d/99-use_pty_setting"
ACTION="$1"

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root." >&2
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 {enabled|disabled}" >&2
    exit 1
fi

case "$ACTION" in
    enabled)
        (echo "Defaults use_pty" > "$CONF_FILE" && chmod 0440 "$CONF_FILE") || false
        ;;
    disabled)
        rm -f "$CONF_FILE" || false
        ;;
    *)
        echo "Error: Invalid argument '$ACTION'. Use 'enabled' or 'disabled'." >&2
        false
        ;;
esac