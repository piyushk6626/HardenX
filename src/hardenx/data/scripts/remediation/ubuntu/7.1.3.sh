#!/bin/bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]] || [[ "$EUID" -ne 0 ]]; then
    exit 1
fi

LOGIN_DEFS="/etc/login.defs"
PARAM="PASS_WARN_AGE"
VALUE="$1"

if [[ ! -f "$LOGIN_DEFS" ]] || [[ ! -w "$LOGIN_DEFS" ]]; then
    exit 1
fi

if grep -qE "^\s*#?\s*${PARAM}\s+" "$LOGIN_DEFS"; then
    sed -i -E "s/^\s*#?\s*${PARAM}\s+.*/${PARAM}\t${VALUE}/" "$LOGIN_DEFS"
else
    echo -e "${PARAM}\t${VALUE}" >> "$LOGIN_DEFS"
fi

exit $?