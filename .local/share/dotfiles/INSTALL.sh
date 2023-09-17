# /bin/sh

# Some basic requirements
sudo pacman --noconfirm -Syyu
sudo pacman-key --init
sudo pacman --noconfirm -S --needed base-devel yadm

# Dotfiles
cd ~
yadm clone https://github.com/elmuz/dotfiles

# This should help keeping clean the home directory
source .config/zsh/.zshenv
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_DATA_HOME

# Install paru in order to manage AUR packages
mkdir tools && cd tools
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg --noconfirm -si

# Install required packages
cd ~
paru -S --needed --noconfirm - < ~/.local/share/dotfiles/pkglist.txt

# Shell steroids
sudo usermod -s /usr/bin/zsh $USER
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv .oh-my-zsh $HOME/.local/share/oh-my-zsh
sudo sh -c 'echo "export ZDOTDIR=\$HOME/.config/zsh" > /etc/zsh/zshenv'

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
