#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

declare -A defined_gids
error_occurred=0

while IFS=: read -r _ _ gid _; do
    [[ -n "$gid" ]] && defined_gids["$gid"]=1
done < /etc/group

while IFS=: read -r username _ uid gid _ _ _; do
    if (( uid >= 1000 )); then
        if [[ ! -v defined_gids[$gid] ]]; then
            if ! userdel -r "$username" &>/dev/null; then
                error_occurred=1
            fi
        fi
    fi
done < /etc/passwd

if [[ $error_occurred -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi