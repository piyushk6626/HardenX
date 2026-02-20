#!/usr/bin/env bash

if [[ "$1" != "Enabled" || "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

LIMITS_CONF="/etc/security/limits.conf"
SYSCTL_CONF="/etc/sysctl.d/99-security.conf"

if ! grep -qFx '* hard core 0' "$LIMITS_CONF"; then
    echo '* hard core 0' >> "$LIMITS_CONF" || { echo "false"; exit 1; }
fi

touch "$SYSCTL_CONF" || { echo "false"; exit 1; }
sed -i '/^\s*fs\.suid_dumpable\s*=/d' "$SYSCTL_CONF" || { echo "false"; exit 1; }
echo 'fs.suid_dumpable = 0' >> "$SYSCTL_CONF" || { echo "false"; exit 1; }

sysctl --system &>/dev/null || { echo "false"; exit 1; }

echo "true"
exit 0