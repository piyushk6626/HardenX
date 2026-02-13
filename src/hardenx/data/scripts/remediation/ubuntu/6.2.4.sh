#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
# The trap will be executed on ERR or EXIT.
set -e
trap 'echo "false"' ERR

# Function to process a single file
process_file() {
    local file_path="$1"
    
    # Check if the file exists and is a regular file
    if [[ ! -f "$file_path" ]]; then
        return
    fi
    
    # Check for active (non-commented) NOPASSWD tag before attempting modification
    if grep -qE '^[[:space:]]*[^#].*\bNOPASSWD:' "$file_path"; then
        # Use visudo's safe editing mechanism. It creates a temp file, runs the
        # editor, checks syntax, and replaces the original file atomically.
        if ! EDITOR="sed -i -E '/^[[:space:]]*#/!s/\bNOPASSWD:[[:space:]]*//g'" visudo -qf "$file_path"; then
            # If visudo fails, it means the edit resulted in a syntax error.
            # The trap will handle printing "false".
            exit 1
        fi
    fi
}

# 1. Must be run as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# 2. Check for the specific 'Enabled' argument.
# If the argument is not 'Enabled', no action is required, which is a success case.
if [[ "$1" != "Enabled" ]]; then
    echo "true"
    exit 0
fi

# 3. Process /etc/sudoers
process_file "/etc/sudoers"

# 4. Process all files in /etc/sudoers.d
if [[ -d "/etc/sudoers.d" ]]; then
    # Use find with -print0 and a while loop to safely handle all filenames,
    # including those with spaces or special characters.
    while IFS= read -r -d '' file; do
        process_file "$file"
    done < <(find "/etc/sudoers.d" -type f -print0)
fi

# 5. If the script completes without error, it's a success.
echo "true"
exit 0