#!/usr/bin/env bash

# Script must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Validate that exactly one argument is provided
if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

NEW_UMASK="$1"

# Validate that the umask is a valid 3-digit octal number
if ! [[ "$NEW_UMASK" =~ ^[0-7]{3}$ ]]; then
    echo "false"
    exit 1
fi

FILES=("/etc/bashrc" "/etc/profile")
SUCCESS=true

# AWK script to perform the in-file logic.
# It handles three cases:
# 1. 'if [ $UID -eq 0 ]' block exists with a umask line: updates the umask value.
# 2. 'if [ $UID -eq 0 ]' block exists without a umask line: adds the umask line inside it.
# 3. 'if [ $UID -eq 0 ]' block does not exist: appends the entire block to the end of the file.
AWK_SCRIPT='
BEGIN {
    in_root_block = 0
    umask_set_in_block = 0
    block_found = 0
}
/^\s*if\s+\[\s*"?\$UID"?\s*-\s*eq\s*0\s*\]/ {
    print
    in_root_block = 1
    block_found = 1
    next
}
in_root_block && /^\s*umask\s+[0-7]{3,4}/ {
    print "    umask " new_umask
    umask_set_in_block = 1
    next
}
in_root_block && /^\s*fi\s*$/ {
    if (!umask_set_in_block) {
        print "    umask " new_umask
    }
    print
    in_root_block = 0
    umask_set_in_block = 0
    next
}
{ print }
END {
    if (!block_found) {
        printf "\nif [ $UID -eq 0 ]; then\n    umask %s\nfi\n", new_umask
    }
}
'

for file in "${FILES[@]}"; do
    if [[ ! -f "$file" ]] || [[ ! -w "$file" ]]; then
        SUCCESS=false
        break
    fi

    TMP_FILE=$(mktemp)
    if ! awk -v new_umask="$NEW_UMASK" "$AWK_SCRIPT" "$file" > "$TMP_FILE"; then
        rm -f "$TMP_FILE"
        SUCCESS=false
        break
    fi

    if ! mv "$TMP_FILE" "$file"; then
        rm -f "$TMP_FILE"
        SUCCESS=false
        break
    fi
done

if [[ "$SUCCESS" == "true" ]]; then
    echo "true"
else
    echo "false"
    exit 1
fi