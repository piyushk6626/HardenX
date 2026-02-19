#!/bin/bash

if findmnt -n -o OPTIONS /var/tmp | grep -q '\bnoexec\b'; then
  echo "noexec"
else
  echo "exec"
fi