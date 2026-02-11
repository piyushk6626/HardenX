#!/bin/bash

# This script is designed to be run with root privileges.

CONFIG_FILE="/etc/modprobe.d/freevxfs.conf"
CONFIG_CONTENT="install freevxfs /bin/true"

# The first positional argument ($1) is accepted but not used in this logic,
# as the requested action is exclusively to disable the module.

if echo "${CONFIG_CONTENT}" > "${CONFIG_FILE}" 2>/dev/null; then
    echo "true"
else
    echo "false"
fi