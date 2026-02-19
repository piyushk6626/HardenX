#!/bin/bash

awk -F: '
    NR==FNR {
        valid_gids[$3] = 1
        next
    }
    !($4 in valid_gids) {
        mismatch_count++
    }
    END {
        print mismatch_count+0
    }
' /etc/group /etc/passwd