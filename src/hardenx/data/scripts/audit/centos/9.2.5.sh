#!/bin/bash

awk -F: '{
    uids[$3]++
}
END {
    count=0
    for (uid in uids) {
        if (uids[uid] > 1) {
            count++
        }
    }
    print count
}' /etc/passwd