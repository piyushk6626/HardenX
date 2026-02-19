#!/usr/bin/env bash

# First, verify that the AIDE binary is installed and executable
if ! command -v aide &> /dev/null; then
    echo "Disabled"
    exit 0
fi

# Second, check for a cron job that executes aide.
# We search the root crontab and all standard system cron directories.
# We filter out commented lines before searching for the 'aide' command.
if (crontab -l -u root 2>/dev/null; grep -rsh . /etc/cron.d /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/crontab 2>/dev/null) | grep -v -E '^\s*#' | grep -q -E '\baide\b'; then
    echo "Enabled"
else
    echo "Disabled"
fi