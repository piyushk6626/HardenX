#!/bin/bash

if augencmp --check &>/dev/null; then
  echo "same"
else
  echo "different"
fi