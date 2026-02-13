#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
  echo "false"
  exit 1
fi

VALUE="$1"
CONF_FILE="/etc/sysctl.d/99-custom-rpfilter.conf"

# Create the configuration file.
# Using a heredoc is clean and effective.
if ! cat << EOF > "$CONF_FILE"; then
net.ipv4.conf.all.rp_filter = ${VALUE}
net.ipv4.conf.default.rp_filter = ${VALUE}
EOF
  echo "false"
  exit 1
fi

# Apply the new settings to the running kernel.
# The -p flag loads settings from a file.
# Redirect output to /dev/null to keep our script's output clean.
if ! sysctl -p "$CONF_FILE" &>/dev/null; then
  # If sysctl fails, attempt to remove the created config file for cleanup.
  rm -f "$CONF_FILE" &>/dev/null
  echo "false"
  exit 1
fi

echo "true"
exit 0