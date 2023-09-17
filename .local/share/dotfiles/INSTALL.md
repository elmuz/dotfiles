# System configuration restoring dotfiles

This guide assumes a working base system, with user and `sudo` privileges.

## Install the desktop environment and its configuration

In general, never trust an external script (like this one). Read it carefully before executing
it blindly.

```shell
curl -sSL https://raw.githubusercontent.com/elmuz/dotfiles/main/.local/share/dotfiles/INSTALL.sh | sh
```

You may want to decrypt any secret-related config file using `yadm` (e.g. ssh keys):
```shell
mkdir $GNUPGHOME
yadm decrypt
```
The above command will ask for a password and will restore any file contained in `.local/share/yadm/archive`.
The variable `$GNUPGHOME` is defined during `INSTALL.sh` script.

## Extras

For wallpapers, place your images in `~/Pictures`, in particular:
- `wallpaper_C.jpg`, horizontal 1080p (DELL)
- `wallpaper_R.jpg`, horizontal 720p (laptop)

## Qt / Gtk
Apart from config files (for Gtk 2.x, 3.x, 4.x) and ENV variables (Qt5, Qt6)
the following packages are required for Qt to match Gtk2 style:
- qt5-styleplugins
- qt6gtk2

## Redshift
- `gammastep` applied via sway config

## Custom script (executed via systemd service) to set battery charging thresholds.
Verify by `cat /sys/class/power_supply/BAT0/charge_control_{start,end}_threshold`
