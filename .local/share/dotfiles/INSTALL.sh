#!/bin/sh
# INSTALL.sh — post-install setup for a fresh Arch Linux system (niri stack).
#
# Assumes a vanilla Arch install: base, linux, linux-firmware, iwd, sudo,
# and a user with sudo privileges (see INSTALL.md).
#
# Sequence:
#   1. base tools (yadm)         5. curated packages
#   2. yadm clone (dotfiles)     6. system-setup.sh (/etc)
#   3. XDG directories           7. themes (Nordic)
#   4. paru (AUR helper)         8. shell (zsh + oh-my-zsh)
#                                9. neovim plugins
#                               10. build xkcd-viewer
#                               11. cleanup
#
# NOTE: never trust an external script. Read it before running.
# Run as the normal user (sudo is invoked internally).

set -e

info() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

NORDIC_VERS="2.2.0"
NORDIC_THEME="Nordic-bluish-accent"
NORDIC_ICON_THEME="Nordic"

# --- 1. Base tools ------------------------------------------------------
info "base tools (yadm, git)"
sudo pacman --noconfirm -Syyu
sudo pacman-key --init
sudo pacman --noconfirm -S --needed base-devel yadm

# --- 2. Dotfiles --------------------------------------------------------
info "dotfiles (yadm clone)"
cd "$HOME"
yadm clone https://github.com/elmuz/dotfiles --bootstrap

# --- 3. XDG directories ------------------------------------------------
info "XDG directories"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_VIDEOS_DIR="$HOME/Videos"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
mkdir -p "$XDG_DOCUMENTS_DIR" "$XDG_DOWNLOAD_DIR" "$XDG_MUSIC_DIR" \
         "$XDG_PICTURES_DIR" "$XDG_VIDEOS_DIR"

# --- 4. paru (AUR helper) ----------------------------------------------
info "building paru"
mkdir -p "$HOME/tools"
git clone https://aur.archlinux.org/paru.git "$HOME/tools/paru"
(cd "$HOME/tools/paru" && makepkg --noconfirm -si)

# --- 5. Curated packages -----------------------------------------------
info "installing curated packages"
grep -vE '^\s*#|^\s*$' "$XDG_CONFIG_HOME/pkgs/pkglist.txt" \
    | paru -S --needed --noconfirm -

# --- 6. System-level configuration (/etc) ------------------------------
info "system-level configuration (system-setup.sh)"
"$HOME/.local/share/dotfiles/system-setup.sh"

# --- 7. Themes / icons / cursors (Nordic) ------------------------------
info "Nordic themes, icons, cursors"
cd /tmp
curl -fLo nordic.tar.xz "https://github.com/EliverLara/Nordic/releases/download/v$NORDIC_VERS/$NORDIC_THEME.tar.xz"
tar xaf nordic.tar.xz
mkdir -p "$XDG_DATA_HOME/themes"
mv "$NORDIC_THEME" "$XDG_DATA_HOME/themes/"
rm nordic.tar.xz

info "Nordic folder icons"
tar xvf "$HOME/.local/share/dotfiles/Nordic-Folders.tar.xz"
mkdir -p "$XDG_DATA_HOME/icons"
mv "Nordic-Folders/$NORDIC_ICON_THEME" "$XDG_DATA_HOME/icons/"
rm -r Nordic-Folders

info "Nordic cursors (build)"
paru -S --needed --noconfirm inkscape xorg-xcursorgen
curl -fLo nordic.tar.gz "https://github.com/EliverLara/Nordic/archive/refs/tags/v$NORDIC_VERS.tar.gz"
tar xaf nordic.tar.gz
(cd "Nordic-$NORDIC_VERS/kde/cursors" && sh build.sh)
mkdir -p "$XDG_DATA_HOME/icons"
mv Nordic-cursors "$XDG_DATA_HOME/icons/"
rm -rf /tmp/Nordic*
paru -Rs --noconfirm inkscape xorg-xcursorgen

# --- 8. Shell (zsh + oh-my-zsh) ----------------------------------------
info "zsh + oh-my-zsh"
sudo usermod -s /bin/zsh "$USER"
sudo sh -c 'echo "export ZDOTDIR=\$HOME/.config/zsh" >> /etc/zsh/zshenv'
KEEP_ZSHRC=yes RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir -p "$XDG_DATA_HOME/zsh" "$XDG_STATE_HOME/zsh"

# --- 9. Neovim (vim-plug) ----------------------------------------------
info "neovim (vim-plug)"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo "    -> open nvim and run  :PlugInstall"

# --- 10. Build xkcd-viewer ---------------------------------------------
info "building xkcd-viewer"
mkdir -p "$HOME/projects"
git clone https://github.com/elmuz/xkcd-viewer.git "$HOME/projects/xkcd-viewer"
(cd "$HOME/projects/xkcd-viewer" && cargo build --release)
mkdir -p "$HOME/.local/bin"
cp "$HOME/projects/xkcd-viewer/target/release/xkcd-viewer" "$HOME/.local/bin/"

# --- 11. Cleanup ----------------------------------------------------------
info "cleanup"
rm -f "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.bash_logout" 2>/dev/null || true

printf '\n\033[1;32mDone.\033[0m Log out and back in.\n'
printf 'Then run  yadm decrypt  and follow the post-install checklist in INSTALL.md.\n'