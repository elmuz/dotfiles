#!/bin/sh
# restore-from-backup.sh
# Selective "full restore" from an rsnapshot backup on the external HDD.
#
# When to use:  AFTER a fresh install + INSTALL.sh (packages, dotfiles,
# system config, yadm decrypt). This script is the "bonus" layer — it brings
# back the user DATA and non-yadm configs that a recreation alone can't
# reproduce (Documents, Pictures, Music, Videos, Downloads, projects,
# browser profiles, etc.).
#
# The rsnapshot config backs up /home, /etc, /usr/local to /mnt/backups/arya/.
# We restore /home but deliberately KEEP the freshly-cloned yadm setup and the
# re-decrypted secrets (they're newer than the backup). The /etc layer is
# handled by system-setup.sh (Phase 3); a small optional fallback is included.
#
# Usage:
#   ./restore-from-backup.sh [snapshot] [user]
#     snapshot: an interval dir, e.g. daily.0, weekly.0 (default: newest daily.*)
#     user:     target user (default: $USER)
#
# Prerequisite: external HDD mounted at /mnt.

set -e

SNAP_ROOT="/mnt/backups"
TARGET_USER="${2:-$USER}"

# Detect newest snapshot if none given
if [ -z "${1:-}" ]; then
    NEWEST="$(ls -d "$SNAP_ROOT"/daily.* 2>/dev/null | sort | tail -1 || true)"
    SNAP_NAME="$(basename "$NEWEST")"
else
    SNAP_NAME="$1"
fi
SNAP="$SNAP_ROOT/$SNAP_NAME/arya"

[ -n "$SNAP_NAME" ] || { echo "ERROR: no daily.* snapshot found in $SNAP_ROOT"; exit 1; }
[ -d "$SNAP/home" ] || { echo "ERROR: backup not found at $SNAP/home"; echo "  Is the HDD mounted at /mnt? Was rsnapshot ever run?"; exit 1; }

echo "Source snapshot : $SNAP"
echo "Restoring to    : /home/$TARGET_USER"
echo

# --- user data + non-yadm configs -------------------------------------
# Keep the fresh-install state for things that are already handled by yadm:
#   .cache, .local/state           -> transient, rebuilt on next login
#   .local/share/yadm, .config/yadm -> keep the fresh GitHub clone (newer)
#   .ssh, .gnupg                    -> restored via  yadm decrypt  instead
sudo rsync -aHAX --info=progress2 \
    --exclude '.snapshots' \
    --exclude '.cache' \
    --exclude '.local/state' \
    --exclude '.local/share/yadm' \
    --exclude '.config/yadm' \
    --exclude '.ssh' \
    --exclude '.gnupg' \
    "$SNAP/home/$TARGET_USER/" "/home/$TARGET_USER/"

# --- optional /etc fallback -------------------------------------------
# system-setup.sh (Phase 3) is the authoritative source for these. Uncomment
# only if you want to also pull them from the backup (e.g. Phase 3 not run).
# for f in pacman.conf makepkg.conf; do
#     [ -f "$SNAP/etc/$f" ] && { echo "Restoring /etc/$f"; sudo cp "$SNAP/etc/$f" "/etc/$f"; }
# done

# --- ownership ---------------------------------------------------------
echo "Fixing ownership ..."
sudo chown -R "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER"

echo
echo "Done."
echo "Next steps:"
echo "  1. Log out and back in."
echo "  2. If secrets not yet restored:  yadm decrypt"
echo "  3. Review:  yadm status   (should be clean; untracked DATA is expected)"
echo "  4. Wallpaper if needed:  awww img ~/Pictures/wallpaper_C.jpg"