#!/bin/bash

current_days=$(($(date +%s) / 86400))

awk -F: -v now="$current_days" '
    FNR==NR {
        if ($3 >= 1000) {
            non_system_users[$1] = 1
        }
        next
    }
    ($1 in non_system_users) && ($3 > now) {
        is_future = 1
        exit
    }
    END {
        if (is_future) {
            print "false"
        } else {
            print "true"
        }
    }
' /etc/passwd /etc/shadow