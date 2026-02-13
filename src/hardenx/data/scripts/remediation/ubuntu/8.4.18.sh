#!/usr/bin/env bash

# This script manages a specific auditd rule for monitoring usermod.
# It ensures idempotency for 'present' and 'absent' states.

set -o pipefail

RULE_FILE="/etc/audit/rules.d/audit.rules"
RULE="-w /usr/sbin/usermod -p wa -k usermod"
STATE="$1"

# --- Pre-flight Checks ---

# Must be run as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "This script must be run as root." >&2
    echo "false"
    exit 1
fi

# Check for required command
if ! command -v augenrules &> /dev/null; then
    echo "Error: 'augenrules' command not found. Is auditd installed?" >&2
    echo "false"
    exit 1
fi

# Validate input argument
if [[ "$STATE" != "present" && "$STATE" != "absent" ]]; then
    echo "Usage: $0 [present|absent]" >&2
    echo "false"
    exit 1
fi

# Ensure audit rules file exists and is writable
if [[ ! -f "$RULE_FILE" ]]; then
    # If the directory exists, we can create the file. If not, it's a bigger problem.
    if [[ -d "$(dirname "$RULE_FILE")" ]]; then
        touch "$RULE_FILE" &>/dev/null || {
            echo "Error: Cannot create audit rule file at $RULE_FILE." >&2
            echo "false"
            exit 1
        }
    else
        echo "Error: Audit rules directory $(dirname "$RULE_FILE") does not exist." >&2
        echo "false"
        exit 1
    fi
elif [[ ! -w "$RULE_FILE" ]]; then
    echo "Error: Audit rule file $RULE_FILE is not writable." >&2
    echo "false"
    exit 1
fi

# --- Main Logic ---

if [[ "$STATE" == "present" ]]; then
    # Check if the rule already exists
    if grep -qFx -- "$RULE" "$RULE_FILE"; then
        # Already compliant
        echo "true"
        exit 0
    else
        # Add the rule
        if echo "$RULE" >> "$RULE_FILE"; then
            # Apply the changes
            if augenrules --load &> /dev/null; then
                echo "true"
                exit 0
            else
                echo "Error: augenrules --load failed after adding rule." >&2
                # Attempt to roll back
                sed -i '\|$RULE|d' "$RULE_FILE"
                echo "false"
                exit 1
            fi
        else
            echo "Error: Failed to write to $RULE_FILE." >&2
            echo "false"
            exit 1
        fi
    fi
elif [[ "$STATE" == "absent" ]]; then
    # Check if the rule exists to be removed
    if ! grep -qFx -- "$RULE" "$RULE_FILE"; then
        # Already compliant, rule is not present
        echo "true"
        exit 0
    else
        # Remove the rule using a temporary file for safety
        TMP_FILE=$(mktemp)
        if grep -vFx -- "$RULE" "$RULE_FILE" > "$TMP_FILE"; then
            if mv "$TMP_FILE" "$RULE_FILE"; then
                # Apply the changes
                if augenrules --load &> /dev/null; then
                    echo "true"
                    exit 0
                else
                    echo "Error: augenrules --load failed after removing rule." >&2
                    # There is no simple rollback here as the original state is unknown.
                    echo "false"
                    exit 1
                fi
            else
                echo "Error: Failed to move temporary file to $RULE_FILE." >&2
                rm -f "$TMP_FILE"
                echo "false"
                exit 1
            fi
        else
            echo "Error: Failed to create temporary rule file." >&2
            rm -f "$TMP_FILE"
            echo "false"
            exit 1
        fi
    fi
fi