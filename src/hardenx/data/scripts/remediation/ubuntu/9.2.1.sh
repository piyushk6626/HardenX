#!/bin/bash

if [[ "$1" == "on" ]]; then
    if pwconv &>/dev/null; then
        true
    else
        false
    fi
else
    false
fi