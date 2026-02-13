#!/bin/bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

permissions="$1"
success=true

shopt -s nullglob
files=(/etc/ssh/ssh_host_*.pub)
shopt -u nullglob

# If no files are found, the loop is skipped and the script succeeds.
# If files are found, the loop will run.

for file in "${files[@]}"; do
    if ! chmod "$permissions" "$file" 2>/dev/null; then
        success=false
        break
    fi
done

echo "$success"