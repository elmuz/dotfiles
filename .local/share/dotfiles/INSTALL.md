# Post-installation configuration

This guide is a very personal attempt to simplify the installation of a fresh environment. I realized over the years that porting all the customizations from one system to another is a very time-consuming task that deserves a better strategy.

These notes are oriented to consistency (i.e. each new system should provide the same user experience, like a new replica) and simplicity (it should be as automatic as possible).

I am a long-time Arch Linux user, so these notes will probably only work on this distribution (or a derivative). The desktop is **[niri](https://github.com/YaLTeR/niri)** (Wayland, scrollable tiling) with the [Nord](https://www.nordtheme.com/docs/colors-and-palettes) theme.

## Notes on the system installation
At this point we assume that you have installed a very essential system. In particular:
- you have completed the wiki [installation guide](https://wiki.archlinux.org/title/Installation_guide) (i.e. partitions, `pacstrap` command, bootloader, etc).
	```shell
	# Remember to add (at least) `iwd` in the pacstrap command, e.g.:
	pacstrap -K /mnt base base-devel linux linux-firmware iwd
	```
- Network is working properly.
   + Create/edit `/etc/iwd/main.conf` by adding:
		```shell
		[General]
		EnableNetworkConfiguration=true

		[Network]
		NameResolvingService=systemd
		```
	+ Start/enable network services
		```shell
		systemctl start systemd-resolved
		systemctl start iwd
		```

- You have created your own user, with sudo privileges.

## Install the desktop environment and its configuration
The next script takes care of everything: it clones the dotfiles with `yadm`, builds `paru`, installs the curated package list, applies the system-level configuration (`system-setup.sh`), installs the Nordic theme/icons/cursors, sets up *zsh* + oh-my-zsh and neovim, and finally builds `xkcd-viewer`.

_NOTE: never trust an external script (like this one). Read it carefully before executing it blindly._

```shell
curl -sSL https://raw.githubusercontent.com/elmuz/dotfiles/main/.local/share/dotfiles/INSTALL.sh | sh
```
At this point it's better to logout and login again.

You may want to decrypt any secret-related config file using `yadm` (e.g. ssh keys):
```shell
mkdir $GNUPGHOME
yadm decrypt
```
The above command will ask for a password and will restore any file contained in `.local/share/yadm/archive`:
- SSH private keys (`~/.ssh/*.key`)
- GPG private keys + revocation certs (`~/.local/share/gnupg/`)
- AWS credentials (`~/.config/aws/credentials`)
- exercism token (`~/.config/exercism/user.json`)

The variable `$GNUPGHOME` is defined during `INSTALL.sh` script.

## System-level configuration (reference)
`INSTALL.sh` already invokes `~/.local/share/dotfiles/system-setup.sh` (step 6). It is an idempotent script that automates the `/etc`-level changes:
- **ALHP** optimized repositories (`x86-64-v4`)
- **makepkg.conf** — `-march=native` + native `RUSTFLAGS`
- **Keyboard layout** — copies `wasd` to `/usr/share/X11/xkb/symbols/`
- **Snapper** — creates `root`/`home` configs, enables timeline + cleanup timers
- **power-profiles-daemon** — enable
- **User groups** — `wheel`, `video`
- **Locale** — `en_US.UTF-8`
- **Network** — `/etc/iwd/main.conf`, `systemd-resolved` + `iwd`
- **fwupd** — firmware refresh timer

Battery charge thresholds are **not** configured — the Framework AMD 7040 handles them in BIOS.

It can also be re-run standalone (it is idempotent):
```shell
~/.local/share/dotfiles/system-setup.sh
```

## Post-install manual checklist
These cannot be automated:
1. **Fingerprint** (Framework): `fprintd-enroll` and register with `fprintd-verify`.
2. **Bitwarden**: login to your self-hosted vault (browser extension).
3. **Firefox**: log into the Mozilla account (sync restores the profile). See the Firefox notes below.
4. **Wallpaper**: if not restored from the backup, set it with `awww img ~/Pictures/wallpaper_C.jpg`.
5. **Verify**: `niri` starts, waybar renders, keyboard layout (`wasd` + options) works, `snapper list` shows snapshots.

## Extras / Appearance

### Firefox
- *Profile-sync-daemon*: enable and start `psd` with `systemctl --user {enable,start} psd`.
- Move disk cache to RAM.
  + Open `about:config` and set `browser.cache.disk.parent_directory` to `/run/user/[UID]/firefox`, where `UID` is your user's ID which can be obtained by running `id -u`.
  + Restart Firefox and go to `about:cache` to verify the new disk cache location.
- Hardware acceleration: set `media.hardware-video-decoding.force-enabled` to `true`. Verify that `vainfo` is working fine (you may need to fix `LIBVA_DRIVER_NAME` variable).

### Wallpapers
The wallpaper tool is `awww` (spawned by niri). It remembers the last image from its cache (`~/.cache/awww`) but this is volatile, so on a fresh setup:
```shell
awww img ~/Pictures/wallpaper_C.jpg
```
Place your images in `~/Pictures`:
- `wallpaper_C.jpg` — main wallpaper
- `wallpaper_R.jpg` — external monitor variant (symlink to `wallpaper_C.jpg`)

### Qt / Gtk
Apart from config files (for Gtk 2.x, 3.x, 4.x) and ENV variables (Qt5, Qt6) the following packages are required for Qt to match the Gtk2 style:
- qt5-styleplugins
- qt6gtk2

## Full restore from backup (bonus path)
The minimal recreation above works from GitHub alone. For a **fuller restore**, the rsnapshot backup on the external HDD contains `/home`, `/etc`, `/usr/local` — i.e. everything, including the bulk data that recreation can't produce.

### Backup (periodically, HDD mounted at `/mnt`)
```shell
sudo ~/.local/bin/backup-to-external-hdd.sh daily   # or: weekly / monthly
```
The rsnapshot config (`/etc/rsnapshot.conf`, tracked at `~/.config/rsnapshot/rsnapshot.conf`) keeps 7 daily + 4 weekly + 12 monthly snapshots of `/home/`, `/etc/`, `/usr/local/` under `/mnt/backups/arya/`.

### Restore (after the minimal recreation)
```shell
# HDD mounted at /mnt, then:
~/.local/share/dotfiles/restore-from-backup.sh        # newest daily.*
# or pick a specific snapshot:
~/.local/share/dotfiles/restore-from-backup.sh daily.2
```
The script restores user data + non-yadm configs, **keeps** the fresh GitHub-cloned yadm setup and re-decrypted secrets, and fixes ownership. It deliberately skips caches and `~/snapshots`.

## What is NOT backed up (by design)
These are intentionally excluded from the DR procedure — they are lightweight to re-create or restore from a remote source:
- **Firefox profile** (`~/.mozilla/`) → synced via Mozilla account; restore from remote.
- **PyCharm** → IDE profile synced online; not recreated (planned to move to Vim/FOSS IDE).
- **Caches** (`~/.cache/awww`, etc.) → volatile; wallpaper re-set via `awww img ~/Pictures/wallpaper_C.jpg`.
- **Bulk data** (`~/Videos ~/Music ~/Downloads`) → external HDD backup (rsnapshot).
- **Manual one-off tools** (zed, aws-cli-v2) → simple setup, not packaged.
- **Fingerprint** (`fprintd`) → biometric, cannot be duplicated; re-enroll by hand.
- **Identity / logins** → Bitwarden (self-hosted; external server, out of laptop DR scope).
- **Auto-generated config noise** (window sizes, `qalc.history`, Thunar `accels.scm`) → not tracked.
