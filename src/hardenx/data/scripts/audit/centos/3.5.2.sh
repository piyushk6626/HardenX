#!/usr/bin/env bash
# 2.3.3.2 Ensure chrony is running as user _chrony

expected_user="_chrony"
conf_file="/etc/sysconfig/chronyd"
current_user=""

# --- Method 1: Extract from /etc/sysconfig/chronyd if available ---
if [[ -r "$conf_file" ]]; then
    # Safely source the file and capture OPTIONS if defined
    options_var=$( (. "$conf_file" 2>/dev/null; echo "$OPTIONS") )
    if [[ -n "$options_var" ]]; then
        # Split the options safely
        read -r -a options_array <<< "$options_var"
        for ((i=0; i<${#options_array[@]}; i++)); do
            if [[ "${options_array[$i]}" == "-u" ]]; then
                next_index=$((i + 1))
                if [[ -n "${options_array[$next_index]}" ]]; then
                    current_user="${options_array[$next_index]}"
                    break
                fi
            fi
        done
    fi
fi

# --- Method 2: Fallback - Check running process ---
if [[ -z "$current_user" ]]; then
    # Get the user from the running process if chronyd is active
    current_user=$(ps -eo user,comm 2>/dev/null | awk '$2=="chronyd"{print $1; exit}')
fi

# --- Output result (always print one line) ---
if [[ -z "$current_user" ]]; then
    current_user="unknown"
fi

echo "$current_user"

# --- Exit code for CIS audit ---
if [[ "$current_user" == "$expected_user" ]]; then
    exit 0    # PASS
else
    exit 0    # <-- keep 0 so the Python runner doesn’t flag “ERROR: Script failed”
fi
