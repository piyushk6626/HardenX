#!/usr/bin/env bash

ss -lntup | awk '
    NR > 1 {
        proto = $1
        n = split($5, addr_parts, ":")
        port = addr_parts[n]

        process = "unknown"
        for (i=6; i<=NF; i++) {
            if ($i ~ /^users:\(\(/) {
                split($i, proc_parts, "\"")
                if (proc_parts[2] != "") {
                    process = proc_parts[2]
                }
                break
            }
        }
        
        entries[++c] = proto ":" port ":" process
    }
    END {
        if (c > 0) {
            printf "%s", entries[1]
            for (i=2; i<=c; i++) {
                printf ",%s", entries[i]
            }
        }
    }
'