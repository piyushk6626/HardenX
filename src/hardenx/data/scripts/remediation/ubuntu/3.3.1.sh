#!/bin/bash

# Exit on any error, and print 'false'
trap 'echo false' ERR
set -e

# --- Pre-flight Checks ---

# 1. Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

# 2. Validate input argument
if [[ $# -ne 1 ]]; then
  echo "false"
  exit 1
fi

TARGET_DAEMON="$1"
if [[ "$TARGET_DAEMON" != "systemd-timesyncd" && "$TARGET_DAEMON" != "chrony" ]]; then
  echo "false"
  exit 1
fi

# --- Configuration ---

declare -a CONFLICTING_DAEMONS
declare TARGET_PACKAGE
declare -a TARGET_SERVICES

if [[ "$TARGET_DAEMON" == "systemd-timesyncd" ]]; then
  TARGET_PACKAGE="" # Part of systemd, no separate package
  TARGET_SERVICES=("systemd-timesyncd")
  CONFLICTING_DAEMONS=("chronyd" "chrony" "ntpd" "ntp")
elif [[ "$TARGET_DAEMON" == "chrony" ]]; then
  TARGET_PACKAGE="chrony"
  TARGET_SERVICES=("chronyd" "chrony") # RHEL uses chronyd, Debian uses chrony
  CONFLICTING_DAEMONS=("systemd-timesyncd" "ntpd" "ntp")
fi

# --- Execution ---

# 1. Install necessary package if required
if [[ -n "$TARGET_PACKAGE" ]]; then
  INSTALL_CMD=""
  if command -v dnf &>/dev/null; then
    INSTALL_CMD="dnf install -y"
  elif command -v yum &>/dev/null; then
    INSTALL_CMD="yum install -y"
  elif command -v apt-get &>/dev/null; then
    # Prevent interactive prompts on Debian/Ubuntu
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y >/dev/null
    INSTALL_CMD="apt-get install -y"
  else
    # Fail if package installation is required but no manager is found
    echo "false"
    exit 1
  fi
  $INSTALL_CMD "$TARGET_PACKAGE" >/dev/null
fi

# 2. Stop and disable all conflicting daemons
for daemon in "${CONFLICTING_DAEMONS[@]}"; do
  # Check if the service exists before trying to manage it
  if systemctl list-unit-files --type=service | grep -q "^${daemon}.service"; then
    systemctl stop "$daemon" >/dev/null 2>&1 || true
    systemctl disable "$daemon" >/dev/null 2>&1 || true
  fi
done

# 3. Enable and start the target daemon
# Try all potential service names for the target; one should succeed.
ENABLED_AND_STARTED=false
for service in "${TARGET_SERVICES[@]}"; do
  if systemctl list-unit-files --type=service | grep -q "^${service}.service"; then
    systemctl enable --now "$service" >/dev/null 2>&1
    # Verify it's active
    if systemctl is-active --quiet "$service"; then
        ENABLED_AND_STARTED=true
        break
    fi
  fi
done

if ! $ENABLED_AND_STARTED; then
    # If we loop through all possibilities and none work, fail.
    echo "false"
    exit 1
fi

# 4. Success
echo "true"
exit 0