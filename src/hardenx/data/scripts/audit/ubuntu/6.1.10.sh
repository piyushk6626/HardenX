#!/bin/bash

awk '
    /^[[:space:]]*[^#]/ && tolower($1) == "hostbasedauthentication" {
        value = tolower($2)
    }
    END {
        if (value == "yes") {
            print "yes"
        } else {
            print "no"
        }
    }
' /etc/ssh/sshd_config