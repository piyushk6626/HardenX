#!/usr/bin/env bash

# Ensure required commands are available and script is run with sufficient privileges.
if ! command -v ufw &>/dev/null || ! command -v ss &>/dev/null; then
    # Silently exit false if dependencies are not met, as per instructions.
    # The problem implies a system where these tools are expected.
    echo "false"
    exit 1
fi

# Check if UFW is active. If not, the condition is not met.
# Use `ufw status` as it's lighter than `verbose` for this initial check.
# The grep must be precise to avoid matching other text.
if ! ufw status | grep -E '^Status:\s+active$' >/dev/null; then
    echo "false"
    exit 0
fi

# Get the detailed ruleset to parse.
# Redirect stderr to /dev/null to suppress potential "WARN: Rule not processed" messages.
ufw_rules_output=$(ufw status verbose 2>/dev/null)

# Get all unique listening TCP and UDP ports in the format "port/protocol".
# The awk script handles both IPv4 and IPv6 addresses by splitting on ':' and taking the last field.
# It also ensures the port is a numeric value.
listening_ports=$(ss -lntuH | awk '
    {
        proto=$1;
        split($5, addr_parts, ":");
        port=addr_parts[length(addr_parts)];
        if (port ~ /^[0-9]+$/) {
            print port"/"proto
        }
    }' | sort -u)

# If there are no listening ports, the condition (all ports are covered) is vacuously true.
if [ -z "$listening_ports" ]; then
    echo "true"
    exit 0
fi

# Iterate through each listening port and protocol combination.
while read -r port_proto; do
    port=$(echo "$port_proto" | cut -d'/' -f1)
    proto=$(echo "$port_proto" | cut -d'/' -f2)

    rule_found=0

    # Read through the UFW rules to find a match for the current port/protocol.
    while IFS= read -r rule_line; do
        # We only care about incoming rules that allow or limit traffic.
        if [[ ! "$rule_line" =~ (ALLOW|LIMIT)[[:space:]]+IN ]]; then
            continue
        fi

        # Extract the 'To' part of the rule (first field).
        rule_spec=$(echo "$rule_line" | awk '{print $1}')

        # Check if the rule is for the correct protocol.
        # This handles cases like '22/tcp' and 'ANYWHERE/tcp'.
        if [[ ! "$rule_spec" =~ /$proto$ ]]; then
            continue
        fi

        # Extract the port definition from the rule spec.
        rule_port_part=$(echo "$rule_spec" | cut -d'/' -f1)

        # Case 1: The rule is for ANY port on the correct protocol.
        if [[ "$rule_port_part" == "Anywhere" || "$rule_port_part" == "ANYWHERE" ]]; then
            rule_found=1
            break
        fi

        # Case 2: The listening port is an exact match for the rule's port.
        if [[ "$rule_port_part" == "$port" ]]; then
            rule_found=1
            break
        fi

        # Case 3: The listening port falls within a range specified by the rule.
        if [[ "$rule_port_part" =~ ^[0-9]+:[0-9]+$ ]]; then
            start_port=$(echo "$rule_port_part" | cut -d':' -f1)
            end_port=$(echo "$rule_port_part" | cut -d':' -f2)
            if [ "$port" -ge "$start_port" ] && [ "$port" -le "$end_port" ]; then
                rule_found=1
                break
            fi
        fi
    done <<< "$ufw_rules_output"

    # If no rule was found for this specific listening port, the overall check fails.
    if [ "$rule_found" -eq 0 ]; then
        echo "false"
        exit 0
    fi
done <<< "$listening_ports"

# If the script has checked all listening ports and found a rule for each one, the check succeeds.
echo "true"