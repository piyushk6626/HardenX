#!/usr/bin/env bash

# Function to safely process and modify a sudoers file
process_file() {
    local file_path="$1"
    local temp_file

    # Per visudo, files with '.' or ending in '~' are ignored.
    # Also skip directories or anything that's not a regular file.
    if [[ ! -f "$file_path" || "$file_path" == *.* || "$file_path" == *~ ]]; then
        return 0
    fi

    # Create a temporary file for editing
    temp_file=$(mktemp)
    if [[ ! -f "$temp_file" ]]; then
        return 1 # Failed to create temp file
    fi

    # Ensure the temporary file is removed on function exit
    trap 'rm -f "$temp_file"' RETURN

    # Use sed to remove any instance of NOPASSWD:, along with preceding whitespace.
    # This correctly handles the syntax `... <TAGS> NOPASSWD: <command>`
    sed -E 's/[[:space:]]+NOPASSWD://g' "$file_path" > "$temp_file"

    # Validate the syntax of the modified temporary file before proceeding
    if ! visudo -cf "$temp_file" &>/dev/null; then
        return 1 # Syntax check failed
    fi

    # If syntax is valid, use install to safely replace the original file
    # while setting the correct permissions and ownership.
    if ! install -o root -g root -m 0440 "$temp_file" "$file_path"; then
        return 1 # Failed to replace the original file
    fi

    return 0
}

# Main script execution
# ---

# Must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Validate the required positional argument
if [[ $# -ne 1 || "$1" != "Enabled" ]]; then
    echo "false"
    exit 1
fi

# Process the main sudoers file
if ! process_file "/etc/sudoers"; then
    echo "false"
    exit 1
fi

# Process all files in the sudoers.d directory, if it exists
if [[ -d "/etc/sudoers.d" ]]; then
    for sudo_file in /etc/sudoers.d/*; do
        if ! process_file "$sudo_file"; then
            echo "false"
            exit 1
        fi
    done
fi

# If all files were processed successfully
echo "true"
exit 0