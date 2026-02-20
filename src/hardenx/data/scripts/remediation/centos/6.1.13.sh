#!/usr/bin/env bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

login_time="$1"
config_file="/etc/ssh/sshd_config"

if [[ $EUID -ne 0 ]] || [[ ! -f "$config_file" ]]; then
   echo "false"
   exit 1
fi

temp_file=$(mktemp)
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

trap 'rm -f "$temp_file"' EXIT

if grep -qE '^\s*#?\s*LoginGraceTime\s+' "$config_file"; then
    sed -E "s/^\s*#?\s*LoginGraceTime\s+.*/LoginGraceTime ${login_time}/" "$config_file" > "$temp_file"
else
    cp "$config_file" "$temp_file"
    echo -e "\nLoginGraceTime ${login_time}" >> "$temp_file"
fi

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

chown --reference="$config_file" "$temp_file"
chmod --reference="$config_file" "$temp_file"

if ! mv "$temp_file" "$config_file"; then
    echo "false"
    exit 1
fi

trap - EXIT

restart_cmd=""
if command -v systemctl &>/dev/null; then
    restart_cmd="systemctl restart sshd"
elif command -v service &>/dev/null; then
    restart_cmd="service sshd restart"
else
    echo "false"
    exit 1
fi

if ${restart_cmd} &>/dev/null; then
    echo "true"
else
    echo "false"
fi