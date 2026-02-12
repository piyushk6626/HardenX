#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
    echo "Usage: $0 \"service1:port1,service2:port2,...\"" >&2
    exit 2
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   exit 1
fi

APPROVED_SERVICES_STRING="$1"
declare -A approved_list
declare -A processed_pids
FAIL_FLAG=0

# Populate the approved_list associative array for O(1) lookups
IFS=',' read -ra services <<< "$APPROVED_SERVICES_STRING"
for service_port in "${services[@]}"; do
    approved_list["$service_port"]=1
done

# Process listening sockets using ss and awk for efficient parsing
# ss options: -H (no header), -t (tcp), -u (udp), -l (listening), -p (processes), -n (numeric)
ss -H -tulpn | awk '{
    if (match($0, /pid=([0-9]+)/, p) && match($0, /users:\(\("([^"]+)"/, n)) {
        # Extract port, handling both IPv4 (0.0.0.0:80) and IPv6 ([::]:80)
        split($4, addr, ":");
        port = addr[length(addr)];
        # Output: pid process_name port
        print p[1], n[1], port;
    }
}' | while read -r pid process_name port; do

    # Skip if we have already processed (stopped/disabled) this PID
    if [[ -n "${processed_pids[$pid]:-}" ]]; then
        continue
    fi

    # Check if the service:port combination is in the approved list
    key="${process_name}:${port}"
    if [[ -z "${approved_list[$key]:-}" ]]; then
        # Mark as processed immediately to avoid duplicate actions
        processed_pids["$pid"]=1

        # Found an unapproved service, now find its systemd unit
        unit_file=""
        # /proc/$pid/cgroup is a reliable way to find the controlling systemd unit
        if [[ -f "/proc/$pid/cgroup" ]]; then
            # Example line: 0::/system.slice/sshd.service -> extract sshd.service
            unit_file=$(grep 'system\.slice/.*\.service' "/proc/$pid/cgroup" | sed 's#.*/##')
        fi

        if [[ -z "$unit_file" ]]; then
            echo "Warning: Could not determine systemd unit for unapproved service '${process_name}' (PID ${pid}). Manual intervention may be required." >&2
            FAIL_FLAG=1
            continue
        fi
        
        echo "Found unapproved service '${process_name}' on port ${port} (PID ${pid}), managed by unit '${unit_file}'." >&2
        echo "Stopping and disabling '${unit_file}'..." >&2

        # Stop and disable the service, checking for failures
        if ! systemctl stop "$unit_file"; then
            echo "Error: Failed to stop '${unit_file}'." >&2
            FAIL_FLAG=1
        fi

        if ! systemctl disable "$unit_file"; then
            echo "Error: Failed to disable '${unit_file}'." >&2
            FAIL_FLAG=1
        fi
    fi
done

if [[ "$FAIL_FLAG" -eq 0 ]]; then
    true
else
    false
fi