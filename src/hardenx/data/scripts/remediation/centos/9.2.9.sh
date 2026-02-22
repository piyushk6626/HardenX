#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ "$1" != "configure" ]]; then
    exit 1
fi

all_successful=true

while IFS=: read -r username _ uid _ gecos homedir shell; do
    if [[ "$uid" -lt 1000 ]]; then
        continue
    fi

    if [[ -z "$homedir" ]] || [[ -d "$homedir" ]]; then
        continue
    fi

    if ! grep -Fxq "$shell" /etc/shells &>/dev/null; then
        continue
    fi

    if ! mkhomedir_helper "$username"; then
        all_successful=false
        break
    fi

done < /etc/passwd

if [[ "$all_successful" == "true" ]]; then
    echo "true"
else
    echo "false"
fi