#!/usr/bin/env bash

# Search for the pam_faillock.so configuration across all files in /etc/pam.d/
# and extract the numerical value of the 'deny' parameter.
# The -h flag for grep suppresses filenames in the output.
# The -oP flags use Perl-compatible regex to extract only the matching number.
# `\K` resets the start of the reported match, so we only get the digits.
# `tail -n 1` ensures we only get one value if it's defined multiple times.
deny_value=$(grep -rsh "pam_faillock.so" /etc/pam.d/ | grep -oP 'deny=\K\d+' | tail -n 1)

# If the deny_value variable is empty (meaning the parameter wasn't found),
# the :-0 expansion will substitute 0. Otherwise, it will echo the found value.
echo "${deny_value:-0}"