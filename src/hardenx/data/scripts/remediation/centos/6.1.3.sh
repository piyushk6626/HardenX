#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

PERMS=$1
TARGET_DIR="/etc/ssh"

# Use mapfile to read file list into an array. This is safer than simple command substitution.
# We check the exit code of the 'find' command within the process substitution.
mapfile -t files < <(find "$TARGET_DIR" -maxdepth 1 -type f -name "*.pub" 2>/dev/null)
if [ $? -ne 0 ]; then
    # This indicates 'find' itself failed, e.g., directory not found or no read permissions.
    echo "false"
    exit 1
fi

# If no files are found, the condition "successful for all files" is vacuously true.
if [ ${#files[@]} -eq 0 ]; then
    echo "true"
    exit 0
fi

# Loop through the array of found files.
for file in "${files[@]}"; do
    if ! chmod "$PERMS" "$file"; then
        # If any chmod command fails, the entire operation is a failure.
        echo "false"
        exit 1
    fi
done

# If the loop completes without any failures, the operation was successful.
echo "true"