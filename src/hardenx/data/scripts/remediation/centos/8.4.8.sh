#!/bin/bash

if [[ "$1" != "Present" ]]; then
    echo "false"
    exit 1
fi

RULE_FILE="/etc/audit/rules.d/identity.rules"

# Use a 'here document' to write the rules to the file.
# The redirection will fail if the script is not run with sufficient privileges.
if ! cat > "$RULE_FILE" <<EOF
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
EOF
then
    echo "false"
    exit 1
fi

# Reload audit rules. This will also fail without sufficient privileges.
if ! augenrules --load; then
    # Attempt to clean up the file we created on failure
    rm -f "$RULE_FILE" &>/dev/null
    echo "false"
    exit 1
fi

echo "true"
exit 0