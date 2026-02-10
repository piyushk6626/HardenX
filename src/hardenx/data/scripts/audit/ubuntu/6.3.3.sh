#!/bin/bash

if dpkg-query -W -f='${Status}' libpam-pwquality 2>/dev/null | grep -q "ok installed"; then
  echo "Installed"
else
  echo "Not Installed"
fi