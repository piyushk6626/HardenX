#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
  echo "false"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "false"
  exit 1
fi

ACTION="$1"
RULES_FILE="/etc/audit/rules.d/permissions.rules"
RULE1='-a always,exit -F arch=b64 -S setfacl -F auid>=1000 -F auid!=-1 -k perm_mod'
RULE2='-a always,exit -F arch=b32 -S setfacl -F auid>=1000 -F auid!=-1 -k perm_mod'

case "$ACTION" in
  enabled)
    mkdir -p "$(dirname "$RULES_FILE")" || { echo "false"; exit 1; }
    touch "$RULES_FILE" || { echo "false"; exit 1; }

    (
      grep -qFx -- "$RULE1" "$RULES_FILE" || echo "$RULE1"
      grep -qFx -- "$RULE2" "$RULES_FILE" || echo "$RULE2"
    ) >> "$RULES_FILE"

    if grep -qFx -- "$RULE1" "$RULES_FILE" && grep -qFx -- "$RULE2" "$RULES_FILE"; then
      echo "true"
    else
      echo "false"
    fi
    ;;

  disabled)
    if [[ ! -f "$RULES_FILE" ]]; then
      echo "true"
      exit 0
    fi
    
    sed -i -e "\|^${RULE1}$|d" -e "\|^${RULE2}$|d" "$RULES_FILE"
    if [[ $? -eq 0 ]]; then
      echo "true"
    else
      echo "false"
    fi
    ;;

  *)
    echo "false"
    exit 1
    ;;
esac