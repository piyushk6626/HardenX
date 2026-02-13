#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]] || { [[ "$1" != "yes" && "$1" != "no" ]]; }; then
    echo "false"
    exit 1
fi

VALUE="$1"
CONF_FILE="/etc/systemd/journald.conf"
SETTING="ForwardToSyslog"
SECTION_HEADER="\[Journal\]"

if [[ ! -f "$CONF_FILE" ]]; then
    touch "$CONF_FILE"
fi

if ! grep -q "^${SECTION_HEADER}" "$CONF_FILE"; then
    if ! (echo -e "\n[Journal]" >> "$CONF_FILE"); then
        echo "false"
        exit 1
    fi
fi

if grep -q -E "^#?${SETTING}=" "$CONF_FILE"; then
    if ! sed -i -E "s/^#?${SETTING}=.*/${SETTING}=${VALUE}/" "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
else
    if ! sed -i "/^${SECTION_HEADER}/a ${SETTING}=${VALUE}" "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
fi

if ! systemctl restart systemd-journald &> /dev/null; then
    echo "false"
    exit 1
fi

echo "true"