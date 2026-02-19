#!/usr/bin/env bash

# Check if ufw is installed and active.
# 'ufw status' returns non-zero if not installed/enabled, but we also check command existence for robustness.
if ! command -v ufw &> /dev/null || ! ufw status | grep -q "Status: active"; then
    echo "Not-Applicable"
    exit 0
fi

# Get all ufw 'ALLOW IN' rules. We only care about incoming connections for listening ports.
# This awk command extracts the port/protocol part (e.g., 22/tcp, 60000:61000/udp).
ufw_rules=$(ufw status verbose | awk '/ALLOW IN/ && /^[0-9]/ {print $1}')

# Get a unique list of all listening TCP and UDP ports and their protocols.
# ss -H (no header), -l (listening), -n (numeric), -t (tcp), -u (udp)
# The awk script parses the output to get protocol and port, handling both IPv4 and IPv6 formats.
# The sort -u ensures we check each port/protocol combination only once.
listening_ports=$(ss -Hlntu | awk '{
    proto=$1
    listen_addr=$4
    split(listen_addr, addr_parts, ":")
    port=addr_parts[length(addr_parts)]
    if (port ~ /^[0-9]+$/) {
        print proto, port
    }
}' | sort -u)

# If there are no listening ports, the system is compliant by default.
if [ -z "$listening_ports" ]; then
    echo "Compliant"
    exit 0
fi

# Iterate over each listening port/protocol pair.
while read -r proto port; do
    # Normalize protocol (e.g., tcp6 -> tcp) to match ufw rule format.
    if [[ "$proto" == "tcp"* ]]; then
        proto="tcp"
    elif [[ "$proto" == "udp"* ]]; then
        proto="udp"
    fi

    port_is_allowed=false

    # Check the listening port against each firewall rule.
    while read -r rule; do
        rule_port_part=${rule%/*}
        rule_proto=${rule#*/}

        # Check if the rule's protocol matches the listening port's protocol.
        if [ "$proto" == "$rule_proto" ]; then
            # Check if the rule is for a port range.
            if [[ "$rule_port_part" == *":"* ]]; then
                start_port=${rule_port_part%:*}
                end_port=${rule_port_part#*:}
                if [ "$port" -ge "$start_port" ] && [ "$port" -le "$end_port" ]; then
                    port_is_allowed=true
                    break # Port is covered by a rule, move to the next port.
                fi
            # Check if the rule is for a single port.
            elif [ "$port" -eq "$rule_port_part" ]; then
                port_is_allowed=true
                break # Port is covered by a rule, move to the next port.
            fi
        fi
    done <<< "$ufw_rules"

    # If we've checked all rules and the port isn't allowed, it's non-compliant.
    if [ "$port_is_allowed" == false ]; then
        echo "Non-Compliant"
        exit 0
    fi
done <<< "$listening_ports"

# If the script has completed the loop, all ports are covered.
echo "Compliant"
exit 0