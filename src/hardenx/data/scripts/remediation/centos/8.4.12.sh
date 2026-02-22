#!/usr/bin/env bash

if [[ "$1" != "Present" ]]; then
    echo "false"
    exit 1
fi

RULES_FILE="/etc/audit/rules.d/logins.rules"

# Write the rules to the file.
# The command substitution and pipe are used to ensure that if the write
# operation fails, the script will not proceed.
cat > "$RULES_FILE" <<EOF
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins
EOF

# Check if the file was written successfully before proceeding
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Load the new rules. The output is redirected to /dev/null.
if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
fi