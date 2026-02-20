#!/usr/bin/env bash

set -eo pipefail

today_days=$(($(date +%s) / 86400))

getent shadow | cut -d: -f1,3 | while IFS=: read -r user last_change_days; do
    if [[ -z "$last_change_days" || ! "$last_change_days" =~ ^[0-9]+$ ]]; then
        continue
    fi

    if (( last_change_days > today_days )); then
        chage -d today "$user"
    fi
done