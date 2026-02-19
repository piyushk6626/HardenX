#!/usr/bin/env bash

sudo sudo -V | grep 'Authentication timestamp timeout' | awk '{print $4}'
