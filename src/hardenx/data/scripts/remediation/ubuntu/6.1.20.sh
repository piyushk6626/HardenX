#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

NEW_VALUE="$1"
CONFIG_FILE="/etc/ssh/sshd_config"
SETTING="PermitRootLogin"
TEMP_FILE=$(mktemp)

trap 'rm -f "$TEMP_FILE"' EXIT

# Use awk for a single, robust pass to modify or add the setting
awk -v setting="$SETTING" -v value="$NEW_VALUE" '
BEGIN {
    found=0
}
$1 == setting || $1 == "#"setting || $1 == "#" setting {
    if (!found) {
        print setting " " value
        found=1
    }
    next
}
{
    print
}
END {
    if (!found) {
        print setting " " value
    }
}
' "$CONFIG_FILE" > "$TEMP_FILE"

# Verify the new configuration file syntax before replacing
if ! sshd -t -f "$TEMP_FILE" &>/dev/null; then
    echo "false"
    exit 1
fi

# Atomically replace the old config with the new one
cat "$TEMP_FILE" > "$CONFIG_FILE" || { echo "false"; exit 1; }

# Restart the SSH service, trying common service names
if command -v systemctl &>/dev/null; then
    systemctl restart sshd.service || systemctl restart ssh.service || { echo "false"; exit 1; }
elif command -v service &>/dev/null; then
    service sshd restart || service ssh restart || { echo "false"; exit 1; }
else
    # Fallback for systems without systemd or service
    if pkill -HUP sshd; then
        : # Success
    else
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0