#!/usr/bin/env bash

file_list=$(find /var/log -type f -perm /027 -print0 | xargs -0)

if [[ -n "${file_list}" ]]; then
  echo "${file_list}"
fi