#!/bin/bash

if auditctl -l 2>/dev/null | grep -- '-S mount' | grep -q -- '-k '; then
  echo 'Present'
else
  echo 'Absent'
fi