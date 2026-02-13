#!/bin/bash

LOGIN_DEFS="/etc/login.defs"
SETTING_KEY="ENCRYPT_METHOD"

if [[ $# -ne 1 || -z "$1" ]]; then
    false
    exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
    false
    exit 1
fi

if [[ ! -w "${LOGIN_DEFS}" ]]; then
    false
    exit 1
fi

ALGORITHM="$1"

# Check if the key already exists (ignoring commented out lines)
if grep -qE "^\s*${SETTING_KEY}\s+" "${LOGIN_DEFS}"; then
    # Key exists, so we replace the value. Using a different delimiter for sed.
    sed -i "s|^\(\s*${SETTING_KEY}\s\+\).*|\1${ALGORITHM}|" "${LOGIN_DEFS}"
    RC=$?
else
    # Key does not exist, append it. Add a newline for safety.
    echo -e "\n${SETTING_KEY} ${ALGORITHM}" >> "${LOGIN_DEFS}"
    RC=$?
fi

if [[ ${RC} -eq 0 ]]; then
    true
else
    false
fi