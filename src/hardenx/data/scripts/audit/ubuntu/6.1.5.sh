#!/usr/bin/env bash

CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "none"
    exit 0
fi

awk '
  /^[[:space:]]*Banner[[:space:]]+/ && !/^[[:space:]]*#/ {
    line = $0
    sub(/^[[:space:]]*Banner[[:space:]]+/, "", line)
    banner_path = line
  }
  END {
    if (banner_path != "") {
      print banner_path
    } else {
      print "none"
    }
  }
' "$CONFIG_FILE"