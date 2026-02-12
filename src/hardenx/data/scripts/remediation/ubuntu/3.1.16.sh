#!/bin/bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "false"
  exit 1
fi

DESIRED_STATE="$1"

if [[ "${DESIRED_STATE}" == "Not Installed" ]]; then
  if apt-get purge -y tftpd-hpa &> /dev/null; then
    echo "true"
  else
    echo "false"
  fi
else
  # The script only handles the 'Not Installed' state.
  # Any other requested state is considered a failure/unsupported operation.
  echo "false"
  exit 1
fi