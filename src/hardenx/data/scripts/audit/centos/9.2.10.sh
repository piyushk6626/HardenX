#!/usr/bin/env bash

# This script finds the most permissive octal permission mode for dotfiles
# across all interactive user home directories (UID >= 1000).

# Use a single awk command to efficiently find home directories of users
# with UID >= 1000 and a valid shell as listed in /etc/shells.
# This avoids looping and repeatedly calling grep.
readarray -t home_dirs < <(
    awk -F: '
        FNR==NR { shells[$0]=1; next }
        $3 >= 1000 && $7 in shells { print $6 }
    ' /etc/shells /etc/passwd 2>/dev/null
)

# If no such users were found, no further action is needed.
if [ ${#home_dirs[@]} -eq 0 ]; then
    echo "Not Applicable"
    exit 0
fi

# Find all dotfiles/dirs in the collected home directories, get their octal
# permissions, sort them numerically in reverse, and take the first (highest) value.
# Errors are redirected to /dev/null to handle non-existent or unreadable home dirs.
max_perm=$(find "${home_dirs[@]}" -maxdepth 1 -mindepth 1 -name '.*' -exec stat -c "%a" {} + 2>/dev/null | sort -rn | head -n 1)

# If the result is an empty string, it means no dotfiles were found.
if [ -z "$max_perm" ]; then
    echo "Not Applicable"
else
    echo "$max_perm"
fi