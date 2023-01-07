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

Install requires packages
```shell
paru -S --needed - < ~/.config/pkglist.txt
```
Fix (Neo)vim
```shell
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

For wallpapers, place your images in `~/Pictures`, in particular:
- `wallpaper_L.jpg`, vertical 1080p (DELL)
- `wallpaper_C.jpg`, horizontal 1080p (DELL)
- `wallpaper_R.jpg`, horizontal 720p (laptop)

Shell steroids
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp -r .oh-my-zsh $XDG_DATA_HOME/oh-my-zsh
sudo sh -c 'echo "export ZDOTDIR=\$HOME/.config/zsh" > /etc/zsh/zshenv'
```

Fix keyboard
```shell
sudo cp .local/share/X11/xkb/symbols/wasd /usr/share/X11/xkb/symbols/
```

## Qt / Gtk
Apart from config files (for Gtk 2.x, 3.x, 4.x) and ENV variables (Qt5, Qt6)
the followinf packages are required for Qt to match Gtk2 style:
- qt5-styleplugins
- qt6gtk2

