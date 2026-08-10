# Post-installation configuration

This guide is a very personal attempt to simplify the installation of a fresh environment. I realized over the years that porting all the customizations from one system to another is a very time-consuming task that deserves a better strategy.

These notes are oriented to consistency (i.e. each new system should provide the same user experience, like a new repica) and simplicity (it should be the most automatic as possible).

I am fan and a long-time user of Arch Linux. So these notes will probably only work on this distribution (or a derivative of it).

## Notes on the system installation
At this point we assume that you have installed a very essential system. In particular:
- you have completed the wiki [installation guide](https://wiki.archlinux.org/title/Installation_guide) (i.e. partitions, `pacstrap` command, bootloader, etc).
	```shell
	# Remember to add (at least) `iwd` in the pacstrap command, e.g.:
	pacstrap -K /mnt base base-devel linux linux-firmware iwd
	```
-  Network is working properly.
   + Create/edit `/etc/iwd/main.conf `by adding:
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
The next script will take care of the management of AUR repository (by building `paru`), it will install *zsh* and its plugins and finally it will setup and configure [Sway](https://swaywm.org/) desktop environment (with all the [Nord](https://www.nordtheme.com/docs/colors-and-palettes) themes).

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
The above command will ask for a password and will restore any file contained in `.local/share/yadm/archive`.
The variable `$GNUPGHOME` is defined during `INSTALL.sh` script.

### System-level configuration (Phase 3)
`INSTALL.sh` handles user-space setup. The `/etc`-level changes are automated by a separate idempotent script:
```shell
~/.local/share/dotfiles/system-setup.sh
# or: curl -sSL https://raw.githubusercontent.com/elmuz/dotfiles/main/.local/share/dotfiles/system-setup.sh | sh
```
It configures ALHP repos, `makepkg.conf`, the `wasd` keyboard layout, snapper, power-profiles, user groups, locale, iwd and fwupd. Battery charge thresholds are **not** set — the Framework AMD 7040 handles them in BIOS.

## Optimized repositories
If your system is somewhat recent, you can enable [ALHP](https://somegit.dev/ALHP/ALHP.GO) optimized repository.

Verify that `x86-64-v3` (or `x86-64-v4`) is supported by checking:

```shell
/lib/ld-linux-x86-64.so.2 --help
```

There's some strange issue regarding PGP signature verification. In order to fix this, you need to manually import the key by doing:
```bash
curl https://somegit.dev/ALHP/alhp-keyring/raw/branch/master/master/anonfunc.asc -o anonfunc.asc
gpg --import anonfunc.asc 
```

Install the keyring and the mirrorlist:

```bash
paru -S alhp-keyring alhp-mirrorlist
```

Update `/etc/pacman.conf` with the new repositories:

```editorconfig
[core-x86-64-v3]
Include = /etc/pacman.d/alhp-mirrorlist

[extra-x86-64-v3]
Include = /etc/pacman.d/alhp-mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist
...
```

Update package database and upgrade:

```shell
pacman -Suy
```

## Optimized binaries build
Edit `/etc/makepkg.conf` with the following arguments:
```
# Remove `-mtune` flag and replace `-march`
CFLAGS="-march=native -O2 -pipe ..."
...
RUSTFLAGS="-C opt-level=2 -C target-cpu=native"
```



## Graphics
If system is based on modern Intel hardware you can enable GuC / HuC firmware loading (see [this](https://wiki.archlinux.org/title/Intel_graphics#Enable_GuC_/_HuC_firmware_loading) ArchLinux wiki page for details).
```commandline
paru -S --needed --noconfirm - < ~/.local/share/dotfiles/pkglist-intel.txt
echo "options i915 enable_guc=2" | sudo tee /etc/modprobe.d/i915.conf
sudo mkinitcpio -P
```

## Extras / Appearance

### Firefox
- *Profile-sync-daemon*d.  It's enough to enable and start `psd` with `systemctl --user {enable,start} psd`.
- Move disk cache to RAM.
  +  Open `about:config` and set `browser.cache.disk.parent_directory` to `/run/user/[UID]/firefox`, where `UID` is your user's ID which can be obtained by running `id -u`.
  + Restart Firefox and go to `about:cache` to verify the new disk cache location.
- Hardware acceleration: set `media.hardware-video-decoding.force-enabled` to `true`. Verify that `vainfo` is working fine (you may need to fix `LIBVA_DRIVER_NAME` variable).

### Wallpapers
Place your images in `~/Pictures`, in particular the following are hard-coded in Sway configuration file:
- `wallpaper_C.jpg`, horizontal 2160p (4k external monitor)
- `wallpaper_R.jpg`, horizontal 1080p (laptop)

### Qt / Gtk
Apart from config files (for Gtk 2.x, 3.x, 4.x) and ENV variables (Qt5, Qt6)
the following packages are required for Qt to match Gtk2 style:
- qt5-styleplugins
- qt6gtk2

## Redshift
- `gammastep` applied via sway config

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
- **Manual one-off tools** (zed, aws-cli-v2, nebula-sync) → simple setup, not packaged.
- **Fingerprint** (`fprintd`) → biometric, cannot be duplicated; re-enroll by hand.
- **Identity / logins** → Bitwarden (self-hosted; external server, out of laptop DR scope).
- **Auto-generated config noise** (window sizes, `qalc.history`, Thunar `accels.scm`) → not tracked.
