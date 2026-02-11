#!/usr/bin/env bash

# Find all local mount points, but exclude the specified pseudo-filesystems.
# The `grep` filters out the mount points we want to ignore.
mount_points=$(df --local -P | awk 'NR>1 {print $6}' | grep -vE "^(/proc|/sys|/dev|/run)")

if [ -z "$mount_points" ]; then
  exit 0
fi

# Find all world-writable files/directories (-perm -0002) that do not have the sticky bit set (! -perm -1000).
# -xdev prevents find from crossing filesystem boundaries.
# -print0 uses a null character to separate results, which is safe for all filenames.
# The outer xargs then takes the null-separated list and echoes it as a single space-separated line.
# The -r flag to xargs ensures it does not run echo if find produces no output, resulting in an empty string.
# Errors (like permission denied) are redirected to /dev/null.
find $mount_points -xdev \( -perm -0002 -a ! -perm -1000 \) -print0 2>/dev/null | xargs -0 -r echo