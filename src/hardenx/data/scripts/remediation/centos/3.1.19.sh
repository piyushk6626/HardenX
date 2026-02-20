#!/bin/bash

if [[ "${1:-}" != "not installed" ]]; then
  echo "false"
  exit 1
fi

# If package is not installed, the state is already correct.
if ! rpm -q xinetd &>/dev/null; then
  echo "true"
  exit 0
fi

# Package is installed, find package manager and attempt removal.
PKG_MANAGER=""
if command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
  PKG_MANAGER="yum"
else
  # No supported package manager found to perform removal.
  echo "false"
  exit 1
fi

if "${PKG_MANAGER}" -y remove xinetd &>/dev/null; then
  echo "true"
else
  echo "false"
fi