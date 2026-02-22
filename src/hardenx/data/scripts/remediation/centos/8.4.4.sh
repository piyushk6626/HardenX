#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
  echo "false"
  exit 1
fi

ACTION="$1"
RULE_FILE="/etc/audit/rules.d/99-time-change.rules"

case "${ACTION}" in
  enabled)
    if ! cat > "${RULE_FILE}" << EOF
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S stime -S clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change
EOF
    then
      echo "false"
      exit 1
    fi
    ;;
  disabled)
    if ! rm -f "${RULE_FILE}"; then
      echo "false"
      exit 1
    fi
    ;;
  *)
    echo "false"
    exit 1
    ;;
esac

if augenrules --load &>/dev/null; then
  echo "true"
else
  echo "false"
fi