#!/bin/bash

fail() {
    echo "false"
    exit 1
}

if [ "$#" -ne 1 ]; then
    fail
fi

SERVICE_TO_CONFIGURE=""
OTHER_SERVICE=""

case "$1" in
    chrony)
        SERVICE_TO_CONFIGURE="chronyd"
        OTHER_SERVICE="ntpd"
        ;;
    ntp)
        SERVICE_TO_CONFIGURE="ntpd"
        OTHER_SERVICE="chronyd"
        ;;
    *)
        fail
        ;;
esac

if ! command -v systemctl &>/dev/null; then
    fail
fi

# Disable and mask the conflicting service if it exists
if systemctl list-unit-files --type=service | grep -q "^${OTHER_SERVICE}.service"; then
    systemctl stop "$OTHER_SERVICE" &>/dev/null
    systemctl disable "$OTHER_SERVICE" &>/dev/null
    systemctl mask "$OTHER_SERVICE" &>/dev/null || fail
fi

# Ensure the target service exists before trying to configure it
if ! systemctl list-unit-files --type=service | grep -q "^${SERVICE_TO_CONFIGURE}.service"; then
    fail
fi

# Unmask, enable, and start the target service
systemctl unmask "$SERVICE_TO_CONFIGURE" &>/dev/null || fail
systemctl enable "$SERVICE_TO_CONFIGURE" &>/dev/null || fail
systemctl start "$SERVICE_TO_CONFIGURE" &>/dev/null || fail

# Final verification
if ! systemctl is-enabled --quiet "$SERVICE_TO_CONFIGURE" || ! systemctl is-active --quiet "$SERVICE_TO_CONFIGURE"; then
    fail
fi

echo "true"
exit 0