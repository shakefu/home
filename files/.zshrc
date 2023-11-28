# shellcheck shell=zsh

# Add homebrew env required for some inits to work
# This is the Mac default install
[[ ! -x /opt/homebrew/bin/brew ]] || eval "$(/opt/homebrew/bin/brew shellenv)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Put the _exa completion script in "${ZSH_CUSTOM}/completions" instead
# fpath=(${ZSH_CUSTOM}/completions ${ZSH_CUSTOM}/plugins/exa $fpath)

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
    # ansible
    brew
    colorize
    # copydir  # Deprecated in favor of copypath
    copyfile
    copypath
    # dash  # Unused
    # django  # Unused
    docker
    docker-compose
    # dotenv  # This is kind of noisy and I'm not sure I want it
    emoji-clock
    exa  # exa completions (custom)
    fzf
    git
    # gitfast  # More up to date version of git?
    git-auto-fetch
    git-extras
    git-prompt  # Adds right-hand prompt with branch
    last-working-dir
    ls  # substitute exa for ls (custom)
    pip
    # rust  # Unused
    ssh-agent
    # sudo  # Conflicts with thefuck, which is better
    # terraform
    thefuck
    themes
    # timer  # Dupes p10k behavior
    virtualenv
    # virtualenvwrapper
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

# These paths are added in reverse order, so lower paths have higher priority
_paths=(
    "/usr/local/bin"
    "/usr/local/share/bin"
    "$(brew --prefix python)/libexec/bin"
    "/usr/local/opt/coreutils/libexec/gnubin"
    "/usr/local/go/bin"
    "$HOME/go/bin"
    "$HOME/.pyenv/bin"
    "$HOME/.nodenv/bin"
    "$HOME/.goenv/shims"
    "$HOME/.goenv/bin"
    "$HOME/.local/bin"
    "$HOME/.bin"
)

# Load all paths if they haven't already
# TODO: Remove debugging
for name in "${_paths[@]}"; do
    # echo "Checking $name"
    [[ -d "$name" ]] || continue
    # echo "Found $name"
    # echo "\":$PATH:\" = *\":$name:\"*"
    if [[ ":$PATH:" = *":$name:"* ]]; then
        # echo "Path $name already in PATH, skipping"
        true
    else
        # echo "Adding $name to PATH"
        # echo "PATH=$PATH"
        # echo "PATH=$name:$PATH"
        export PATH="$name:$PATH"
    fi
    # echo "New path: $PATH"
done
# echo "Final path: $PATH"


# [ -d /usr/local/opt/coreutils/libexec/gnubin ] && export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

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
  # Default to vi for easy CLI usage
  # export EDITOR='vi'
  export EDITOR="code"
else
  # This causes issues when opening files automatically, e.g. with git or
  # fotingo, so we fall back to just vi
  # export EDITOR='mvim --remote-tab-silent'
  export EDITOR="vi"
fi


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
# alias beep='tput bel'
# TODO: Make this non-mac specific
alias bell="afplay \"/System/Library/Sounds/Submarine.aiff\""
# Sane grep defaults
alias grep='grep --binary-files=without-match --color=auto'
# Kill the most recent backgrounded process
alias kbg='kill %%;fg'
# Strip coloring
alias nocolor='sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
# Nice tree output
alias tree='tree --noreport --matchdirs -a -C -x -I ".git" -L 2'

# Docker aliases
alias dc='docker-compose'

# Git aliases
alias gpull='git pull --no-edit --prune --all --verbose'
alias gundo='git reset --soft "HEAD^"'
alias gunstage='git reset --'
alias gstaged='git diff --staged'
alias gdiff='git diff'
alias gch='git checkout'

# Helper
_unalias () {
    unalias "$@" &>/dev/null || true
}

# Remove git plugin aliases that I don't like
_unalias gbr     # git branch --remote
_unalias gsta	# git stash save
_unalias gstaa	# git stash apply
_unalias gstc	# git stash clear
_unalias gstd	# git stash drop
_unalias gstl	# git stash list
_unalias gstp	# git stash pop
_unalias gsts	# git stash show --text
_unalias gstu	# git stash --include-untracked
_unalias gstall	# git stash --all

# Remap some of them
alias gbr='git branch'
alias gsta='git diff --staged'

# Remove other zsh aliases we don't want
# These conflict with the ls plugin
_unalias l
_unalias la
_unalias ll
_unalias ls
_unalias lsa

###########
# Functions
###########

# Colors
# TODO: Relocate this if we start using it all over
_echo_blue () { printf "\033[1;34m%s\033[0m\n" "$*"; }

# Really specific usage of `exa` that I like
function ll {
    # local ignore="*/.git/*|.git|.terraform|.DS_Store|.idea|.vs_code|.git/|*/node_modules/*|node_modules"
    local ignore=".git|.terraform|.DS_Store|.idea|.vs_code|node_modules"
    local args=(
        --tree
        --ignore-glob $ignore
        --all
        --group-directories-first
        --long
        --created
        --modified
        --header
        --icons
    )
    local list_home
    local level

    # If there's arguments let's do some easy parsing for shorthand
    while [[ -n "$1" ]]; do
        if [[ "$1" =~ '^-[0-9]+$' ]]; then
            # Found hyphen-digit, strip the hyphen, set level
            args+=( --level "${1:1}" )
            level="1"
        elif [[ "$1" =~ '^[0-9]+$' ]]; then
            # Found single digit, interpret as a level
            args+=( --level "$1" )
            level="1"
        else
            # Everything else just gets slapped on
            args+=( "$1" )
        fi
        shift
    done

    # Use a default level of 2
    [[ -n "$level" ]] || args+=( --level 2 )

    # Long list command
    exa "${args[@]}"
}

# Notifier bell
function beep {
    local text="${*:-Beep!}"
    if command -v "terminal-notifier" &>/dev/null; then
        terminal-notifier -message "$text" -group "beep" -sound default >/dev/null
    elif command -v "afplay" &>/dev/null; then
        afplay "/System/Library/Sounds/Submarine.aiff"
    else
        tput bel
    fi
}

# Notifier that checks command exit
function notify {
    local cmd="$@"
    local msg=""

    echo "notify: $cmd"
    zsh -c "$cmd"
    if [[ $? -eq 0 ]]; then
        msg="✅ Success!"
    else
        msg="⛔ Failed!"
    fi

    echo -e "notify: $msg\n        $cmd"

    if command -v "terminal-notifier" &>/dev/null; then
        terminal-notifier -message "$cmd" -title "$msg" -group "${cmd%% *}" -sound default >/dev/null
    else
        echo "Finished!"
        beep
    fi
}

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

# Shorthand for git commit with a message
function gcom {
    if [[ -z "$1" ]]; then
        git commit
        return $?
    fi
    git commit -m $@
}

# Shorthand for adding files
function gadd {
    local files=$@
    if [[ -z "$files" ]]; then
        files=( "." )
    fi
    git add ${files[@]}
}

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

    # Attempt to push to the branch remote, safely
    # This checks if we have an upstream already, and adds our args
    local upstream=()
    git rev-parse --abbrev-ref --symbolic-full-name @{u} &> /dev/null || upstream=( "--set-upstream" "$remote" "$current_branch" )

    # Fetch the default branch for rebasing
    _echo_blue "Fetching $remote/$default_branch"
    git fetch --verbose --prune $(git remote) "$default_branch" || return $?

    # Attempt to rebase onto the remote default automatically
    _grebase "$remote/$default_branch" || return $?

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

# Helper rebase for DRYing up rebases
function _grebase {
    local target_branch="$1"
    # Get the current branch name
    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Attempt to rebase onto the remote default automatically
    _echo_blue "Rebasing $current_branch onto $target_branch"
    git rebase --verbose --rerere-autoupdate --autostash --allow-empty "$target_branch"
    local result=$?
    [[ $result -eq 0 ]] || git rebase --verbose --abort
    [[ $result -eq 0 ]] || return $result
}

# Interactive rebase and squash with guard rails to limit the chance of
# overwriting remote changes
function gsquash {
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

    # Attempt to push to the branch remote, safely
    # This checks if we have an upstream already, and adds our args
    local no_upstream
    git rev-parse --abbrev-ref --symbolic-full-name @{u} &> /dev/null || no_upstream="true"

    # If there's an upstream branch, we need to rebase onto it to avoid
    # obliterating upstream changes
    #
    # This causes rebase conflicts if we squashed a bunch of commits before
    # pushing which is super annoying, but we can't do anything about it
    if [[ -z "$no_upstream" && "$current_branch" != "$default_branch" ]]; then
        # Fetch the remote branch for rebasing
        _echo_blue "Fetching $remote/$current_branch"
        git fetch --verbose --prune $(git remote) "$current_branch" || return $?

        # Attempt to rebase onto the remote branch (should be a no-op in most
        # instances), but this will ensure we don't lose any changes from the remote
        # when we force push later
        _grebase "$remote/$current_branch" || return $?
    fi

    # Fetch the default branch for rebasing
    _echo_blue "Fetching $remote/$default_branch"
    git fetch --verbose --prune $(git remote) "$default_branch" || return $?

    # Attempt to rebase onto the remote default automatically
    _grebase "$remote/$default_branch" || return $?

    # Interactive rebase to squash
    git rebase --verbose --rerere-autoupdate --autostash --allow-empty --interactive "$remote/$default_branch" || return $?

    # Do the actual push, soft force for rebasing, optionally setting upstream
    _echo_blue "Pushing $current_branch to $remote"
    git push --force-with-lease --verbose ${upstream[@]} || return $?

}

function _repo_clone {
    local url="$1"
    local name="${2:-$(basename "$url" .git)}"
    local repodir
    if [[ -d "/workspaces" ]]; then
        # Handle codespaces
        repodir="/workspaces"
    else
        # Normal config
        repodir="$HOME/git"
    fi
    local dirname="$repodir/$name"
    if [[ -d "$dirname" ]]; then
        echo "Error: directory already exists: $dirname"
        return 1
    fi
    git clone "$url" "$dirname"
    local result=$?
    if [[ $result -ne 0 ]]; then
        echo "Error: could not clone repository"
        return $result
    fi
    cd "$dirname"
}

# Switch to repostory based on short name, with tab completion
function repo {
    if [[ "$1" = http* ]]; then
        echo "'$1' looks like a repository URL. Cloning..."
        _repo_clone "$1"
        return $?
    fi

    local dirname
    dirname="$HOME/$1"
    if [[ -d "$dirname" ]]; then
        cd "$dirname"
        return
    fi

    # Handle OS X style $HOME/git checkout directory
    local basedir="$HOME/git"
    dirname="$basedir/$($FD_FIND --hidden --base-directory "$basedir" --full-path --glob "**/*$1*/.git" | sed -e 's/[/]\.git[/]*$//' | sort | head -1)"
    if [[ -d "$dirname" ]]; then
        cd "$dirname"
        return
    elif [[ -d "/workspaces" ]]; then
        # Handle codespaces
        basedir="/workspaces"
        dirname="$basedir/$($FD_FIND --hidden --base-directory "$basedir" --full-path --glob "**/*$1*/.git" | sed -e 's/[/]\.git[/]*$//' | sort | head -1)"
        if [[ -d "$dirname" ]]; then
            cd "$dirname"
            return
        fi
    fi

    echo "Could not find matching repo for: $1"
    return 1
}

function _repo {
    local basedir
    if [[ -d "/workspaces" ]]; then
        # Handle codespaces
        basedir="/workspaces"
    else
        # Normal config
        basedir="$HOME/git"
    fi
    local repos=( $($FD_FIND --hidden --base-directory "$basedir" "^\.git[/]*$" | sed -e 's/[/]*\.git[/]*$//' | grep -Ev '(^\.|/\.)') )
    compadd -M 'l:|=* r:|=*' ${repos[@]}
}

compdef _repo repo

# Print the default branch name
function gdefault {
    # Find the default branch so we can rebase
    local default_branch=$(git remote show $(git remote -v | grep push | awk '{print $2}') | grep 'HEAD branch' | awk '{print $3}')
    # Fallback to "main"
    [[ -n "$default_branch" ]] || default_branch="main"
    echo "$default_branch"
}

# Grep all
unalias gr  # Override zsh plugin alias
function gr {
    [[ -z "$DEBUG" ]] || echo "all args: $@"
    local pattern="$1"
    [[ -z "$DEBUG" ]] || echo "pattern: $pattern"
    if [[ $# > 1 ]]; then
        shift
        args="$@"
    fi
    if [[ -z "$args" ]]; then
        args="."
    fi
    [[ -z "$DEBUG" ]] || echo "args: $args"
    grep -nR --exclude-dir='node_modules' --exclude-dir='.git' \
        --exclude-dir='build' --exclude-dir='bower_components' \
        --exclude-dir='coverage' --exclude-dir='.nyc_output' \
        --exclude-dir='.terraform' --exclude-dir='.eggs' \
        --exclude-dir='external' --exclude-dir='vendor' \
        --exclude='terraform.tfstate*' --exclude='*.min.*' \
        --exclude='*.js.map' --exclude='*.css.map' \
        --exclude='yarn.lock' --exclude='*.log' --exclude-dir='dist' \
        "$pattern" $args
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


###########################################
# Loading external scripts for dependencies
#
# THis has to be loaded before the devops alias because otherwise it won't find
# fotingo on the path


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load in the profile baybee
[[ ! -f ~/.profile ]] || source ~/.profile

# Load goenv
if command -v goenv &>/dev/null; then eval "$(goenv init - )"; fi

# Load pyenv
if command -v pyenv &>/dev/null; then eval "$(pyenv init - )"; fi

# Load nodenv
if command -v nodenv &>/dev/null; then eval "$(nodenv init - )"; fi

# Configure tfenv because it don't play nice with Mac aarch64
# export TFENV_ARCH=amd64
# export TFENV_AUTO_INSTALL=true
