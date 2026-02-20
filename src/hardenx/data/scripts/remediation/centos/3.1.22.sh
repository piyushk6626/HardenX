#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "false"
    exit 1
fi

if ! firewall-cmd --state &>/dev/null; then
    echo "false"
    exit 1
fi

APPROVED_SERVICES_STR="$1"

ACTIVE_ZONE=$(firewall-cmd --get-active-zones | head -n 1)
if [ -z "$ACTIVE_ZONE" ]; then
    echo "false"
    exit 1
fi

# Remove all existing services from the runtime configuration
CURRENT_SERVICES=$(firewall-cmd --zone="$ACTIVE_ZONE" --list-services) || { echo "false"; exit 1; }
for service in $CURRENT_SERVICES; do
    firewall-cmd --zone="$ACTIVE_ZONE" --remove-service="$service" &>/dev/null || { echo "false"; exit 1; }
done

# Add the approved services to the runtime configuration
IFS=',' read -r -a services_to_add <<< "$APPROVED_SERVICES_STR"
for service in "${services_to_add[@]}"; do
    trimmed_service=$(echo "$service" | xargs) # Trim whitespace
    if [ -n "$trimmed_service" ]; then
        firewall-cmd --zone="$ACTIVE_ZONE" --add-service="$trimmed_service" &>/dev/null || { echo "false"; exit 1; }
    fi
done

# Make the runtime configuration permanent
firewall-cmd --runtime-to-permanent &>/dev/null || { echo "false"; exit 1; }

echo "true"
exit 0