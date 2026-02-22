#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

MODE="$1"
AUDIT_BINARIES=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/audispd"
    "/sbin/augenrules"
)

for bin in "${AUDIT_BINARIES[@]}"; do
    # Attempt chmod and check its exit status immediately.
    # Suppress stderr to ensure only "true" or "false" is printed.
    chmod "${MODE}" "${bin}" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
done

echo "true"
exit 0