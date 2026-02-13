#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ "$1" != "0" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
PARAMS=(
    "net.ipv6.conf.all.accept_ra"
    "net.ipv6.conf.default.accept_ra"
)
PERSISTENT_CONF_FILE="/etc/sysctl.d/99-disable-ipv6-ra.conf"

for param in "${PARAMS[@]}"; do
    if ! sysctl -w "${param}=${VALUE}" &>/dev/null; then
        echo "false"
        exit 1
    fi
done

TMP_FILE=$(mktemp)
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi
trap 'rm -f "$TMP_FILE"' EXIT

(
    printf "%s = %s\n" "${PARAMS[0]}" "$VALUE"
    printf "%s = %s\n" "${PARAMS[1]}" "$VALUE"
) > "$TMP_FILE"

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

if ! mv "$TMP_FILE" "$PERSISTENT_CONF_FILE"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0