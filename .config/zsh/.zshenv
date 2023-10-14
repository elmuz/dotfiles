# Some XDG fixes
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state

# XDG user dirs
export XDG_DESKTOP_DIR="$HOME/Downloads"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_VIDEOS_DIR="$HOME/Videos"

# Zsh ties the PATH variable to a path array.
# This allows you to manipulate PATH by simply modifying the path array.
typeset -U path PATH
path=(~/.local/bin $path)
export PATH

#export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export HISTFILE="$XDG_STATE_HOME/$(basename $SHELL)"/history
export ZSH_COMPDUMP=$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
export PYENV_ROOT=$XDG_DATA_HOME/pyenv
export LESSKEY="$XDG_CONFIG_HOME"/less/lesskey
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_DATA_HOME"/themes/Nordic/gtk-2.0/gtkrc
export QT_QPA_PLATFORMTHEME=gtk2
export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME"/docker-machine
export SSB_HOME="$XDG_DATA_HOME"/zoom
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export DVDCSS_CACHE="$XDG_DATA_HOME"/dvdcss
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials,
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export ANSIBLE_HOME="${XDG_DATA_HOME}/ansible"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_HOME}/ansible/galaxy_cache"

# Oh my Zsh
export ZSH="$XDG_DATA_HOME/oh-my-zsh"

# Default programs
export TERMINAL="alacritty"
export BROWSER="firefox"
export EDITOR="nvim"
export VISUAL="nvim"

# LIBVA
export LIBVA_DRIVER_NAME="iHD"
