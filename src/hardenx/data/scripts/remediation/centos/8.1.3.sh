#!/usr/bin/env bash

if [[ "$#" -ne 1 || -z "$1" ]]; then
    echo "false"
    exit 1
fi

MAX_SIZE="$1"
CONF_FILE="/etc/systemd/journald.conf"
SETTING="SystemMaxUse"

if [[ ! -f "$CONF_FILE" ]] || [[ ! -w "$CONF_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if the setting exists, commented or uncommented
if grep -qE "^[[:space:]]*#?[[:space:]]*${SETTING}=" "$CONF_FILE"; then
    # If it exists, replace it and ensure it's uncommented.
    sed -i -E "s/^[[:space:]]*#?[[:space:]]*${SETTING}=.*/${SETTING}=${MAX_SIZE}/" "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    # If it doesn't exist, add it under the [Journal] section.
    if grep -qE '^[[:space:]]*\[Journal\]' "$CONF_FILE"; then
        # If [Journal] section exists, add the setting after it.
        sed -i "/^[[:space:]]*\[Journal\]/a ${SETTING}=${MAX_SIZE}" "$CONF_FILE"
        if [[ $? -ne 0 ]]; then
            echo "false"
            exit 1
        fi
    else
        # If [Journal] section doesn't exist, add both the section and the setting.
        printf "\n[Journal]\n%s=%s\n" "$SETTING" "$MAX_SIZE" >> "$CONF_FILE"
        if [[ $? -ne 0 ]]; then
            echo "false"
            exit 1
        fi
    fi
fi

echo "true"
exit 0