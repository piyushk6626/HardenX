#!/bin/bash

if rpm -q xorg-x11-server-common &> /dev/null; then
  echo "Installed"
else
  echo "Not Installed"
fi