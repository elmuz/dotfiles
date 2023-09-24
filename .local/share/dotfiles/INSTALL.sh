# /bin/sh

# Some basic requirements (`git` comes with `yadm`)
sudo pacman --noconfirm -Syyu
sudo pacman-key --init
sudo pacman --noconfirm -S --needed base-devel yadm

# Install paru in order to manage AUR packages
mkdir tools && cd tools
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg --noconfirm -si

# Dotfiles
cd ~
yadm clone https://github.com/elmuz/dotfiles

# This should help keeping clean the home directory
source .config/zsh/.zshenv
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_STATE_HOME

# Install required packages
cd ~
paru -S --needed --noconfirm - < ~/.local/share/dotfiles/pkglist.txt

# Extra cosmetics (e.g. themes and cursors)
NORDIC_VERS="2.2.0"
cd /tmp
curl -fLo nordic.tar.xz https://github.com/EliverLara/Nordic/releases/download/v$NORDIC_VERS/Nordic.tar.xz
tar xaf nordic.tar.xz
mkdir $XDG_DATA_HOME/themes
mv Nordic $XDG_DATA_HOME/themes/
rm nordic.tar.xz
paru -S --needed --noconfirm inkscape xorg-xcursorgen
curl -fLo nordic.tar.gz https://github.com/EliverLara/Nordic/archive/refs/tags/v$NORDIC_VERS.tar.gz
tar xaf nordic.tar.gz
cd Nordic-$NORDIC_VERS/kde/cursors
sh build.sh
mkdir $XDG_DATA_HOME/icons
mv Nordic-cursors $XDG_DATA_HOME/icons/
cd $HOME
rm -rf /tmp/Nordic*
paru -Rs --noconfirm inkscape xorg-xcursorgen

# Shell steroids
sudo usermod -s /bin/zsh $USER
sudo sh -c 'echo "export ZDOTDIR=\$HOME/.config/zsh" >> /etc/zsh/zshenv'
KEEP_ZSHRC=yes RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir -p $XDG_DATA_HOME/zsh
mkdir -p $XDG_STATE_HOME/zsh

# Fix (neo)vim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# open vim and run `:PlugInstall`

# Fix keyboard
sudo cp .local/share/X11/xkb/symbols/wasd /usr/share/X11/xkb/symbols/

# Battery charging thresholds
sudo cp .local/share/dotfiles/charge-thresholds.s* /etc/systemd/system/
sudo systemctl enable charge-thresholds

# Clean bash stuff
rm -r .bash*

