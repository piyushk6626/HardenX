#!/bin/bash

if findmnt -n -o OPTIONS /dev/shm | grep -qw 'noexec'; then
  echo "true"
else
  echo "false"
fi