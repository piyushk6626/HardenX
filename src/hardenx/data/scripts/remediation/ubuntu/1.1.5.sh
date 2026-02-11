#!/usr/bin/env bash

CONF_FILE="/etc/modprobe.d/disable-jffs2.conf"
DESIRED_STATE="$1"

case "$DESIRED_STATE" in
    Disabled)
        if echo 'install jffs2 /bin/true' > "$CONF_FILE"; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    Enabled)
        if rm -f "$CONF_FILE"; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    *)
        echo "false"
        ;;
esac
