#!/usr/bin/env bash

fail() {
    exec 1>&3 3>&-
    echo "false"
    exit 1
}

if [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

exec 3>&1
exec &>/dev/null

if command -v apt-get &>/dev/null; then
    if ! dpkg-query -W -f='${Status}' chrony 2>/dev/null | grep -q "install ok installed"; then
        apt-get update || fail
        apt-get install -y chrony || fail
    fi
    SERVICE_NAME="chrony"
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    if ! rpm -q chrony &>/dev/null; then
        if command -v dnf &>/dev/null; then
            dnf install -y chrony || fail
        else
            yum install -y chrony || fail
        fi
    fi
    SERVICE_NAME="chronyd"
else
    fail
fi

systemctl enable "$SERVICE_NAME" || fail
systemctl start "$SERVICE_NAME" || fail

exec 1>&3 3>&-
echo "true"
exit 0