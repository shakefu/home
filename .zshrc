# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/jacobalheid/.oh-my-zsh"

# zsh/oh-my-zsh settings

# Use default theme (for now)
ZSH_THEME="robbyrussell"
# Use default custom directory
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# Treat - and _ the same for history search
HYPHEN_INSENSITIVE="true"
# Show dots for completion so it doesn't look like a lock up
COMPLETION_WAITING_DOTS="true"
# Don't auto update zsh
DISABLE_AUTO_UPDATE="true"
# Ignore untracked files for prompts (speeds things up)
DISABLE_UNTRACKED_FILES_DIRTY="true"
# Don't overwrite custom titles
DISABLE_AUTO_TITLE="true"
# Show stamps instead of history number
HIST_STAMPS="yyyy-mm-dd"  # Doesn't seem to work?
# Options for timer plugin
TIMER_FORMAT="# %d"
TIMER_PRECISION="3"
# Options for zsh-autosuggestions plugin
ZSH_AUTOSUGGEST_USE_ASYNC="true"
# Fuzzy completion, we might want to export this variable
FZF_BASE="/usr/local/opt/fzf/"

#########
# History

# These duplicate some of the oh-my-zsh options, but explicit is good
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_NO_FUNCTIONS
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt NO_HIST_BEEP

# zsh plugins
plugins=(
    ansible
    brew
    colorize
    copydir
    copyfile
    dash
    django
    docker
    docker-compose
    dotenv
    emoji-clock
    fzf
    git
    # gitfast  # More up to date version of git?
    git-auto-fetch
    git-extras
    git-prompt
    last-working-dir
    pip
    rust
    ssh-agent
    # sudo  # Conflicts with thefuck, which is better
    terraform
    thefuck
    themes
    timer
    virtualenv
    virtualenvwrapper
    zsh-autosuggestions  # https://github.com/zsh-users/zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh


#####################
# oh-my-zsh overrides

# These are set for us by oh-my-zsh
HISTSIZE=100000
SAVEHIST=100000


#####################
# Shell Configuration
#####################

######
# PATH

# Append language specific paths in search order
# Add Python's site.USER_BASE bin
export PATH="$PATH:/Users/jacobalheid/Library/Python/3.7/bin"
# Add Homebrew unversioned Python binaries to PATH
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
# Adding user bin directory to PATH as top priority
export PATH="$HOME/.bin:$PATH"

###########
# Variables

# Fix for Python not being able to detect terminal width
export COLUMNS
# Disable virtualenv prefixing
export VIRTUAL_ENV_DISABLE_PROMPT=1

################
# Shell settings

# Force the language to be utf-8
export LANG=en_US.UTF-8

# Toggle editor based on SSH status
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim --remote-tab-silent'
fi

####################
# Python Virtualenvs

# Use the default directory, explicitly
export WORKON_HOME=$HOME/.virtualenvs
# Anything that is done with mkproject ends up in tmp
export PROJECT_HOME=$HOME/tmp
# Lazy load virtualenvwrapper commands for quicker shells
source /usr/local/bin/virtualenvwrapper_lazy.sh
# Don't need this, script is on our path
# export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh

#########
# Aliases
#########

# General aliases
alias beep='tput bel'
alias bell="afplay \"/Applications/iMovie.app/Contents/Resources/iMovie '08 Sound Effects/Bell Buoy.mp3\""
# Sane grep defaults
alias grep='grep --binary-files=without-match --color=auto'
# Kill the most recent backgrounded process
alias kbg='kill %%;fg'
# ls with good formatting
alias ls='ls -Gp'
# Strip coloring
alias nocolor='sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
# Use MacVim GUI
alias vim='mvim --remote-tab-silent'
# Use colorized versions of less and more
alias less='cless'
alias more='cless'
# Nice tree output
alias tree='tree --noreport --matchdirs -a -C -x -I ".git" -L 2'

# Docker aliases
alias dc='docker-compose'

# Git aliases
alias gpull='git pull --no-edit'
alias gundo='git reset --soft "HEAD^"'
alias gunstage='git reset --'
alias gstaged='git diff --staged'
alias gdiff='git diff'
alias gcom='git commit -m'
alias gadd='git add'
alias gpush='git push'
alias gcheck='git checkout'

###########
# Functions
###########

# Grep all
unalias gr  # Override zsh plugin alias
function gr {
    local pattern="$1"
    shift
    grep -nR --exclude-dir='node_modules' --exclude-dir='.git' \
        --exclude-dir='build' --exclude-dir='bower_components' \
        --exclude-dir='coverage' --exclude-dir='.nyc_output' \
        --exclude-dir='.terraform' --exclude-dir='.eggs' \
        --exclude='terraform.tfstate*' \
        --exclude='yarn.lock' --exclude='*.log' "$pattern" $* .
}

# Python grep
function pyg {
    local pattern="$1"
    shift
    local args="$*"
    if [ -z "$args" ]; then
        args="."
    fi
    grep -nR --exclude-dir node_modules --exclude-dir .eggs \
        --exclude-dir __pycache__ \
        --include=*py "$pattern" $args
}

# JS and HTML grep
function pgr {
    local pattern="$1"
    shift
    local args="$*"
    if [ -z "$args" ]; then
        args="."
    fi
    grep -nR --exclude-dir '.meteor' --exclude-dir amd-compiled \
        --exclude=*.min.js --exclude=modernizr*.js --exclude-dir docs \
        --exclude-dir build-files --exclude-dir core --exclude-dir jquery \
        --exclude-dir bower --exclude-dir vendor --exclude-dir closure \
        --exclude-dir ckeditor --exclude-dir node_modules \
        --include=*.coffee --include=*.js --include=*.html "$pattern" $args
}

# Name Terminal.app and iTerm 2 tabs
function tabname {
  printf "\e]1;$1\a"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
