#!/bin/bash

if rpm -q pam &>/dev/null; then
  echo "Installed"
else
  echo "Not Installed"
fi