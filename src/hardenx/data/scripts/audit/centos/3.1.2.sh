#!/bin/bash

# Run the command, capturing both stdout and stderr.
output=$(systemctl is-enabled avahi-daemon.service 2>&1)
exit_code=$?

# A non-zero exit code can mean 'disabled' or 'not found'.
# We distinguish them by checking the output. A valid status is a single
# word, while an error message is a sentence containing spaces.
if [[ $exit_code -ne 0 ]] && [[ "$output" == *" "* ]]; then
    echo "not installed"
else
    echo "$output"
fi