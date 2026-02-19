#!/usr/bin/env bash

files_to_check=(
    "/var/run/utmp"
    "/var/log/wtmp"
    "/var/log/btmp"
    "/var/log/lastlog"
)

all_present=1
loaded_rules=$(auditctl -l 2>/dev/null)

if [ -z "$loaded_rules" ]; then
    all_present=0
fi

if [[ $all_present -eq 1 ]]; then
    for file in "${files_to_check[@]}"; do
        if ! echo "$loaded_rules" | grep -q -E -- "-w ${file} .* -p wa"; then
            all_present=0
            break
        fi
    done
fi

if [[ $all_present -eq 1 ]]; then
    echo "Present"
else
    echo "Absent"
fi