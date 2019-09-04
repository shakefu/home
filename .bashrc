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

#### Append language specific paths in search order
# Add Python's site.USER_BASE bin
export PATH="$PATH:/Users/jacobalheid/Library/Python/3.7/bin"
# Adding opt bin to PATH
# export PATH="$PATH:/opt/local/bin"
# Add node modules to path
# export PATH="$PATH:./node_modules/.bin"
# export PATH="$PATH:/usr/local/share/npm/bin"
# Add ruby gems to path
export PATH="$PATH:/usr/local/opt/ruby/bin"
# Node path
# export NODE_PATH="$NODE_PATH:./node_modules"

#### Prepend priority paths in reverse search order

# Add local bin directory to PATH
# export PATH="/usr/local/bin:$PATH"
# export PATH="/usr/local/sbin:$PATH"
# Add Homebrew unversioned Python binaries to PATH
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
# Adding user bin directory to PATH
export PATH="$HOME/.bin:$PATH"


###########
# Variables
#

# Fix for Python not being able to detect terminal width
export COLUMNS

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
alias beep='tput bel'
alias bell="afplay \"/Applications/iMovie.app/Contents/Resources/iMovie '08 Sound Effects/Bell Buoy.mp3\""
alias grep='grep --binary-files=without-match --color=auto'
alias kbg='kill %%;fg'
alias ls='ls -Gp'
alias nocolor='sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
alias vim='mvim --remote-tab-silent'

# Docker aliases
alias dc='docker-compose'
alias dps='docker ps'
alias dclean='docker rmi $(docker images -q -f dangling=true)'

function dkill () {
    docker kill $*
    docker rm $*
}

function axtest () {
    # Check the current directory has a docker-compose and is a git repository
    if [[ ! -f docker-compose.yml ]]; then
        echo "No docker-compose.yml present."
        return 1
    elif [[ ! -d .git ]]; then
        echo "Not a git repository."
        return 1
    fi

    local name

    # Get the current directory name
    name="$(basename $(pwd))"

    # Get anything before a hyphen in the name, which is most likely to be the
    # individual service name
    name=${name%%-*}

    echo "Running tests for service $name"

    # Run tests with docker-compose
    local msg="Tests passed!"
    local cmd="docker-compose up --build --force-recreate --remove-orphans
        --exit-code-from $name"
    $cmd
    # Set the notification message based on the exit code of docker-compose
    if [[ "$?" -ne "0" ]]; then
        msg="Tests failed."
    fi

    if [ $(which terminal-notifier) ]; then
        # Pop up a notification on Mac OS X ... comment this out if your'e not
        # on a Mac
        terminal-notifier -title "$name" -message "$msg" -group "axiom" \
            -remove "axiom" &>/dev/null
    fi
}
# Make pytest available in subshells
export -f axtest

function axwatch() {
    watcher axtest
}

function pytest() {
    local args="${*:-.}"

    # Only run this if we're in a virtaulenv
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "Error: No virtualenv"
        return 1
    fi

    # Find the package name
    local name
    name="$(find . -depth 2 -name '__init__.py' -type f | grep -Ev 'test|fixtures' | head -1 | cut -d / -f 2)"
    if [ -z "$name" ]; then
        echo "Error: Could not resolve package name"
        return 1
    fi

    if [ -z "$(pip freeze -l | grep 'nose==')" ]; then
        echo "Error: Missing nosetests package"
        return 1
    fi

    local msg="flake8 failed!"
    # Find and set the notifier commmand
    local notify="$(which terminal-notifier)"
    # Or use a nullop
    notify=${notify:-":"}

    # Flake things
    if [ $(which flake8) ]; then
        flake8 $name test/

        # Notify and early exit if flake8 fails
        if [[ "$?" -ne "0" ]]; then
            $notify -title "$name" -message "$msg" -group "axiom" \
                -remove "axiom" &>/dev/null
            return 1
        fi
    fi

    # nose-timer plugin switches
    if [ -n "$(pip freeze -l | grep 'nose-timer==')" ]; then
        args="--with-timer --timer-top-n 3 --timer-ok 10ms $args"
    fi

    # coverage plugin switches
    if [ -n "$(pip freeze -l | grep 'coverage==')" ]; then
        args="--with-coverage --cover-package $name $args"
    fi

    # Final command
    cmd="nosetests $args"
    echo "$cmd"

    # Notifier message to use
    msg="Tests passed!"

    # Execute!
    $cmd

    # Set the notification message based on the exit code of nosetests
    if [[ "$?" -ne "0" ]]; then
        msg="Tests failed."
    fi

    # Pop up a notification on Mac OS X ... comment this out if your'e not
    # on a Mac
    $notify -title "$name" -message "$msg" -group "axiom" \
        -remove "axiom" &>/dev/null
}
# Make pytest available in subshells
export -f pytest

function pywatch() {
    watcher pytest
}

function watcher() {
    local test_cmd
    test_cmd='echo "error: No test command."'
    test_cmd="${1:-$test_cmd}"
    if [ ! $(which fswatch) ]; then
        echo "error: fswatch not installed"
        return 1
    fi

    if [ -z "$(find . -name 'Dockerfile' -depth 1)" ]; then
        echo "error: Dockerfile not present, you sure this is a service?"
        return 1
    fi

    local paths
    paths="$(grep -E '^COPY \w+/ ./\w+/$' Dockerfile | awk '{print $2}' | sort -u)"

    echo "Waiting for file changes..."

    local cmd
    cmd='echo -e "$(date)\nRunning tests..."'
    cmd="$cmd ; $test_cmd"
    cmd="$cmd ; echo -e 'Waiting for file changes...\n\n'"

    # fswatch -ro -e '.*' -i '.*\.py$' *.py $paths | xargs -o -n1 -I{} bash -c 'declare -f pytest ; pytest'
    fswatch -ro -e '.*' -i '.*\.py$' *.py $paths | xargs -o -n1 -I{} bash -c "$cmd"
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
    find . -name '*.pyc' | xargs rm
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
    if [[ "$branch" == "master" ]]; then
        echo -n "git pull: " && git pull && \
        echo -n "gclean: " && gclean && return
    fi

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
    if flake8 --version &>/dev/null; then
        cmd="flake8"
    elif ! pyflakes --version &>/dev/null; then
        cmd="pyflakes"
    else
        echo "Neither pyflakes nor flake8 is installed."
        return 1
    fi
    git status -suno | awk '{print $2}' | grep '\.py$' | xargs $cmd
}

# Tag current commit
gtag(){
    local tag="$*"
    git tag -am "Release $tag" v$tag
    git tag -ln
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
twork(){
    if ! cd ~/github.com/turo/$1 2>/dev/null; then
        echo "No such project."
        return
    fi
    if [[ -n "$1" ]]; then
        workon $1 2>/dev/null
        tabname $1
    fi
}
# Tab completion for twork helper
_twork(){ _complete "`/bin/ls -1 ~/github.com/turo/`"; }
complete -F _twork twork

# Work on an Axiom Exergy project
awork(){
    if ! cd ~/github.com/axiomexergy/$1 2>/dev/null; then
        echo "No such project."
        return
    fi
    workon $1 2>/dev/null
    tabname $1
}
# Tab completion for awork helper
_awork(){ _complete "`/bin/ls -1 ~/github.com/axiomexergy/`"; }
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
        --exclude-dir='.terraform' --exclude-dir='.eggs' \
        --exclude='terraform.tfstate*' \
        --exclude='yarn.lock' --exclude='*.log' "$pattern" $* .
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
    grep -nR --exclude-dir node_modules --exclude-dir .eggs \
        --include=*py "$pattern" $args
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
# Uncomment this to actually load it, otherwise it slows down loading new shells
# if [ -f $HOME/.venvburrito/startup.sh ]; then
#     . $HOME/.venvburrito/startup.sh
# fi

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/tmp
source /Users/jacobalheid/Library/Python/3.7/bin/virtualenvwrapper.sh

##########
# YARN BIN
# export PATH="$HOME/.yarn/bin:$PATH"

##########
# NODE NVM

# export NVM_DIR="$HOME/.nvm"
# source /usr/local/opt/nvm/nvm.sh

#############
# PYENV SHELL
#
# if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
