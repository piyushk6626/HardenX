#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
# a trap will catch the error and print the failure message.
trap 'echo "false"' ERR
set -euo pipefail

# 1. Validate input and privileges
# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   exit 1
fi

# Check for correct number and value of arguments
if [ "$#" -ne 1 ] || [ "$1" != "Install and Schedule" ]; then
    exit 1
fi

# 2. Ensure AIDE packages are installed
if ! dpkg -s aide >/dev/null 2>&1 || ! dpkg -s aide-common >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y >/dev/null
    apt-get install -y aide aide-common >/dev/null
fi

# 3. Initialize the AIDE database if it doesn't exist
# Re-running aideinit is expensive, so we check first.
if [ ! -f "/var/lib/aide/aide.db" ]; then
    # aideinit is a helper script from aide-common
    aideinit >/dev/null

    # aideinit creates aide.db.new.gz, copy it to the location AIDE expects
    if [ -f "/var/lib/aide/aide.db.new" ]; then
        mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    else
        # Fallback for systems that might create a gzipped version
        gunzip /var/lib/aide/aide.db.new.gz
        mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    fi
fi

# 4. Schedule the daily check via cron if not already scheduled
CRON_CMD="/usr/bin/aide.wrapper --config /etc/aide/aide.conf --check"
if ! crontab -l 2>/dev/null | grep -qF "$CRON_CMD"; then
    (crontab -l 2>/dev/null; echo "0 5 * * * $CRON_CMD") | crontab -
fi

# If script reaches this point, it was successful
echo "true"