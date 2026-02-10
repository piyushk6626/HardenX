#!/bin/bash

passwd -S root 2>/dev/null | awk '{
    if ($2 == "L") {
        print "Locked"
    } else {
        print "Unlocked"
    }
}'