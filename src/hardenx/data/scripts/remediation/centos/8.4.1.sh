#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    false
    exit 1
fi

ACTION="$1"
RULES_FILE="/etc/audit/rules.d/scope.rules"
RULE1="-w /etc/sudoers -p wa -k scope"
RULE2="-w /etc/sudoers.d -p wa -k scope"
RULES_DIR=$(dirname "$RULES_FILE")

case "$ACTION" in
    Enabled)
        mkdir -p "$RULES_DIR" || { false; exit 1; }
        touch "$RULES_FILE" || { false; exit 1; }

        if ! grep -qFx -- "$RULE1" "$RULES_FILE"; then
            echo "$RULE1" >> "$RULES_FILE" || { false; exit 1; }
        fi

        if ! grep -qFx -- "$RULE2" "$RULES_FILE"; then
            echo "$RULE2" >> "$RULES_FILE" || { false; exit 1; }
        fi
        true
        ;;

    Disabled)
        if [[ ! -f "$RULES_FILE" ]]; then
            true
            exit 0
        fi

        temp_file=$(mktemp) || { false; exit 1; }
        
        # Invert grep to remove the exact lines, write to temp file
        grep -vFx -- "$RULE1" "$RULES_FILE" | grep -vFx -- "$RULE2" > "$temp_file" || { rm -f "$temp_file"; false; exit 1; }

        # Check if file has content before moving, then remove it
        if [[ -s "$temp_file" ]]; then
            mv "$temp_file" "$RULES_FILE" || { rm -f "$temp_file"; false; exit 1; }
        else
            rm -f "$RULES_FILE" "$temp_file" || { false; exit 1; }
        fi
        true
        ;;
        
    *)
        false
        ;;
esac