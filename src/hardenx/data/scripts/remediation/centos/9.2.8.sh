#!/usr/bin/env bash

# This script is designed for situations where a duplicate group name is detected.
# Automated remediation is high-risk, so this script takes no action
# other than logging the event and returning a failure status.

if [[ -z "$1" ]]; then
  logger -t "RemediationPolicy" -p user.warn "Manual intervention required: A duplicate group was detected, but the group name was not provided to the script."
else
  logger -t "RemediationPolicy" -p user.warn "Manual intervention required: Duplicate group name found: '$1'. No automatic remediation was performed."
fi

# Always exit with a non-zero status to indicate failure/manual action required.
false