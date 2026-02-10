#!/usr/bin/env bash

CONFIG_FILE="/etc/ssh/sshd_config"

interval_val=$(grep -E '^[[:space:]]*ClientAliveInterval[[:space:]]+' "$CONFIG_FILE" 2>/dev/null | tail -n 1 | awk '{print $2}')
count_max_val=$(grep -E '^[[:space:]]*ClientAliveCountMax[[:space:]]+' "$CONFIG_FILE" 2>/dev/null | tail -n 1 | awk '{print $2}')

final_interval=${interval_val:-0}
final_count_max=${count_max_val:-3}

echo "${final_interval}:${final_count_max}"