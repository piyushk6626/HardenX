#!/bin/bash

if rpm -q sudo &>/dev/null; then
  echo "Installed"
else
  echo "Not Installed"
fi