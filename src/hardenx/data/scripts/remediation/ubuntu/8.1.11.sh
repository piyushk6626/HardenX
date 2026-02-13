#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Error: This script must be run as root." >&2
  false
  exit $?
fi

if [[ "$1" != "disabled" ]]; then
  echo "Usage: $0 disabled" >&2
  false
  exit $?
fi

CONFIG_FILES=()
if [[ -f /etc/rsyslog.conf ]]; then
    CONFIG_FILES+=("/etc/rsyslog.conf")
fi

if [[ -d /etc/rsyslog.d ]]; then
    while IFS= read -r -d $'\0' file; do
        CONFIG_FILES+=("$file")
    done < <(find /etc/rsyslog.d -maxdepth 1 -type f -name "*.conf" -print0)
fi

if [[ ${#CONFIG_FILES[@]} -eq 0 ]]; then
    echo "Warning: No rsyslog configuration files found." >&2
    true
    exit $?
fi

# Regex to match uncommented remote logging directives (legacy and modern syntax)
REGEX='s/^\s*(\$ModLoad\s+im(udp|tcp)|\$UDPServerRun|\$InputTCPServerRun|module\(load="im(udp|tcp)"\)|input\(type="im(udp|tcp)".*)/# &/'

for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        # Only apply the substitution to lines that are not already commented
        sed -i -E "/^\s*#/!$REGEX" "$file"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to modify $file." >&2
            false
            exit $?
        fi
    fi
done

if ! systemctl restart rsyslog; then
    echo "Error: Failed to restart rsyslog service." >&2
    false
    exit $?
fi

true