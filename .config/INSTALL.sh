#!/bin/sh

# Some basic requirements
# sudo pacman -S --needed base-devel zsh git

# Dotfiles
# cd ~
# git clone https://github.com/elmuz/dotfiles
# p -r dotfiles/.config dotfiles/.local .

# Install paru in order to manage AUR packages
mkdir tools && cd tools
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Install required packages
cd ~
paru -S --needed - < ~/.config/pkglist.txt

# Fix (neo)vim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# open vim and run `:PlugInstall`

# Shell steroids
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp -r .oh-my-zsh $XDG_DATA_HOME/oh-my-zsh
sudo sh -c 'echo "export ZDOTDIR=\$HOME/.config/zsh" > /etc/zsh/zshenv'

