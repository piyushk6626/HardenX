#!/usr/bin/env bash

if grep -qE '^\s*(AllowUsers|DenyUsers|AllowGroups|DenyGroups)\s+.+' /etc/ssh/sshd_config; then
    echo 'Configured'
else
    echo 'Not Configured'
fi