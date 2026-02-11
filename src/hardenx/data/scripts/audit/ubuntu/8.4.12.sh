#!/usr/bin/env bash

# This script must be run with sufficient privileges to execute auditctl

set -o pipefail

rules_list=$(auditctl -l 2>/dev/null)

if [ -z "${rules_list}" ]; then
    echo "false"
    exit 0
fi

check_rule() {
    local file_path=$1
    echo "${rules_list}" | grep -- "${file_path}" | grep -q -- "-p wa"
}

if check_rule "/var/log/faillog" && \
   check_rule "/var/log/lastlog" && \
   check_rule "/var/log/tallylog"; then
    echo "true"
else
    echo "false"
fi