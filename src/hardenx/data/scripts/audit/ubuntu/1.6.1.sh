#!/bin/bash

var_tmp_source=$(findmnt --noheadings --output SOURCE --target /var/tmp)
var_source=$(findmnt --noheadings --output SOURCE --target /var)

if [[ -n "$var_tmp_source" && "$var_tmp_source" != "$var_source" ]]; then
    echo "Enabled"
else
    echo "Disabled"
fi