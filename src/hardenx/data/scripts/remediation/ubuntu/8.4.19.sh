#!/bin/bash

if [[ $# -ne 1 ]] || [[ "$1" != "Present" ]]; then
    echo "false"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

RULES_FILE="/etc/audit/rules.d/kernel_modules.rules"

# Create the rule file. If this fails, exit.
cat <<'EOF' > "${RULES_FILE}" || { echo "false"; exit 1; }
-a always,exit -F arch=b64 -S init_module -S finit_module -S delete_module -S create_module -k kernel_modules
-a always,exit -F arch=b32 -S init_module -S finit_module -S delete_module -S create_module -k kernel_modules
-w /sbin/insmod -p x -k kernel_modules
-w /sbin/rmmod -p x -k kernel_modules
-w /sbin/modprobe -p x -k kernel_modules
EOF

# Load the new rules. If this fails, remove the created file and exit.
if ! augenrules --load &>/dev/null; then
    rm -f "${RULES_FILE}"
    echo "false"
    exit 1
fi

echo "true"
exit 0