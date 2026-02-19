#!/usr/bin/env bash

if [[ "$(sysctl -n fs.suid_dumpable 2>/dev/null)" == "0" ]] && \
   grep -Eq '^\s*\*\s+hard\s+core\s+0\s*($|#)' /etc/security/limits.conf /etc/security/limits.d/* 2>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi