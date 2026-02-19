#!/bin/bash

FILES=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/audispd"
    "/sbin/augenrules"
)

stat -c "%a" "${FILES[@]}" 2>/dev/null | paste -sd,