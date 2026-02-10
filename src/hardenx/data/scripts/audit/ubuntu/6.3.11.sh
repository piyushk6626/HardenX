#!/bin/bash

grep -oP '^\s*difok\s*=\s*\K\d+' /etc/security/pwquality.conf