#!/bin/bash

if [[ "$1" == "Disabled" ]]; then
    systemctl stop bluetooth && systemctl --now disable bluetooth
else
    true
fi