#!/usr/bin/env bash

CONF_FILE="/etc/systemd/journald.conf"
DIRECTIVE="SystemMaxUse"

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

MAX_SIZE="$1"
DESIRED_LINE="${DIRECTIVE}=${MAX_SIZE}M"

# Ensure the config file exists and is writable
if [[ ! -f "$CONF_FILE" ]] || [[ ! -w "$CONF_FILE" ]]; then
    # If it doesn't exist, create it (as it's a valid systemd behavior)
    if ! touch "$CONF_FILE" 2>/dev/null; then
        echo "false"
        exit 1
    fi
fi

# If the directive exists (commented or uncommented), replace it.
if grep -q -E "^#?${DIRECTIVE}=" "$CONF_FILE"; then
    sed -i -E "s/^#?${DIRECTIVE}=.*/${DESIRED_LINE}/" "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
# If the directive does not exist, add it.
else
    # If [Journal] section exists, add it there.
    if grep -q -E "^\[Journal\]" "$CONF_FILE"; then
        sed -i "/^\[Journal\]/a ${DESIRED_LINE}" "$CONF_FILE"
        if [[ $? -ne 0 ]]; then
            echo "false"
            exit 1
        fi
    # If [Journal] section doesn't exist, add both.
    else
        echo -e "\n[Journal]\n${DESIRED_LINE}" >> "$CONF_FILE"
        if [[ $? -ne 0 ]]; then
            echo "false"
            exit 1
        fi
    fi
fi

# Reload and restart the service
if ! systemctl restart systemd-journald &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"
exit 0