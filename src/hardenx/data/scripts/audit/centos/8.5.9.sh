#!/bin/bash

files_to_check=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/audispd"
    "/sbin/augenrules"
)

for file_path in "${files_to_check[@]}"; do
    if [ -e "$file_path" ]; then
        owner=$(stat -c '%U' "$file_path")
        if [ "$owner" != "root" ]; then
            echo "$owner"
            exit 0
        fi
    fi
done

echo "root"