#!/usr/bin/env bash

RULES_FILE="/etc/audit/rules.d/user-group-modification.rules"

fail() {
    echo "false"
    exit 1
}

# Check for root privileges and correct argument count
if [[ $EUID -ne 0 ]] || [[ $# -ne 1 ]]; then
   fail
fi

ACTION="$1"

case "$ACTION" in
    enabled)
        # Create or overwrite the rules file with the specified content
        if ! cat > "$RULES_FILE" << EOF
-w /etc/group -p wa -k user-group-modification
-w /etc/passwd -p wa -k user-group-modification
-w /etc/gshadow -p wa -k user-group-modification
-w /etc/shadow -p wa -k user-group-modification
-w /etc/security/opasswd -p wa -k user-group-modification
EOF
        then
            fail
        fi
        ;;
    disabled)
        # Remove the rules file. rm -f does not fail if the file does not exist.
        if ! rm -f "$RULES_FILE"; then
            fail
        fi
        ;;
    *)
        # Handle invalid arguments
        fail
        ;;
esac

# Reload auditd rules from the /etc/audit/rules.d/ directory
if ! augenrules --load &>/dev/null; then
    fail
fi

# If all operations were successful
echo "true"
exit 0