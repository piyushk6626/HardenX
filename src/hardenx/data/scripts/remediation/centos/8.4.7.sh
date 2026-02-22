#!/bin/bash

RULE_FILE="/etc/audit/rules.d/unsuccessful-access.rules"
read -r -d '' RULES_CONTENT <<'EOF'
# CIS: Log unsuccessful file access attempts (EACCES/EPERM)
-a always,exit -F arch=b64 -S open,openat,openat2,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k access-denied
-a always,exit -F arch=b32 -S open,openat,openat2,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k access-denied
-a always,exit -F arch=b64 -S open,openat,openat2,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k access-denied
-a always,exit -F arch=b32 -S open,openat,openat2,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k access-denied
EOF

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

case "$1" in
  Present)
    if ! echo "$RULES_CONTENT" > "$RULE_FILE"; then
        echo "false"
        exit 1
    fi

    if augenrules --load &>/dev/null; then
      echo "true"
    else
      rm -f "$RULE_FILE" &>/dev/null
      echo "false"
    fi
    ;;

  Absent)
    if [ ! -f "$RULE_FILE" ]; then
        echo "true"
        exit 0
    fi

    if rm -f "$RULE_FILE" && augenrules --load &>/dev/null; then
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