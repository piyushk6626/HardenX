#!/bin/bash

rules=$(auditctl -l 2>/dev/null)

files_to_check=(
    "/etc/group"
    "/etc/passwd"
    "/etc/gshadow"
    "/etc/shadow"
    "/etc/security/opasswd"
)

for file in "${files_to_check[@]}"; do
    if ! echo "$rules" | grep -q -- "-w ${file}" | grep -q -- "-k identity"; then
        echo "Absent"
        exit 0
    fi
done

echo "Present"
exit 0