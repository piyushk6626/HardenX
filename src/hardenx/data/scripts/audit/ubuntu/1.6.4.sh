#!/bin/bash

if findmnt -n -o OPTIONS --target /var/tmp | grep -q '\bnoexec\b'; then
  echo 'enabled'
else
  echo 'disabled'
fi