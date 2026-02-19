#!/bin/bash

if findmnt -n -o OPTIONS /var/tmp | grep -qw 'nosuid'; then
  echo "true"
else
  echo "false"
fi