#!/bin/bash

if findmnt --noheadings /dev/shm &>/dev/null; then
  echo 'mounted'
else
  echo 'not mounted'
fi