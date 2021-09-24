# Add .local/bin to PATH
export PATH=$HOME/.local/bin:$PATH

# Some XDG fixes
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share

export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export HISTFILE="$XDG_DATA_HOME"/zsh/history
export ZSH_COMPDUMP=$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
export LESSKEY="$XDG_CONFIG_HOME"/less/lesskey
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME"/docker-machine
export SSB_HOME="$XDG_DATA_HOME"/zoom

# Oh my Zsh
ZSH="$XDG_DATA_HOME/oh-my-zsh"

# Default programs
export TERMINAL="alacritty"
export BROWSER="firefox"
export EDITOR="nvim"
export VISUAL="nvim"

# LIBVA
export LIBVA_DRIVER_NAME="iHD"
