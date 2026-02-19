#!/bin/bash

if rpm -q aide &>/dev/null; then
  echo "Installed"
else
  echo "Not Installed"
fi