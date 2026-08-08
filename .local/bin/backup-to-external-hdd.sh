#!/bin/sh
# backup-to-external-hdd.sh
# Run the rsnapshot backup onto the external HDD.
#
# Backs up /home, /etc, /usr/local to /mnt/backups/arya/ (see rsnapshot.conf).
# Retention: daily x7, weekly x4, monthly x12.
#
# Usage:
#   sudo ./backup-to-external-hdd.sh [interval]
#     interval: daily | weekly | monthly   (default: daily)
#
# Note: rsnapshot must run as root to read /home and /etc.
# The config to use lives at /etc/rsnapshot.conf (copy from
# ~/.config/rsnapshot/rsnapshot.conf if missing).

set -e

INTERVAL="${1:-daily}"
MOUNT_POINT="/mnt"
SNAP_ROOT="/mnt/backups"
CONF="/etc/rsnapshot.conf"

# 1. mount check
mountpoint -q "$MOUNT_POINT" || { echo "ERROR: external HDD not mounted at $MOUNT_POINT"; exit 1; }

# 2. snapshot root
[ -d "$SNAP_ROOT" ] || { echo "Creating $SNAP_ROOT"; sudo mkdir -p "$SNAP_ROOT"; }

# 3. config check
[ -f "$CONF" ] || {
    echo "ERROR: $CONF missing."
    echo "Install it with:  sudo cp ~/.config/rsnapshot/rsnapshot.conf $CONF"
    exit 1
}

# 4. run the backup
echo "Running rsnapshot  $INTERVAL  ->  $SNAP_ROOT"
sudo rsnapshot -c "$CONF" "$INTERVAL"

echo
echo "Backup complete. Verify:"
echo "  ls -la $SNAP_ROOT/$INTERVAL.*/arya/home"