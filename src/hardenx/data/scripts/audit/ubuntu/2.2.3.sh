#!/usr/bin/env bash

if grep -qsE "^\*\s+hard\s+core\s+0\s*$" /etc/security/limits.conf /etc/security/limits.d/*.conf 2>/dev/null && \
   [[ "$(sysctl -n fs.suid_dumpable 2>/dev/null)" == "0" ]]; then
    echo "Enabled"
else
    echo "Disabled"
fi