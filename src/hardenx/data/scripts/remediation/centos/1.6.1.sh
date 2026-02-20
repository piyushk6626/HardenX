#!/bin/bash

if [[ "$1" == "mounted" ]]; then
    cat <<'EOF'
MANUAL INTERVENTION REQUIRED
This script has detected a configuration that requires a separate partition.
Please follow the steps below to provision and mount a new partition.
WARNING: These steps are destructive and can lead to data loss. Ensure you have backups.

1.  Identify an available block device:
    Use 'lsblk' or 'fdisk -l' to find an unused disk or partition space.
    # lsblk

2.  Partition the device (replace /dev/sdX with your device):
    # fdisk /dev/sdX
    - Use 'n' to create a new partition.
    - Accept the defaults for a single primary partition.
    - Use 'w' to write the changes to the disk.

3.  Format the new partition (replace /dev/sdX1 with your new partition):
    # mkfs.ext4 /dev/sdX1

4.  Create a mount point:
    # mkdir /new_mount_point

5.  Find the UUID of the new partition for stable mounting:
    # blkid /dev/sdX1

6.  Add the new partition to /etc/fstab to mount it on boot. Edit the file:
    # nano /etc/fstab
    Add a line similar to this, using the UUID from the previous step:
    UUID=<your-uuid-from-blkid>  /new_mount_point  ext4  defaults,nodev,nosuid  0 2

7.  Mount the new partition and verify:
    # mount -a
    # df -h

8.  (If applicable) Migrate existing data to the new partition:
    # rsync -av /path/to/old_data/ /new_mount_point/

After completing these manual steps, rerun your compliance checks.
EOF
    echo "false"
fi