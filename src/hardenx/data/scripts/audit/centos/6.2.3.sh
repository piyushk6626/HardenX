#!/usr/bin/env bash
#!/usr/bin/env bash

logfile=$(sudo grep -rE '^Defaults\s+logfile' /etc/sudoers /etc/sudoers.d/ 2>/dev/null | sed 's/.*logfile=//')

if [[ -n "$logfile" ]]; then
    printf "Sudo log file is configured: %s\n" "$logfile"
else
    printf "Sudo log file is not configured.\n"
fi