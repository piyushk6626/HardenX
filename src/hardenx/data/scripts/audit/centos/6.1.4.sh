#!/usr/bin/env bash

if grep -Eq '^[[:space:]]*(AllowUsers|AllowGroups|DenyUsers|DenyGroups)[[:space:]]+' /etc/ssh/sshd_config 2>/dev/null; then
    echo "Configured"
else
    echo "Not Configured"
fi