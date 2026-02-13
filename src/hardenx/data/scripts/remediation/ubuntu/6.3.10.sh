#!/usr/bin/env bash

PAM_FILE="/etc/pam.d/common-auth"
TARGET_PATTERN="auth.*required.*pam_faillock.so"
OPTION="even_deny_root"
ACTION=$1

if [[ $# -ne 1 ]] || [[ "$ACTION" != "true" && "$ACTION" != "false" ]]; then
    echo "false"
    exit 1
fi

if ! grep -q "$TARGET_PATTERN" "$PAM_FILE"; then
    echo "false"
    exit 1
fi

if [[ ! -w "$PAM_FILE" ]]; then
    echo "false"
    exit 1
fi

is_present=false
if grep "$TARGET_PATTERN" "$PAM_FILE" | grep -q "\s$OPTION"; then
    is_present=true
fi

modification_needed=false
if [[ "$ACTION" == "true" && "$is_present" == "false" ]]; then
    modification_needed=true
elif [[ "$ACTION" == "false" && "$is_present" == "true" ]]; then
    modification_needed=true
fi

if [[ "$modification_needed" == "false" ]]; then
    echo "true"
    exit 0
fi

if [[ "$ACTION" == "true" ]]; then
    sed -i.bak "/${TARGET_PATTERN}/s/\$/ ${OPTION}/" "$PAM_FILE"
else
    sed -i.bak "/${TARGET_PATTERN}/s/ ${OPTION}//" "$PAM_FILE"
fi

if [[ $? -eq 0 ]]; then
    echo "true"
else
    mv "${PAM_FILE}.bak" "$PAM_FILE" &>/dev/null
    echo "false"
fi