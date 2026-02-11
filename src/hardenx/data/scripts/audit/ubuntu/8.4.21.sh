#!/bin/bash

if augenrules --check &>/dev/null; then
  echo "same"
else
  echo "different"
fi