#!/usr/bin/env bash

# This script checks for auditd rules for 'setfacl' command execution.
# It inspects both the currently loaded kernel rules and the persistent rule files.
#
# A compliant setup requires one rule for 64-bit systems (arch=b64) and
# one for 32-bit systems (arch=b32).
#
# Each rule must:
# - Be on the 'exit' list and trigger 'always'.
# - Audit the 'execve' syscall.
# - Specify the path '/usr/bin/setfacl'.
# - Apply to user-initiated events (auid>=1000).
# - Explicitly exclude daemon/system events (auid!=-1 or auid!=4294967295).

# The awk script will set its exit code based on whether compliant rules are found.
# Exit code 0: Both b32 and b64 rules were found.
# Exit code 1: One or both rules were missing.
#
# The script processes a combined stream of rules from `auditctl -l` and
# files in /etc/audit/rules.d/.

(auditctl -l 2>/dev/null; find /etc/audit/rules.d -maxdepth 1 -type f -name '*.rules' -exec cat {} + 2>/dev/null) |
awk '
# Skip comments and empty lines
/^\s*#/ || /^\s*$/ { next }

{
    # Reset flags for each line
    a = s = p = auid_gte = auid_ne = arch_b32 = arch_b64 = 0

    # Iterate over fields in the rule
    for (i = 1; i <= NF; i++) {
        if ($i == "-a" || $i == "-A") {
            # Check for "always,exit" or "exit,always"
            if ($(i+1) ~ /^(always,exit|exit,always)$/) { a = 1 }
        }
        else if ($i == "-S" && $(i+1) == "execve") { s = 1 }
        else if ($i == "-F") {
            if ($(i+1) == "path=/usr/bin/setfacl") { p = 1 }
            else if ($(i+1) == "auid>=1000") { auid_gte = 1 }
            else if ($(i+1) == "auid!=-1" || $(i+1) == "auid!=4294967295") { auid_ne = 1 }
            else if ($(i+1) == "arch=b32") { arch_b32 = 1 }
            else if ($(i+1) == "arch=b64") { arch_b64 = 1 }
        }
    }

    # Check if a fully compliant rule was found on this line
    is_compliant = (a && s && p && auid_gte && auid_ne)

    if (is_compliant && arch_b32) { found_b32 = 1 }
    if (is_compliant && arch_b64) { found_b64 = 1 }
}

END {
    if (found_b32 && found_b64) {
        exit 0
    } else {
        exit 1
    }
}
'

if [ $? -eq 0 ]; then
    echo "true"
else
    echo "false"
fi