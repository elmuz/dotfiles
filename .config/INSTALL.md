Packages expected already installed:
- zsh
- git

...maybe it might be helpful
```shell
sudo pacman -S --needed base-devel
```

Clone dotfiles repository
```shell
cd ~
git clone https://github.com/elmuz/dotfiles
cp -r dotfiles/.config dotfiles/.local .
```

Install `paru` in order to manage AUR packages
```shell
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

```shell
paru -S --needed ~/.config/pkglist.txt
```

## Qt / Gtk
Apart from config files (for Gtk 2.x, 3.x, 4.x) and ENV variables (Qt5, Qt6)
the followinf packages are required for Qt to match Gtk2 style:
- qt5-styleplugins
- qt6gtk2

