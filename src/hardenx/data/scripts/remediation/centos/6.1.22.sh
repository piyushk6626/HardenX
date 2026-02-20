#!/usr/bin/env bash

fail() {
    echo "false"
    exit 1
}

if [[ $# -ne 1 || ("$1" != "yes" && "$1" != "no") ]]; then
    fail
fi

pam_setting="$1"
ssh_config_file="/etc/ssh/sshd_config"

if [[ "$(id -u)" -ne 0 ]]; then
    fail
fi

if [[ ! -f "$ssh_config_file" ]]; then
    fail
fi

if grep -qE '^[[:space:]]*#?[[:space:]]*UsePAM' "$ssh_config_file"; then
    sed -i -E "s/^[[:space:]]*#?[[:space:]]*UsePAM.*/UsePAM ${pam_setting}/" "$ssh_config_file" || fail
else
    echo "" >> "$ssh_config_file" || fail
    echo "UsePAM ${pam_setting}" >> "$ssh_config_file" || fail
fi

systemctl restart sshd &>/dev/null || fail

echo "true"
exit 0