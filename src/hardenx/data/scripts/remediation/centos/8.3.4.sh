#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
    false
    exit 1
fi

new_value="$1"
config_file="/etc/audit/auditd.conf"
setting="space_left_action"

if [[ ! -f "$config_file" ]] || [[ ! -w "$config_file" ]]; then
    false
    exit 1
fi

if grep -qE "^\s*${setting}\s*=" "$config_file"; then
    sed -i "s/^\s*${setting}\s*=.*/${setting} = ${new_value}/" "$config_file"
    if [[ $? -ne 0 ]]; then
        false
        exit 1
    fi
else
    # Ensure a newline exists before appending, if the file is not empty
    if [[ -s "$config_file" ]] && [[ "$(tail -c1 "$config_file"; echo x)" != $'\nx' ]]; then
        echo "" >> "$config_file"
    fi
    echo "${setting} = ${new_value}" >> "$config_file"
    if [[ $? -ne 0 ]]; then
        false
        exit 1
    fi
fi

true