Install the desktop environment and its configuration
```shell
curl -sSL https://raw.githubusercontent.com/elmuz/dotfiles/main/.local/share/dotfiles/INSTALL.sh | sh
```

For wallpapers, place your images in `~/Pictures`, in particular:
- `wallpaper_L.jpg`, vertical 1080p (DELL)
- `wallpaper_C.jpg`, horizontal 1080p (DELL)
- `wallpaper_R.jpg`, horizontal 720p (laptop)

## Qt / Gtk
Apart from config files (for Gtk 2.x, 3.x, 4.x) and ENV variables (Qt5, Qt6)
the followinf packages are required for Qt to match Gtk2 style:
- qt5-styleplugins
- qt6gtk2

