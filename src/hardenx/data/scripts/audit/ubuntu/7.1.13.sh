#!/usr/bin/env bash

awk -F: '
    NR==FNR {
        if ($0 !~ /^#|^$/) {
            valid_shells[$0] = 1
        }
        next
    }

    $3 >= 1 && $3 <= 999 && ($7 in valid_shells) {
        users = (users ? users " " : "") $1
    }

    END {
        if (users) {
            printf "%s\n", users
        }
    }
' /etc/shells /etc/passwd