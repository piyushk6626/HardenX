#!/bin/bash

# This script is intended to be called with one argument, which it will ignore.
# Its purpose is to acknowledge a remediation request that requires manual intervention.

logger -p user.warn -t "security-remediation" "Manual intervention required to create a separate /var/tmp partition. Automated remediation is not possible for this task."

# Always exit with a 'false' status to indicate that remediation was not performed.
false