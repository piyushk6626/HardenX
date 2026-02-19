#!/bin/bash

if modprobe -c | grep -q '^\s*install\s\+dccp\s\+/bin/true\s*$'
then
  echo "disabled"
else
  echo "enabled"
fi