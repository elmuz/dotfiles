# System configuration restoring dotfiles

This guide assumes a working base system, with user and `sudo` privileges.

## Install the desktop environment and its configuration

In general, never trust an external script (like this one). Read it carefully before executing
it blindly.

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

## Extras / Appearance

### Firefox
- Profile-sync-daemon.  It's enough to enable and start `psd` with `systemctl --user {enable,start} psd`.
- Move disk cache to RAM. Open `about:config` and set `browser.cache.disk.parent_directory` to `/run/user/[UID]/firefox`,
  where `UID` is your user's ID which can be obtained by running `id -u`. Open `about:cache` to verify the new disk cache
  location. 

## Wallpapers
Place your images in `~/Pictures`, in particular the following are hard-coded in Sway configuration file:
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
