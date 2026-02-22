#!/usr/bin/env bash

exit_status=0

while IFS= read -r username; do
    # Skip empty lines, just in case
    [[ -z "$username" ]] && continue

    if ! passwd -l "$username" &>/dev/null; then
        exit_status=1
    fi
done < <(awk -F: '$2 == "" {print $1}' /etc/shadow)

exit "$exit_status"