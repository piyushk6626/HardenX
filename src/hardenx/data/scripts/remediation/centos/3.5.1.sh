#!/usr/bin/env bash

set -eo pipefail

fail() {
    echo "false"
    exit 1
}

trap fail ERR

[[ $# -ne 1 || -z "$1" ]] && exit 1
[[ $EUID -ne 0 ]] && exit 1

readonly CHRONY_CONF="/etc/chrony.conf"
readonly SERVERS_CSV="$1"

[[ -f "$CHRONY_CONF" ]] || exit 1

readonly TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"; fail' ERR EXIT HUP INT TERM

# Comment out existing server and pool lines
sed -E 's/^[[:space:]]*(server|pool)/#&/' "$CHRONY_CONF" > "$TMP_FILE"

# Add new server lines from the command-line argument
IFS=',' read -r -a servers_array <<< "$SERVERS_CSV"
for server in "${servers_array[@]}"; do
    # Trim leading/trailing whitespace
    read -r -d '' server_trimmed <<< "$server"
    if [[ -n "$server_trimmed" ]]; then
        echo "server $server_trimmed iburst" >> "$TMP_FILE"
    fi
done

# Atomically replace the original file
install -m 0644 "$TMP_FILE" "$CHRONY_CONF"

# Clean up and report success
rm -f "$TMP_FILE"
trap - ERR EXIT HUP INT TERM
echo "true"
exit 0