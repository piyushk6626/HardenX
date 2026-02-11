#!/bin/bash

AUDIT_RULES_DIR="/etc/audit/rules.d"

if [ ! -d "$AUDIT_RULES_DIR" ]; then
    echo "Not Applicable"
    exit 0
fi

# Check if the directory is empty of any files
if ! find "$AUDIT_RULES_DIR" -maxdepth 1 -type f -print -quit | grep -q .; then
    echo "Not Applicable"
    exit 0
fi

for file in "$AUDIT_RULES_DIR"/*; do
    if [ -f "$file" ]; then
        group_owner=$(stat -c "%G" "$file")
        if [ "$group_owner" != "root" ]; then
            echo "$group_owner"
            exit 0
        fi
    fi
done

echo "root"
exit 0