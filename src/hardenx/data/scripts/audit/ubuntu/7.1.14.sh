#!/usr/bin/env bash

declare -a problem_users

MIN_UID=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs 2>/dev/null)
: "${MIN_UID:=1000}"

while IFS=: read -r user _ uid _ _ _ shell; do
    if [[ "$uid" -lt "$MIN_UID" ]]; then
        continue
    fi

    if ! grep -Fxq "$shell" /etc/shells; then
        password_hash=$(getent shadow "$user" 2>/dev/null | cut -d: -f2)
        if [[ -n "$password_hash" && "$password_hash" != '!'* && "$password_hash" != '*' ]]; then
            problem_users+=("$user")
        fi
    fi
done < /etc/passwd

echo "${problem_users[*]}"