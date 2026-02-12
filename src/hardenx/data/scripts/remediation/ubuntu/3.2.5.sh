#!/bin/bash

if [[ "$1" != "Not Installed" ]]; then
  echo "false"
  exit 0
fi

if apt-get purge -y ldap-utils &>/dev/null; then
  echo "true"
else
  echo "false"
fi