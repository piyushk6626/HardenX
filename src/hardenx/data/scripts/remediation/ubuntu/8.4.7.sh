#!/usr/bin/env bash

set -euo pipefail

RULE_FILE="/etc/audit/rules.d/99-file-access-failures.rules"
ACTION="${1:-}"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    false
    exit 1
fi

if [[ "${ACTION}" != "enabled" && "${ACTION}" != "disabled" ]]; then
    echo "Usage: $0 <enabled|disabled>" >&2
    false
    exit 1
fi

reload_rules() {
    if ! augenrules --load >/dev/null 2>&1; then
        echo "Error: Failed to reload auditd rules." >&2
        return 1
    fi
    return 0
}

enable_rules() {
    cat > "${RULE_FILE}" <<'EOF'
# Log unsuccessful file access attempts (EACCES & EPERM)
-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat -F exit=-EACCES -k file_access_failure
-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat -F exit=-EACCES -k file_access_failure
-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat -F exit=-EPERM -k file_access_failure
-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat -F exit=-EPERM -k file_access_failure
EOF
    if ! reload_rules; then
        rm -f "${RULE_FILE}"
        return 1
    fi
    return 0
}

disable_rules() {
    rm -f "${RULE_FILE}"
    reload_rules
}

case "${ACTION}" in
    enabled)
        if enable_rules; then
            true
        else
            false
        fi
        ;;
    disabled)
        if disable_rules; then
            true
        else
            false
        fi
        ;;
esac