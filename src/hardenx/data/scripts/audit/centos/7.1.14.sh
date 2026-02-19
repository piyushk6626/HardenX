#!/usr/bin/env bash

awk -F: '
    NR==FNR {
        if ($2 ~ /^!|^\*/) {
            locked[$1] = 1
        }
        next
    }
    ($7 == "/sbin/nologin" || $7 == "/bin/false") && !($1 in locked) {
        users = users ? users " " $1 : $1
    }
    END {
        if (users) {
            print users
        }
    }
' /etc/shadow /etc/passwd