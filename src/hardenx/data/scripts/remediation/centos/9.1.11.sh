#!/usr/bin/env bash

error_occurred=0

# Use Process Substitution to pipe find's output to the while loop
# without creating a subshell for the loop itself. This ensures the
# error_occurred variable is modified in the main script scope.
#
# find arguments:
#   /         : Start search from the root directory.
#   -xdev     : Don't descend into directories on other filesystems.
#   -perm -o=w: Find items where the 'others' permission includes 'write'.
#   -print0   : Print the full file name on the standard output, followed
#               by a null character. This handles all possible filenames.
#
# read arguments:
#   -r        : Do not allow backslashes to escape any characters.
#   -d ''     : Read until the first NUL character.
#
# We redirect find's stderr to /dev/null to suppress "Permission denied"
# errors for directories the script can't read, allowing it to continue
# processing the directories it can.
while IFS= read -r -d '' file_path; do
    # Attempt to remove the world-writable permission.
    if ! chmod o-w "${file_path}"; then
        # If chmod fails for any reason, set the error flag.
        # We also print a message to stderr for diagnostics, which does not
        # interfere with the required stdout of 'true' or 'false'.
        echo "Error: Failed to change permissions on '${file_path}'" >&2
        error_occurred=1
    fi
done < <(find / -xdev -perm -o=w -print0 2>/dev/null)

if [[ ${error_occurred} -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi