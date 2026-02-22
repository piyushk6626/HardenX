#!/usr/bin/env bash

if [[ "$#" -ne 1 || "$1" != "Present" ]]; then
    echo "false"
    exit 1
fi

RULE_FILE="/etc/audit/rules.d/99-login-session.rules"
RULES_CONTENT=$(cat <<EOF
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins
-w /var/log/lastlog -p wa -k logins
EOF
)

# Write rules to the file. This requires appropriate permissions.
# The `tee` command is used to write the content, which might be run with sudo.
echo "${RULES_CONTENT}" > "${RULE_FILE}"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Ensure the rules are loaded into the running kernel configuration
augenrules --load >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

echo "true"
exit 0