#!/bin/bash

if mountpoint -q /var; then
  echo "true"
else
  echo "false"
fi