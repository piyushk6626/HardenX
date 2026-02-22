#!/usr/bin/env bash

# This script must be run as root.
if [[ "${EUID}" -ne 0 ]]; then
    echo "Error: This script requires root privileges." >&2
    false
    exit 1
fi

# Validate command-line arguments.
if [[ "$#" -ne 1 ]] || [[ "$1" != "enabled" ]]; then
    echo "Usage: $0 enabled" >&2
    false
    exit 1
fi

# Define the path for the new rules file.
RULES_FILE="/etc/audit/rules.d/99-dac-permissions.rules"

# Define the audit rules using a here-document.
# These rules watch for DAC modifications by any user with an audit UID >= 1000.
# The `auid!=-1` or `auid!=4294967295` condition filters out system processes without a login UID.
read -r -d '' AUDIT_RULES <<'EOF'
## Log DAC permission modification events (chmod, chown, setxattr).
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S fsetxattr -S lsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S fsetxattr -S lsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
EOF

# Write the rules to the specified file. Using printf is safer.
if ! printf "%s\n" "${AUDIT_RULES}" > "${RULES_FILE}"; then
    echo "Error: Failed to write to ${RULES_FILE}" >&2
    false
    exit 1
fi

# Load the audit rules from the /etc/audit/rules.d/ directory.
# This compiles all .rules files into /etc/audit/audit.rules and signals the daemon.
if ! augenrules --load > /dev/null; then
    echo "Error: augenrules command failed to load new rules." >&2
    # Clean up the created file on failure to maintain a clean state.
    rm -f "${RULES_FILE}"
    false
    exit 1
fi

# Return true on success.
true