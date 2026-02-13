#!/usr/bin/env bash

RULE_FILE="/etc/audit/rules.d/99-mounts.rules"
ACTION="$1"

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

perform_action() {
    case "$ACTION" in
        Enabled)
            cat > "$RULE_FILE" <<EOF
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=unset -k mounts
EOF
            ;;
        Disabled)
            rm -f "$RULE_FILE"
            ;;
        *)
            return 1
            ;;
    esac
}

if ! perform_action; then
    echo "false"
    exit 1
fi

if ! augenrules --load &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"
exit 0