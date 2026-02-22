#!/usr/bin/env bash

if [[ "$1" != "Configured" ]]; then
    echo "false"
    exit 1
fi

RULES_FILE="/etc/audit/rules.d/50-system-locale.rules"

# Use a temporary file to safely write rules before moving
TMP_FILE=$(mktemp)
if [ $? -ne 0 ]; then
    echo "false"
    exit 1
fi

# Write rules to the temporary file
cat > "$TMP_FILE" << EOF
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale
EOF

# Move the temporary file to the final destination
mv "$TMP_FILE" "$RULES_FILE" &> /dev/null
if [ $? -ne 0 ]; then
    rm -f "$TMP_FILE"
    echo "false"
    exit 1
fi

# Set correct permissions
chmod 0640 "$RULES_FILE" &> /dev/null
if [ $? -ne 0 ]; then
    echo "false"
    exit 1
fi

# Regenerate master rule file and reload the service
if augenrules --load &> /dev/null && service auditd reload &> /dev/null; then
    echo "true"
else
    echo "false"
fi