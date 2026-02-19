#!/usr/bin/env bash

# This script must be run with sufficient privileges to read /etc/shadow

current_days_since_epoch=$(($(date +%s) / 86400))

awk -F: -v current_days="$current_days_since_epoch" '
    # Field 3 must be a number and greater than the current date
    $3 ~ /^[0-9]+$/ && $3 > current_days {
        # Append username to the list, prepending a comma if the list is not empty
        user_list = (user_list ? user_list "," : "") $1
    }
    END {
        # Print the final list without a trailing newline
        printf "%s", user_list
    }
' /etc/shadow