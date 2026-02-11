#!/usr/bin/env bash

# An array of files that require write and attribute change watches.
files_to_check=(
    "/etc/group"
    "/etc/passwd"
    "/etc/gshadow"
    "/etc/shadow"
    "/etc/security/opasswd"
)

# Fetch the current ruleset from auditctl. Suppress errors if the daemon is not running or permissions are insufficient.
ruleset=$(auditctl -l 2>/dev/null)

# If auditctl fails or returns no rules, the required rules cannot be present.
if [[ -z "$ruleset" ]]; then
    echo "false"
    exit 0
fi

# Iterate over the list of files to check.
for file_path in "${files_to_check[@]}"; do
    # Use grep to check if a rule exists for the file with the correct permissions (-p wa).
    # The regex looks for "-w /path/to/file" followed by "-p wa".
    # We check for a space or end-of-line after the file path and permission to ensure an exact match.
    if ! echo "$ruleset" | grep -q -E -- "-w ${file_path}(\s|$).*-p wa(\s|$)"; then
        # If any rule is not found, output false and exit immediately.
        echo "false"
        exit 0
    fi
done

# If the script completes the loop, all rules were found.
echo "true"
exit 0