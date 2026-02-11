#!/bin/bash

rules=$(auditctl -l 2>/dev/null)

check1() {
    echo "$1" | grep -- "-w /var/run/utmp" | grep -- "-p wa" | grep -q -- "-k"
}

check2() {
    echo "$1" | grep -- "-w /var/log/wtmp" | grep -- "-p wa" | grep -q -- "-k"
}

check3() {
    echo "$1" | grep -- "-w /var/log/btmp" | grep -- "-p wa" | grep -q -- "-k"
}

if check1 "$rules" && check2 "$rules" && check3 "$rules"; then
    echo "Enabled"
else
    echo "Disabled"
fi