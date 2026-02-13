#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ "$#" -ne 1 ]] || ! [[ "$1" == "yes" || "$1" == "no" ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
SETTING="HostbasedAuthentication"
VALUE="$1"

if ! [ -w "${CONFIG_FILE}" ]; then
    echo "false"
    exit 1
fi

if grep -qE "^\s*#?\s*${SETTING}" "${CONFIG_FILE}"; then
    sed -i -E "s/^\s*#?\s*${SETTING}.*/${SETTING} ${VALUE}/" "${CONFIG_FILE}"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    echo "${SETTING} ${VALUE}" >> "${CONFIG_FILE}"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

if command -v systemctl &> /dev/null; then
    systemctl restart sshd &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "true"
        exit 0
    fi
elif command -v service &> /dev/null; then
    service sshd restart &> /dev/null || service ssh restart &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "true"
        exit 0
    fi
fi

echo "false"
exit 1