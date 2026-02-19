#!/bin/bash

users=$(awk -F: '
    BEGIN {
        while ((getline shell < "/etc/shells") > 0) {
            if (shell !~ /^#|^$/) {
                valid_shells[shell] = 1
            }
        }
        close("/etc/shells")
    }
    $3 >= 1 && $3 <= 999 {
        if ($7 in valid_shells)
            valid_users[$1] = 1
        else
            invalid_users[$1] = 1
    }
    END {
        if (length(invalid_users) == 0)
            print "All normal users have valid login shells."
        else {
            print "Users with invalid shells:"
            for (u in invalid_users) print " - " u
        }
    }
' /etc/passwd)

echo "$users"