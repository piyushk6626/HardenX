#!/bin/bash

CMD_TO_RUN=""

if [[ -r "/etc/profile" ]]; then
    CMD_TO_RUN+="source /etc/profile >/dev/null 2>&1; "
fi

if [[ -r "/etc/bashrc" ]]; then
    CMD_TO_RUN+="source /etc/bashrc >/dev/null 2>&1; "
fi

CMD_TO_RUN+="umask"

# This command must be run as root (UID 0) to correctly evaluate
# any conditional logic for the root user within the sourced files.
bash -c "$CMD_TO_RUN"