# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# zsh/oh-my-zsh settings

# Use default theme (for now)
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

###############
# Custom prompt
#
# Current git branch
# function _gcurbranch { git rev-parse --abbrev-ref HEAD 2>/dev/null; }

# Current git repo
# function gcurrepo { git remote show -n origin 2>/dev/null | grep Fetch \
#     | sed 's/.*\/\([^/.]*\).*/\1/'; }

# Set the current tab name to repo/branch
# _gsettab(){
#     local repo branch
#     repo=`_gcurrepo`
#     if [ -n "$repo" ]; then
#         branch=`_gcurbranch`
#         tabname "$repo/$branch"
#     else
#         tabname ""
#     fi
# }

###################
# zsh configuration

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
TIMER_FORMAT="# %d "
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


##########################
# Completion compatability

fpath=(${ZSH_CUSTOM}/completions ${ZSH_CUSTOM}/plugins/exa $fpath)

# export FPATH="$FPATH:/usr/local/etc/bash_completion.d/"
# ZSH_DISABLE_COMPFIX="true"
#
# # Load completion
# autoload -Uz compinit
# compinit -i
#
# # Load bashcompinit for some old bash completions
# autoload bashcompinit && bashcompinit
#
# # Load exa completions
# [[ -r /usr/local/etc/bash_completion.d/exa ]] && source /usr/local/etc/bash_completion.d/exa

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
    # dotenv  # This is kind of noisy and I'm not sure I want it
    emoji-clock
    fzf
    git
    # gitfast  # More up to date version of git?
    git-auto-fetch
    git-extras
    # git-prompt  # Adds right-hand prompt with branch
    last-working-dir
    ls
    pip
    rust
    ssh-agent
    # sudo  # Conflicts with thefuck, which is better
    terraform
    thefuck
    themes
    # timer  # Dupes p10k behavior
    virtualenv
    virtualenvwrapper
    zsh-autosuggestions  # https://github.com/zsh-users/zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


#####################
# oh-my-zsh overrides

# These are set for us by oh-my-zsh
HISTSIZE=100000
SAVEHIST=100000

# Completion for middle of words
# zstyle ':completion:*' matcher-list '' '' '' 'l:|=* r:|=*'  # Doesn't work
# zstyle ':completion:*' completer _complete
# zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# autoload -Uz compinit
# compinit
# zstyle ':completion:*' matcher-list '' '+m:{a-z}={A-Z}' '+m:{A-Z}={a-z}' '+l:|=* r:|=*'
# zstyle ':completion:*:complete:*:*:*' matcher-list '' '+m:{a-z}={A-Z}' '+m:{A-Z}={a-z}' '+l:|=* r:|=*'

#####################
# Shell Configuration
#####################

######
# PATH

# Append language specific paths in search order
# Add Python's site.USER_BASE bin
export PATH="$PATH:$HOME/Library/Python/3.7/bin"
# Add Homebrew unversioned Python binaries to PATH
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
# Adding user local bin directory where things get installed in Ubuntu 20.10
export PATH="$HOME/.local/bin:$PATH"
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
source $(which virtualenvwrapper_lazy.sh)
# Don't need this, script is on our path
# export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh

#################################
# FD cross platform compatability

export FD_FIND="$(command -v fd)"
[[ ! -x $(command -v fdfind) ]] || export FD_FIND="$(command -v fdfind)"

######################
# FZF fuzzy completion

# Set the trigger sequence (same as default **)
export FZF_COMPLETION_TRIGGER='**'
# Options to fzf command
export FZF_COMPLETION_OPTS='+c -x'
# Use fd (https://github.com/sharkdp/fd) instead of the default find
function _fzf_compgen_path { $FD_FIND --hidden --follow --exclude ".git" . "$1"; }
# Use fd to generate the list for directory completion
function _fzf_compgen_dir { $FD_FIND --type d --hidden --follow --exclude ".git" . "$1"; }
# Source fzf into zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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
# alias ls='ls -Gp'
# Strip coloring
alias nocolor='sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
# Use MacVim GUI
# alias vim='mvim --remote-tab-silent'
# Use colorized versions of less and more
alias less='cless'
alias more='cless'
# Nice tree output
alias tree='tree --noreport --matchdirs -a -C -x -I ".git" -L 2'

# Docker aliases
alias dc='docker-compose'

# Git aliases
alias gpull='git pull --no-edit --prune --all --verbose'
alias gundo='git reset --soft "HEAD^"'
alias gunstage='git reset --'
alias gstaged='git difftool --staged'
alias gdiff='git difftool'
alias gcom='git commit -m'
alias gadd='git add'
alias gcheck='git checkout'

# Remove git plugin aliases that I don't like
unalias gbr     # git branch --remote
unalias gsta	# git stash save
unalias gstaa	# git stash apply
unalias gstc	# git stash clear
unalias gstd	# git stash drop
unalias gstl	# git stash list
unalias gstp	# git stash pop
unalias gsts	# git stash show --text
unalias gstu	# git stash --include-untracked
unalias gstall	# git stash --all

# Remap some of them
alias gbr='git branch'
alias gsta='git difftool --staged'

# Remove other zsh aliases we don't want
# These conflict with the ls plugin
unalias l
unalias la
unalias ll
unalias ls
unalias lsa

###########
# Functions
###########

# Smart VIM if mvim is available
function vim {
    if [[ -x $(command -v mvim ) ]]; then
        mvim --remote-tab-silent $@
    else
        local cmd
        [[ ! -x /bin/vi ]] || cmd="/bin/vi"
        [[ ! -x /bin/vim ]] || cmd="/bin/vim"
        [[ ! -x /usr/bin/vim ]] || cmd="/usr/bin/vim"
        [[ ! -x /usr/local/bin/vim ]] || cmd="/usr/local/bin/vim"
        $cmd $@
    fi
}

# TODO: Relocate this if we start using it all over
_echo_blue () { printf "\033[1;34m%s\033[0m\n" "$*"; }

# Clean rebasing of branches with pull
function gpush {
    # Handle manual arguments
    if [[ -n "$@" ]]; then
        git push $@
        return $?
    fi

    # Automate our push flow

    # Get the remote name (usually "origin")
    local remote=$(git remote)
    # Get the current branch name
    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Find the default branch so we can rebase
    local default_branch=$(git remote show $(git remote -v | grep push | awk '{print $2}') | grep 'HEAD branch' | awk '{print $3}')
    # Fallback to "main"
    [[ -n "$default_branch" ]] || default_branch="main"

    # Fetch the default branch for rebasing
    _echo_blue "Fetching $remote/$default_branch"
    git fetch --verbose --prune $(git remote) "$default_branch:$default_branch" || return $?

    # Attempt to rebase onto the default automatically
    _echo_blue "Rebasing $current_branch onto $remote/$default_branch"
    git rebase --verbose --rerere-autoupdate "$default_branch"
    local result=$?
    [[ $result -eq 0 ]] || git rebase --verbose --abort
    [[ $result -eq 0 ]] || return $result

    # Attempt to push to the branch remote, safely
    # This checks if we have an upstream already, and adds our args
    local upstream=()
    git rev-parse --abbrev-ref --symbolic-full-name @{u} &> /dev/null || upstream=( "--set-upstream" "$remote" "$current_branch" )

    # Do the actual push, soft force for rebasing, optionally setting upstream
    _echo_blue "Pushing $current_branch to $remote"
    git push --force-with-lease --verbose ${upstream[@]} || return $?
}
function _gpush {
    # Completion for our gpush
    local branches=( $(git for-each-ref --format='%(refname:short)' 'refs/heads/**') )
    compadd -M 'l:|=* r:|=*' ${branches[@]}
}
compdef _gpush gpush

# Switch to repostory based on short name, with tab completion
function repo {
    cd "$HOME/$1"
}
function _repo {
    local repos=( $(fdfind --hidden --base-directory "$HOME" "^\.git$" | sed -e 's/\/\.git$//' | grep -Ev '(^\.|/\.)') )
    compadd -M 'l:|=* r:|=*' ${repos[@]}
}

compdef _repo repo

# Grep all
unalias gr  # Override zsh plugin alias
function gr {
    local pattern="$1"
    if [[ $# > 1 ]]; then
        shift
        args="$*"
    fi
    if [[ -z "$args" ]]; then
        args="."
    fi
    grep -nR --exclude-dir='node_modules' --exclude-dir='.git' \
        --exclude-dir='build' --exclude-dir='bower_components' \
        --exclude-dir='coverage' --exclude-dir='.nyc_output' \
        --exclude-dir='.terraform' --exclude-dir='.eggs' \
        --exclude-dir='external' --exclude-dir='vendor' \
        --exclude='terraform.tfstate*' --exclude='*.min.*' \
        --exclude='*.js.map' --exclude='*.css.map' \
        --exclude='yarn.lock' --exclude='*.log' "$pattern" $args
}

# Python grep
function pyg {
    local pattern="$1"
    if [[ $# > 1 ]]; then
        shift
        args="$*"
    fi
    if [[ -z "$args" ]]; then
        args="."
    fi
    grep -nR --exclude-dir node_modules --exclude-dir .eggs \
        --exclude-dir __pycache__ \
        --include *py "$pattern" $args
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load in the profile baybee
[[ ! -f ~/.profile ]] || source ~/.profile

# Load NVM if it exists
[[ ! -f ~/.nvm/nvm.sh ]] || source ~/.nvm/nvm.sh
