# Post-installation configuration

This guide is a very personal attempt to simplify the installation of a fresh environment. I realized over the years that porting all the customizations from one system to another is a very time-consuming task that deserves a better strategy.

These notes are oriented to consistency (i.e. each new system should provide the same user experience, like a new repica) and simplicity (it should be the most automatic as possible).

I am fan and a long-time user of Arch Linux. So these notes will probably only work on this distribution (or a derivative of it).

## Install the desktop environment and its configuration

At this point we assume that you have installed a very essential system. In particular:
- you have completed the wiki [installation guide](https://wiki.archlinux.org/title/Installation_guide) (i.e. partitions, `pacstrap` command, bootloader, etc).
- You have created your own user, with sudo privileges.

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

## Optimized repositories
If your system is somewhat recent, you can enable [ALHP](https://somegit.dev/ALHP/ALHP.GO) optimized repository.

Verify that `x86-64-v3` is supported by checking:

```shell
/lib/ld-linux-x86-64.so.2 --help
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
- Move disk cache to RAM. Open `about:config` and set `browser.cache.disk.parent_directory` to `/run/user/[UID]/firefox`,
  where `UID` is your user's ID which can be obtained by running `id -u`. Open `about:cache` to verify the new disk cache
  location. 

### Wallpapers
Place your images in `~/Pictures`, in particular the following are hard-coded in Sway configuration file:
- `wallpaper_C.jpg`, horizontal 2160p (DELL)
- `wallpaper_R.jpg`, horizontal 1080p (laptop)

### Qt / Gtk
Apart from config files (for Gtk 2.x, 3.x, 4.x) and ENV variables (Qt5, Qt6)
the following packages are required for Qt to match Gtk2 style:
- qt5-styleplugins
- qt6gtk2

## Redshift
- `gammastep` applied via sway config

## Custom script (executed via systemd service) to set battery charging thresholds.
Verify by `cat /sys/class/power_supply/BAT0/charge_control_{start,end}_threshold`
