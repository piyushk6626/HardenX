#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
KEY="kernel.randomize_va_space"
CONF_FILE="/etc/sysctl.d/99-custom-randomize-va-space.conf"

if ! [[ "$VALUE" =~ ^[0-2]$ ]]; then
    if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
      echo "false"
      exit 1
    fi
fi

if ! sysctl -w "${KEY}=${VALUE}" &>/dev/null; then
    echo "false"
    exit 1
fi

if ! mkdir -p "$(dirname "${CONF_FILE}")"; then
    echo "false"
    exit 1
fi

if grep -qs "^\\s*${KEY}" "${CONF_FILE}"; then
    if ! sed -i "s|^\\s*${KEY}.*|${KEY} = ${VALUE}|" "${CONF_FILE}"; then
        echo "false"
        exit 1
    fi
else
    if ! echo "${KEY} = ${VALUE}" >> "${CONF_FILE}"; then
        echo "false"
        exit 1
    fi
fi

echo "true"