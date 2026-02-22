#!/usr/bin/env bash

if [[ "$#" -ne 1 || -z "$1" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

GROUP_NAME="$1"
CONF_FILE="/etc/audit/auditd.conf"

if [[ ! -f "${CONF_FILE}" ]]; then
    echo "false"
    exit 1
fi

# Escape for sed replacement string: backslash and ampersand
SED_GROUP_NAME=$(printf '%s\n' "${GROUP_NAME}" | sed -e 's/[\/&]/\\&/g')
RC=1

# Check if log_group parameter exists (and is not commented out)
if grep -qE '^\s*log_group\s*=' "${CONF_FILE}"; then
    # Parameter exists, so update it
    sed -i "s/^\s*log_group\s*=.*/log_group = ${SED_GROUP_NAME}/" "${CONF_FILE}"
    RC=$?
else
    # Parameter does not exist, so append it
    echo "log_group = ${GROUP_NAME}" >> "${CONF_FILE}"
    RC=$?
fi

if [[ "${RC}" -eq 0 ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi