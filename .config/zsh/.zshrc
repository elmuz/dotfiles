# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$XDG_DATA_HOME/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="afowler"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

bindkey '^H' backward-kill-word

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# TERM
export TERM="xterm-256color"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Aliases
alias zrc="vim $XDG_CONFIG_HOME/zsh/.zshrc"
alias zenv="vim $XDG_CONFIG_HOME/zsh/.zshenv"
alias act="source venv/bin/activate"
alias hyprconf="vim $XDG_CONFIG_HOME/hypr/hyprland.conf"
alias swayconf="vim $XDG_CONFIG_HOME/sway/config"
alias niriconf="vim $XDG_CONFIG_HOME/niri/config.kdl"
alias la7="mpv https://d15umi5iaezxgx.cloudfront.net/LA7/CLN/HLS-B/Live_1280x720_.m3u8"
alias wget=wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"
alias r="ranger"
alias nord='print -P "┌──────────────┐\n│ %F{#2e3440}████%f #2e3440 │\n│ %F{#3b4252}████%f #3b4252 │\n│ %F{#434c5e}████%f #434c5e │\n│ %F{#4c566a}████%f #4c566a │\n│ %F{#d8dee9}████%f #d8dee9 │\n│ %F{#e5e9f0}████%f #e5e9f0 │\n│ %F{#eceff4}████%f #eceff4 │\n│ %F{#8fbcbb}████%f #8fbcbb │\n│ %F{#88c0d0}████%f #88c0d0 │\n│ %F{#81a1c1}████%f #81a1c1 │\n│ %F{#5e81ac}████%f #5e81ac │\n│ %F{#bf616a}████%f #bf616a │\n│ %F{#d08770}████%f #d08770 │\n│ %F{#ebcb8b}████%f #ebcb8b │\n│ %F{#a3be8c}████%f #a3be8c │\n│ %F{#b48ead}████%f #b48ead%f │\n└──────────────┘"'

# SSH agent
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
