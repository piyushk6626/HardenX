#!/bin/bash

if dpkg-query -W -f='${Status}' ldap-utils 2>/dev/null | grep -q "ok installed"; then
  echo "Installed"
else
  echo "Not Installed"
fi