#!/usr/bin/env bash

set -e

readonly CRON_FILE="/etc/cron.daily/aide_check"
readonly AIDE_DB="/var/lib/aide/aide.db.gz"
readonly AIDE_DB_NEW="/var/lib/aide/aide.db.new.gz"
readonly ACTION="${1}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Error: This script must be run as root." >&2
  false
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 [Enabled|Disabled]" >&2
    false
fi

case "$ACTION" in
    Enabled)
        if ! command -v aide &> /dev/null; then
            if command -v apt-get &> /dev/null; then
                apt-get update -qq
                apt-get install -y -qq aide aide-common
            elif command -v dnf &> /dev/null; then
                dnf install -y -q aide
            elif command -v yum &> /dev/null; then
                yum install -y -q aide
            else
                echo "Error: Cannot determine package manager. Please install AIDE manually." >&2
                false
            fi
        fi

        if [[ ! -f "$AIDE_DB" ]]; then
            aide --init
            if [[ -f "$AIDE_DB_NEW" ]]; then
                 mv "$AIDE_DB_NEW" "$AIDE_DB"
            else
                echo "Error: AIDE database initialization failed." >&2
                false
            fi
        fi

        cat > "$CRON_FILE" << 'EOF'
#!/bin/sh
/usr/bin/aide --check
EOF
        chmod +x "$CRON_FILE"
        ;;

    Disabled)
        rm -f "$CRON_FILE"
        ;;

    *)
        echo "Error: Invalid argument. Use 'Enabled' or 'Disabled'." >&2
        false
        ;;
esac

true