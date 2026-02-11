#!/usr/bin/env bash

fail() {
    echo "false"
    exit 1
}

if [[ "$(id -u)" -ne 0 ]]; then
    fail
fi

if [[ "$#" -ne 1 ]]; then
    fail
fi

ACTION="$1"
SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"
LIMITS_CONF="/etc/security/limits.conf"
LIMITS_LINE="* hard core 0"
SYSCTL_LINE="fs.suid_dumpable = 0"
CORE_SERVICE="systemd-coredump.service"

case "$ACTION" in
    Enabled)
        # Add core dump limit if it doesn't exist
        grep -qF -- "$LIMITS_LINE" "$LIMITS_CONF" || echo "$LIMITS_LINE" >> "$LIMITS_CONF" || fail

        # Set sysctl value
        echo "$SYSCTL_LINE" > "$SYSCTL_CONF" || fail
        sysctl -p "$SYSCTL_CONF" &>/dev/null || fail

        # Disable coredump service
        systemctl stop "$CORE_SERVICE" &>/dev/null || true # May already be stopped
        systemctl disable "$CORE_SERVICE" &>/dev/null || fail
        ;;

    Disabled)
        # Remove core dump limit
        # Use a temp file for sed to be safe
        sed "/^\s*\* hard core 0\s*$/d" "$LIMITS_CONF" > "$LIMITS_CONF.tmp" && mv "$LIMITS_CONF.tmp" "$LIMITS_CONF" || fail

        # Remove sysctl file
        rm -f "$SYSCTL_CONF" || fail
        sysctl --system &>/dev/null || fail

        # Enable coredump service
        systemctl enable "$CORE_SERVICE" &>/dev/null || fail
        systemctl start "$CORE_SERVICE" &>/dev/null || fail
        ;;

    *)
        fail
        ;;
esac

echo "true"
exit 0