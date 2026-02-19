#!/bin/bash

if rpm -q audit &>/dev/null && rpm -q audit-libs &>/dev/null; then
  echo "installed"
else
  echo "not installed"
fi