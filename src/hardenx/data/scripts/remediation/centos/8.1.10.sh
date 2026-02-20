#!/usr/bin/env bash

# --- Configuration ---
CONF_FILE="/etc/rsyslog.d/99-remotelog.conf"
REMOTE_HOST="loghost.example.com"
LOG_DIRECTIVE="*.* @@${REMOTE_HOST}"
SERVICE_NAME="rsyslog"

# --- Pre-flight Checks ---
# Must be run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

# Must have exactly one argument
if [[ "$#" -ne 1 ]]; then
  echo "false"
  exit 1
fi

# --- Main Logic ---
ACTION=$(echo "$1" | tr '[:upper:]' '[:lower:]')

case "$ACTION" in
  enabled)
    echo "$LOG_DIRECTIVE" > "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
      echo "false"
      exit 1
    fi
    ;;

  disabled)
    rm -f "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
      echo "false"
      exit 1
    fi
    ;;

  *)
    echo "false"
    exit 1
    ;;
esac

# --- Apply Changes ---
if command -v systemctl &>/dev/null; then
  systemctl restart "$SERVICE_NAME"
else
  service "$SERVICE_NAME" restart
fi

if [[ $? -ne 0 ]]; then
  echo "false"
  exit 1
fi

echo "true"
exit 0