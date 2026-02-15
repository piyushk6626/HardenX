#!/usr/bin/env bash

# This script manages CIS-recommended auditd rules for time changes.
# It must be run as root.

RULES_FILE="/etc/audit/rules.d/cis_time_change.rules"
ACTION="$1"

fail() {
    echo "false"
    exit 1
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   fail
fi

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 [Enabled|Disabled]" >&2
    fail
fi

case "$ACTION" in
    Enabled)
        (
        cat > "$RULES_FILE" <<'EOF'
# CIS 4.1.4: Ensure events that modify date and time information are collected
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -k time-change
-w /etc/localtime -p wa -k time-change
EOF
        ) || fail

        # Reload auditd rules. The command may produce output which we suppress.
        augenrules --load >/dev/null 2>&1 || fail
        ;;

    Disabled)
        if [[ -f "$RULES_FILE" ]]; then
            rm -f "$RULES_FILE" || fail
        fi

        # Reload auditd rules.
        augenrules --load >/dev/null 2>&1 || fail
        ;;

    *)
        echo "Invalid argument: Must be 'Enabled' or 'Disabled'." >&2
        fail
        ;;
esac

echo "true"
exit 0