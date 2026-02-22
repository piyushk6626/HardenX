#!/usr/bin/env bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

BACKLOG_LIMIT="$1"
RULES_FILE="/etc/audit/rules.d/audit.rules"
RULES_DIR=$(dirname "$RULES_FILE")

if ! mkdir -p "$RULES_DIR"; then
    echo "false"
    exit 1
fi

# The grep will fail if the file doesn't exist or the pattern isn't found.
# In both cases, we want to proceed to the 'else' block to add the line.
if grep -qE '^\s*(-b|--backlog)\s+' "$RULES_FILE" 2>/dev/null; then
    # Rule exists, so replace its value
    if ! sed -i -E "s/^(\s*(-b|--backlog)\s+)[0-9]+/\1$BACKLOG_LIMIT/" "$RULES_FILE"; then
        echo "false"
        exit 1
    fi
else
    # Rule does not exist, so append it. This will create the file if needed.
    if ! echo "-b $BACKLOG_LIMIT" >> "$RULES_FILE"; then
        echo "false"
        exit 1
    fi
fi

if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
fi