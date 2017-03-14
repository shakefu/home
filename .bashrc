# shellcheck shell=bash
###############
# Jake's bashrc
#
# Version 20160210

# echo "Loading .bashrc"

# Up the file limit
ulimit -n 65536 65536 2>/dev/null


######
# PATH
#

# Adding user bin directory to PATH
export PATH="$HOME/.bin:$PATH"
# Adding opt bin to PATH
export PATH="${PATH}:/opt/local/bin"
# Add node modules to path
export PATH="$PATH:./node_modules/.bin"
export PATH="$PATH:/usr/local/share/npm/bin"
# Add ruby gems to path
export PATH="$PATH:/usr/local/opt/ruby/bin"
# Node path
export NODE_PATH="$NODE_PATH:./node_modules"
# Rust path
export PATH="$HOME/.cargo/bin:$PATH"


###########
# Variables
#

# Fix for Python not being able to detect terminal width
export COLUMNS

# Make dockerize speak
export DOCKERIZE_SAY=true

########
# Prompt
#

# Faster, bash based prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1
_prompt() {
    # Colors
    local white="\033[1;37m"
    local reset="\033[0m"
    local yel="\033[0;33m"
    local blue="\033[0;34m"
    local cyan="\033[0;36m"
    local red="\033[0;31m"

    # Function which sets the tab name to "repo/branch (program)"
    _gsettab

    # Print the current directory (last two dirs)
    local curdir=$(basename "$(pwd)")
    local pardir=$(basename "$(dirname "$(pwd)")")
    echo -en "$blue\xe2\x95\x92===$reset ";
    if [ "$pardir" != "/" ]; then echo -en "$yel/$reset$pardir"; fi
    if [ "$curdir" != "/" ]; then echo -en "$yel/$white$curdir$reset"
    else echo -en "$yel/$reset"; fi
    echo -en " $blue==$reset "

    # Print the current repository and branch
    local repo=$(git remote show -n origin 2>/dev/null | grep Fetch \
        | sed 's/.*\/\([^/.]*\).*/\1/')
    if [ -n "$repo" ]; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -z "$branch" ]; then branch="detached"; fi
        echo -en "$cyan$repo$yel/$reset$branch"
        echo -en " $blue==$reset "
    fi

    # Print the virtualenv if we have one
    local venv="${VIRTUAL_ENV##*/}"
    if [ -n "$venv" ]; then
        local venvcolor="$cyan"
        # Change the color of the venv name if it doesn't match the repo
        if [ "$venv" != "$repo" ]; then venvcolor="$red"; fi
        echo -en "$yel($venvcolor$venv$yel)$reset"
        echo -en " $blue==$reset "
    fi

    # If we're in a repo, print the current git status
    if [ -n "$repo" ]; then
        # Get the status, with color, and use sed to add a colored blue line at
        # the front and a space, to make it line up and look pretty
        local status=$(git -c color.ui=always status -s \
            | sed 's/^/\\033[0;34m\\xe2\\x94\\x82 /')
        if [ -n "$status" ]; then
            echo
            echo -en "$status"
        fi
    fi
}
export PS1="\$(_prompt)\n\$ "


##############
# Bash History
#

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=10000                    # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"


#########
# Aliases
#

# General aliases
alias ls='ls --color=auto -p'
alias grep='grep --binary-files=without-match --color=auto'
alias beep='tput bel'
alias nocolor='sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
alias kbg='kill %%;fg'
alias bell="afplay \"/Applications/iMovie.app/Contents/Resources/iMovie '08 Sound Effects/Bell Buoy.mp3\""

# Docker aliases
alias dc='docker-compose'
alias dps='docker ps'
alias dclean='docker rmi $(docker images -q -f dangling=true)'

function dkill () {
    docker kill $*
    docker rm $*
}


#############
# Git helpers
#

# Git aliases
alias gpull='git pull --no-edit'
alias gundo='git reset --soft "HEAD^"'
alias gunstage='git reset --'
alias gstaged='git diff --staged'

# Remove merged branches
gclean(){ git pull --prune; git branch --merged | egrep -v '(^\*|master)' | xargs git branch -d; }

# Git methods with tab completion
gcom(){ local msg="$1"; shift; git commit -m "$msg" $*; }
gdiff(){ git diff $*; }
gadd(){ git add $*; }
# Tab completion for unstaged files
_complete_unstaged(){ _complete "`git status -s | awk '{print $2}'`"; }
complete -F _complete_unstaged gcom
complete -F _complete_unstaged gadd
complete -F _complete_unstaged gdiff

gcheck(){
    git checkout $*
    # Clean up compiled files for switching branches
    # find . -name '*.pyc' | xargs rm 2>/dev/null
}
gmerge(){
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    local target=${@: -1}
    if [ -z "$branch" ]; then branch="detached"; fi
    echo "Merging '$target' into '$branch' ..."
    if [[ -z "$(git branch -a | grep "remotes/origin/$branch")" ]]; then
        echo "Remote upstream does not exist. Attempting rebase instead ..."
        git rebase $target
    else
        git merge --no-edit $*;
    fi
}
grebase(){ git rebase $*; }
gforward(){ git fetch origin $1:$1; }
gbranch(){ git branch $*; }
gpush(){ git push $*; }
# Tab completion for branch name
_gbranch(){ _complete "`git branch -a | sed 's/remotes\/origin\/\(.*\)/\1/' \
    | sed 's/^[* ] //' | sed '/^HEAD/d'`"; }
complete -F _gbranch gbranch
complete -F _gbranch gpush
complete -F _gbranch gcheck
complete -F _gbranch gmerge
complete -F _gbranch gforward

# Update the current branch with master
# alias gup='git checkout master && git pull && gclean'
gup(){
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    git checkout master && \
    echo -n "git pull: " && git pull && \
    echo -n "gclean: " && gclean
    if [[ -z "$branch" ]]; then
        echo "gup: Couldn't find original branch."
    fi
    git checkout $branch && \
    echo -n "git pull: " && git pull && \
    echo -n "gmerge master: " && gmerge master
}

# Run pyflakes against uncommitted changes
gflake(){
    if ! pyflakes --version &>/dev/null; then
        echo "Pyflakes is not installed."
        return 1
    fi
    git status -suno | awk '{print $2}' | grep '\.py$' | xargs pyflakes
}

# Current git branch
_gcurbranch(){ git rev-parse --abbrev-ref HEAD 2>/dev/null; }

# Current git repo
_gcurrepo(){ git remote show -n origin 2>/dev/null | grep Fetch \
    | sed 's/.*\/\([^/.]*\).*/\1/'; }

# Set the current tab name to repo/branch
_gsettab(){
    local repo branch
    repo=`_gcurrepo`
    if [ -n "$repo" ]; then
        branch=`_gcurbranch`
        tabname "$repo/$branch"
    else
        tabname ""
    fi
}

###########
# Functions
#

# Work on an about.me project
awork(){
    if ! cd ~/github.com/aboutdotme/$1 2>/dev/null; then
        echo "No such project."
        return
    fi
    workon $1 2>/dev/null
    tabname $1
}
# Tab completion for awork helper
_awork(){ _complete "`/bin/ls -1 ~/github.com/aboutdotme/`"; }
complete -F _awork awork

# Helper for switching to a project directory and starting the venv
gwork(){
    if ! cd ~/github.com/shakefu/$1 2>/dev/null; then
        echo "No such project."
        return
    fi
    tabname $1
    workon $1 2>/dev/null
}
# Tab completion for gwork helper
_gwork(){ _complete "`/bin/ls -1 ~/github.com/shakefu`"; }
complete -F _gwork gwork

# Easy tab completion
_complete(){
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$*"

    # `COMP_CWORD -eq 1` only allows comparison for the first word, but we want
    # to allow completion for whatever the last word is
    # if [[ ${cur} == * && ${COMP_CWORD} -eq 1 ]] ; then
    if [[ ${cur} == * ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

# Grep all
gr(){
    pattern=$1
    shift
    grep -nR --exclude-dir='node_modules' --exclude-dir='.git' \
        --exclude-dir='build' --exclude-dir='bower_components' \
        --exclude-dir='coverage' --exclude-dir='.nyc_output' \
        --exclude-dir=test* "$pattern" $* .
}

# Python grep
pyg(){
    local pattern args
    pattern=$1
    shift
    args=$*
    if [ -z "$args" ]; then
        args=.
    fi
    grep -nR --exclude-dir node_modules --include=*py "$pattern" $args
}

# JS and HTML grep
pgr(){
    local pattern args
    pattern=$1
    shift
    args=$*
    if [ -z "$args" ]; then
        args=.
    fi
    grep -nR --exclude-dir '.meteor' --exclude-dir amd-compiled \
        --exclude=*.min.js --exclude=modernizr*.js --exclude-dir docs \
        --exclude-dir build-files --exclude-dir core --exclude-dir jquery \
        --exclude-dir bower --exclude-dir vendor --exclude-dir closure \
        --exclude-dir ckeditor --exclude-dir node_modules \
        --include=*.coffee --include=*.js --include=*.html "$pattern" $args
}

# Vim as Python `more`
pym(){
    vim $*
}

# Vim-based more'ing
MORE=`which more`
more() {
    if [ -z "$*" ]; then
        $MORE;
    else
        for file in $*;
        do
            if [[ "$file" =~ .*py$ ]]; then
                pym $file;
            else
                $MORE $file;
            fi;
        done;
    fi
}

# Beep beep beep
beeps() {
    for i in `seq 3`;
    do
        tput bel;
    done
}

# Name Terminal.app and iTerm 2 tabs
function tabname {
  printf "\e]1;$1\a"
}


#################
# VIM KEYBINDINGS
#

# Switch to vim mode
# set -o vi


##########################
# PYTHON VIRTUALENVWRAPPER
#

# startup virtualenv-burrito
if [ -f $HOME/.venvburrito/startup.sh ]; then
    . $HOME/.venvburrito/startup.sh
fi

export PATH="$HOME/.yarn/bin:$PATH"


##################
# RUST ENVIRONMENT
if [[ -f "$HOME/.cargo/env" ]]; then
    source $HOME/.cargo/env
fi
