#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <octal_mode>" >&2
    exit 1
fi

PERMS="$1"
if ! [[ "$PERMS" =~ ^[0-7]{3,4}$ ]]; then
    echo "Error: Invalid octal permission mode '$PERMS'." >&2
    exit 1
fi

all_successful=true

declare -A valid_shells
while IFS= read -r shell; do
    [[ -z "$shell" || "$shell" =~ ^# ]] && continue
    valid_shells["$shell"]=1
done < /etc/shells

while IFS=: read -r _ _ uid _ _ home shell; do
    if (( uid >= 1000 )) && [[ -v "valid_shells[$shell]" ]]; then
        if [[ -d "$home" ]]; then
            # Find dotfiles and dot-directories, excluding '.' and '..'
            # The '+' in -exec is more efficient than ';'.
            # If any chmod invocation fails, find will return a non-zero status.
            if ! find "$home" -maxdepth 1 -name '.*' -not -name '.' -not -name '..' -exec chmod "$PERMS" {} +; then
                all_successful=false
            fi
        fi
    fi
done < <(getent passwd)

if "$all_successful"; then
    true
else
    false
fi