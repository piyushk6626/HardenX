#!/usr/bin/env bash

# Find the active, uncommented MaxSessions line.
# The grep pattern looks for lines starting with optional whitespace,
# followed by "MaxSessions" and then more whitespace.
value=$(grep -E '^[[:space:]]*MaxSessions[[:space:]]+' /etc/ssh/sshd_config | awk '{print $2}' | tail -n 1)

# Use parameter expansion to provide the default value if 'value' is empty.
echo "${value:-10}"