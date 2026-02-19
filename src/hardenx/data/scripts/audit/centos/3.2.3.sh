#!/bin/bash

if rpm -q talk &>/dev/null; then
  echo "Installed"
else
  echo "Not Installed"
fi