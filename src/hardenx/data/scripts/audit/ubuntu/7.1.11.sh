#!/usr/bin/env bash

# Condition 1: Check for current directory '.' or empty directory fields.
# An empty field is represented by '::', a leading ':', or a trailing ':'.
if [[ "$PATH" =~ (^|:)\.(:|$) || "$PATH" =~ (^|:)(:|$) ]]; then
    echo "Insecure"
    exit 0
fi

# Save original Internal Field Separator
OIFS=$IFS
IFS=:

# Condition 2: Check if any directory in the PATH is group or world-writable.
for dir in $PATH; do
    # Path components can be empty if PATH starts/ends with ':', already caught above.
    # We only process actual, existing directories.
    if [ -d "$dir" ]; then
        # Check for group or world writability using stat's octal output.
        # stat -c %a gives permissions like 755.
        # We test the second digit (group) and third digit (other).
        # A value of 2, 3, 6, or 7 means write permission is set.
        perms=$(stat -c %a "$dir")
        group_perm=${perms:1:1}
        other_perm=${perms:2:1}

        if [[ "$group_perm" =~ [2367] || "$other_perm" =~ [2367] ]]; then
            echo "Insecure"
            IFS=$OIFS
            exit 0
        fi
    fi
done

# Restore original IFS
IFS=$OIFS

# If both conditions pass, the PATH is secure.
echo "Secure"