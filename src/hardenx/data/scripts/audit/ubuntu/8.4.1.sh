#!/bin/bash

rules_output=$(auditctl -l 2>/dev/null)

sudoers_rule_found=false
sudoers_d_rule_found=false

if echo "${rules_output}" | grep -q -- "-w /etc/sudoers -p wa"; then
    sudoers_rule_found=true
fi

if echo "${rules_output}" | grep -q -- "-w /etc/sudoers.d -p wa"; then
    sudoers_d_rule_found=true
fi

if [[ "$sudoers_rule_found" == true && "$sudoers_d_rule_found" == true ]]; then
    echo "Enabled"
else
    echo "Disabled"
fi