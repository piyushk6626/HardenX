#!/bin/bash

fail() {
    echo "false"
    exit 1
}

if [[ $# -ne 1 ]]; then
    fail
fi

STATE="$1"
RULE_FILE="/etc/audit/rules.d/50-privileged.rules"
RULES=(
    "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0"
    "-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0"
    "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0"
    "-a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0"
)

if [[ "$STATE" != "present" ]]; then
    fail
fi

if [[ $EUID -ne 0 ]]; then
   fail
fi

if ! command -v augenrules &> /dev/null; then
    fail
fi

mkdir -p "$(dirname "$RULE_FILE")" || fail
touch "$RULE_FILE" || fail

for rule in "${RULES[@]}"; do
    if ! grep -qFx -- "$rule" "$RULE_FILE"; then
        echo "$rule" >> "$RULE_FILE" || fail
    fi
done

if augenrules --load &>/dev/null; then
    echo "true"
else
    fail
fi