#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 || "$1" != "compliant" ]]; then
    echo "false"
    exit 1
fi

if ! getent group nogroup &>/dev/null; then
    echo "false"
    exit 1
fi

valid_gids=$(cut -d: -f3 /etc/group | sort -u)

while IFS=: read -r username _ _ gid _; do
    if ! echo "${valid_gids}" | grep -qx "${gid}"; then
        if ! usermod -g nogroup "${username}"; then
            echo "false"
            exit 1
        fi
    fi
done < <(getent passwd)

echo "true"
exit 0