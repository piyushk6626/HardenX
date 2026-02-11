#!/usr/bin/env bash

# This script checks for the presence of four specific auditd rules for execve
# related to setuid/setgid privilege escalation.

RULES_DIR="/etc/audit/rules.d"
RULES_FILES="${RULES_DIR}/*.rules"

# Exit with "absent" if the directory doesn't exist or is empty
if ! [ -d "${RULES_DIR}" ] || ! ls ${RULES_FILES} &>/dev/null; then
    echo "absent"
    exit 0
fi

# Use awk to find lines that contain all required components for each rule.
# This is more robust against variations in argument order than a simple grep.

# Check for b64 setuid rule
found_b64_setuid=$(awk '/-a\s+(always,exit|exit,always)/ && /-F\s+arch=b64/ && /-S\s+execve/ && /-C\s+uid!=euid/ && /-F\s+euid=0/' ${RULES_FILES} 2>/dev/null)

# Check for b32 setuid rule
found_b32_setuid=$(awk '/-a\s+(always,exit|exit,always)/ && /-F\s+arch=b32/ && /-S\s+execve/ && /-C\s+uid!=euid/ && /-F\s+euid=0/' ${RULES_FILES} 2>/dev/null)

# Check for b64 setgid rule
found_b64_setgid=$(awk '/-a\s+(always,exit|exit,always)/ && /-F\s+arch=b64/ && /-S\s+execve/ && /-C\s+gid!=egid/ && /-F\s+egid=0/' ${RULES_FILES} 2>/dev/null)

# Check for b32 setgid rule
found_b32_setgid=$(awk '/-a\s+(always,exit|exit,always)/ && /-F\s+arch=b32/ && /-S\s+execve/ && /-C\s+gid!=egid/ && /-F\s+egid=0/' ${RULES_FILES} 2>/dev/null)

if [ -n "${found_b64_setuid}" ] && \
   [ -n "${found_b32_setuid}" ] && \
   [ -n "${found_b64_setgid}" ] && \
   [ -n "${found_b32_setgid}" ]; then
    echo "present"
else
    echo "absent"
fi