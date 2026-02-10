#!/usr/bin/env bash

logfile_path=$(sudo grep -rE '^\s*Defaults\s+logfile=' /etc/sudoers /etc/sudoers.d/ 2>/dev/null | tail -n 1 | awk -F'=' '{print $2}' | xargs)

if [[ -n "$logfile_path" ]]; then
    echo "$logfile_path"
else
    echo "Not configured"
fi