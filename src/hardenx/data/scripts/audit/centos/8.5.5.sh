#!/usr/bin/env bash

TARGET_DIR="/etc/audit/"

if ! [[ -d "$TARGET_DIR" && -r "$TARGET_DIR" ]]; then
    echo "{}"
    exit 0
fi

json_entries=()

while IFS= read -r -d '' file; do
    perms=$(stat -c "%a" "$file" 2>/dev/null)
    if [[ -n "$perms" ]]; then
        json_key="\"$file\""
        json_value="\"$perms\""
        json_entries+=("${json_key}:${json_value}")
    fi
done < <(find "$TARGET_DIR" -type f -print0 2>/dev/null)

if [ ${#json_entries[@]} -eq 0 ]; then
    echo "{}"
else
    json_output=$(IFS=,; echo "${json_entries[*]}")
    echo "{${json_output}}"
fi