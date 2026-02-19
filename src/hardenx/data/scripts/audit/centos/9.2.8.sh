#!/usr/bin/env bash
# 9.2.8 

awk -F: '
    NR==FNR {
        groups[$3] = $1  # from /etc/group, store GID
        next
    }
    {
        user=$1
        gid=$4
        if (!(gid in groups)) {
            printf "User: %-15s | Missing Group ID: %s\n", user, gid
            missing=1
        }
    }
    END {
        if (!missing)
            print "All groups in /etc/passwd exist in /etc/group."
    }
' /etc/group /etc/passwd