#!/usr/bin/env bash

# Define constants
RULE_FILE="/etc/audit/rules.d/50-perm_mod.rules"
RULE="-w /usr/bin/chacl -p x -k perm_mod"
STATE="$1"

# --- Pre-flight checks ---

# Must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Check for correct argument
if [[ "$STATE" != "present" && "$STATE" != "absent" ]]; then
    echo "false"
    exit 1
fi

# --- Main logic ---

perform_change() {
    if augenrules --load &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

case "$STATE" in
    present)
        # Ensure the parent directory exists
        if ! mkdir -p "$(dirname "$RULE_FILE")"; then
            echo "false"
            exit 1
        fi

        # Add the rule if it doesn't already exist (match whole line)
        if ! grep -qxF -- "$RULE" "$RULE_FILE" &>/dev/null; then
            if ! echo "$RULE" >> "$RULE_FILE"; then
                echo "false"
                exit 1
            fi
        fi

        perform_change
        ;;

    absent)
        # If the file doesn't exist, the rule is already absent. Success.
        if [[ ! -f "$RULE_FILE" ]]; then
            echo "true"
            exit 0
        fi

        # If the rule exists, remove it.
        if grep -qxF -- "$RULE" "$RULE_FILE" &>/dev/null; then
            # Using a temp file is safer than sed -i.
            TEMP_FILE=$(mktemp)
            if ! grep -vxF -- "$RULE" "$RULE_FILE" > "$TEMP_FILE"; then
                rm -f "$TEMP_FILE"
                echo "false"
                exit 1
            fi
            if ! mv "$TEMP_FILE" "$RULE_FILE"; then
                rm -f "$TEMP_FILE"
                echo "false"
                exit 1
            fi
        fi

        perform_change
        ;;
esac