#!/usr/bin/env bash

sudo -V | grep "Authentication timestamp timeout" | awk '{print $5}'