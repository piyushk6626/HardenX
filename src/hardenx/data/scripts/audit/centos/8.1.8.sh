#!/usr/bin/env bash
#!/usr/bin/env bash

mode=$(grep -hE '^[[:space:]]*\$FileCreateMode' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null | tail -n 1 | awk '{print $2}')

if [[ -n "$mode" ]]; then
    printf "rsyslog default file creation mode: %s\n" "$mode"
else
    printf "rsyslog default file creation mode not set.\n"
fi