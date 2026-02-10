#!/bin/bash

if dpkg-query -W -f='${Status}' ufw 2>/dev/null | grep -q "install ok installed"; then
  echo "Installed"
else
  echo "Not Installed"
fi