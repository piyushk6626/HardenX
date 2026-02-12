#!/bin/bash

if [[ $# -ne 1 || "$1" != "Not Installed" ]]; then
  echo "false"
  exit 1
fi

if apt-get purge -y rsh-client &>/dev/null; then
  echo "true"
  exit 0
else
  echo "false"
  exit 1
fi