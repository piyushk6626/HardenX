#!/bin/bash

if [[ "$1" != "Configured" ]]; then
    echo "false"
    exit 1
fi

RULES_FILE="/etc/audit/rules.d/privilege-escalation.rules"

cat > "$RULES_FILE" <<'EOF'
-a always,exit -F arch=b64 -S setuid,setgid,setreuid,setregid,setresuid,setresgid,setfsuid,setfsgid -F auid>=1000 -F auid!=-1 -k privilege_changes
-a always,exit -F arch=b32 -S setuid,setgid,setreuid,setregid,setresuid,setresgid,setfsuid,setfsgid -F auid>=1000 -F auid!=-1 -k privilege_changes
EOF

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
    exit 1
fi

exit 0