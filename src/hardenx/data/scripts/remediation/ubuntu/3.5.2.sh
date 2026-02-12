#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

USERNAME="$1"
OVERRIDE_DIR="/etc/systemd/system/chrony.service.d"
OVERRIDE_FILE="${OVERRIDE_DIR}/override.conf"

# Create the override directory
if ! mkdir -p "$OVERRIDE_DIR"; then
    echo "false"
    exit 1
fi

# Create the override file with the specified content
cat > "$OVERRIDE_FILE" << EOF
[Service]
User=$USERNAME
EOF

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Reload systemd manager configuration
if ! systemctl daemon-reload; then
    echo "false"
    exit 1
fi

# Restart the chrony service
if ! systemctl restart chrony; then
    echo "false"
    exit 1
fi

echo "true"
exit 0