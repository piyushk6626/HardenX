#!/bin/bash

# Define constants
PAM_FILE="/etc/pam.d/common-password"
MODULE="pam_pwhistory.so"
OPTION="use_authtok"
ACTION="$1"

# --- Pre-flight Checks ---

if [ "$#" -ne 1 ]; then
    false
    exit 1
fi

if [[ "$ACTION" != "Present" && "$ACTION" != "Absent" ]]; then
    false
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    false
    exit 1
fi

if [ ! -w "$PAM_FILE" ]; then
    false
    exit 1
fi

if ! grep -q -E "^\s*password\s+.*\s+$MODULE" "$PAM_FILE"; then
    false
    exit 1
fi

# --- Helper Function ---

# Checks if the option is currently present on the target module line
option_is_present() {
    grep -q -E "^\s*password\s+.*\s+$MODULE\s+.*\s+$OPTION\b" "$PAM_FILE"
}

# --- Main Logic ---

case "$ACTION" in
    Present)
        if option_is_present; then
            true
        else
            sed -i.bak -r "s/($MODULE.*)/\1 $OPTION/" "$PAM_FILE" && true || false
        fi
        ;;
    Absent)
        if ! option_is_present; then
            true
        else
            sed -i.bak -r "s/(\s+$OPTION\b)//g" "$PAM_FILE" && true || false
        fi
        ;;
esac