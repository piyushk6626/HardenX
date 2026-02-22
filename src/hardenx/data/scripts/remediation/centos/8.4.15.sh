#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    exit 1
fi

ACTION="$1"
RULE_FILE="/etc/audit/rules.d/chcon-exec.rules"

case "$ACTION" in
    Present)
        if ! cat <<EOF > "$RULE_FILE"; then
-a always,exit -F arch=b64 -S execve -F path=/usr/bin/chcon -F auid>=1000 -F auid!=unset -k chcon_executions
-a always,exit -F arch=b32 -S execve -F path=/usr/bin/chcon -F auid>=1000 -F auid!=unset -k chcon_executions
EOF
            exit 1
        fi

        if augenrules --load; then
            exit 0
        else
            rm -f "$RULE_FILE"
            exit 1
        fi
        ;;

    Absent)
        if [[ -f "$RULE_FILE" ]]; then
            if ! rm -f "$RULE_FILE"; then
                exit 1
            fi
        fi

        if augenrules --load; then
            exit 0
        else
            exit 1
        fi
        ;;

    *)
        exit 1
        ;;
esac