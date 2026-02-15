#!/bin/bash

RULES_FILE="/etc/audit/rules.d/99-finalize.rules"
ARG=$1

if [[ $EUID -ne 0 ]]; then
   false
   exit $?
fi

if [[ "$#" -ne 1 ]] || ! [[ "$1" =~ ^[12]$ ]]; then
   false
   exit $?
fi

if ! [ -f "$RULES_FILE" ] && ! touch "$RULES_FILE"; then
    false
    exit $?
fi

if ! [ -w "$RULES_FILE" ]; then
    false
    exit $?
fi

# Create a secure temporary file
TMP_FILE=$(mktemp)
if [[ ! "$TMP_FILE" || ! -f "$TMP_FILE" ]]; then
    false
    exit $?
fi
trap 'rm -f "$TMP_FILE"' EXIT

# Write all lines except existing '-e' rules to the temp file
# The `|| [[ $? -eq 1 ]]` part handles the case where grep finds no matches, which is not an error here.
grep -v '^[[:space:]]*-e ' "$RULES_FILE" > "$TMP_FILE" || [[ $? -eq 1 ]]

# Add the desired rule to the end
echo "-e $ARG" >> "$TMP_FILE"

# Only replace the file if a change was actually made
if ! cmp -s "$RULES_FILE" "$TMP_FILE"; then
    # Preserve original ownership and permissions before replacing
    chown --reference="$RULES_FILE" "$TMP_FILE" && \
    chmod --reference="$RULES_FILE" "$TMP_FILE" && \
    mv -f "$TMP_FILE" "$RULES_FILE"
    
    if [[ $? -ne 0 ]]; then
        false
        exit $?
    fi
else
    # The file is already in the desired state. No action needed.
    # We can remove the temp file now as the trap might not have fired yet.
    rm -f "$TMP_FILE"
    trap - EXIT
fi

true
exit $?