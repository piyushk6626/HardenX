#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <group_name> <new_gid>" >&2
    false
    exit 1
fi

GROUP_NAME="$1"
NEW_GID="$2"

if ! [[ "$NEW_GID" =~ ^[0-9]+$ ]]; then
    echo "Error: GID must be a positive integer." >&2
    false
    exit 1
fi

if ! getent group "$GROUP_NAME" >/dev/null; then
    echo "Error: Group '$GROUP_NAME' does not exist." >&2
    false
    exit 1
fi

if getent group "$NEW_GID" >/dev/null; then
    echo "Error: GID '$NEW_GID' is already in use." >&2
    false
    exit 1
fi

if groupmod -g "$NEW_GID" "$GROUP_NAME"; then
    true
else
    # groupmod provides its own error message to stderr on failure.
    false
fi