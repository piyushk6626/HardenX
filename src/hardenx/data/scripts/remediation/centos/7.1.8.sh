#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <required_gid_0_group_name>" >&2
    exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi

readonly REQUIRED_GROUP="$1"
has_failed=false

mapfile -t gid_zero_groups < <(getent group 0 | cut -d: -f1)

found_required_group=false
for group in "${gid_zero_groups[@]}"; do
    if [[ "$group" == "$REQUIRED_GROUP" ]]; then
        found_required_group=true
        break
    fi
done

if ! $found_required_group; then
    echo "Error: The specified group '$REQUIRED_GROUP' does not have GID 0 or does not exist." >&2
    exit 1
fi

for group in "${gid_zero_groups[@]}"; do
    if [[ "$group" != "$REQUIRED_GROUP" ]]; then
        if ! groupdel "$group"; then
            echo "Error: Failed to remove duplicate GID 0 group '$group'." >&2
            has_failed=true
        fi
    fi
done

if $has_failed; then
    exit 1
else
    exit 0
fi