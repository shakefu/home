# Home

This repository contains configuration files that I don't want to have to lose
so I'm putting them under version control.

## Installing

### Install Pathogen

[Pathogen](https://github.com/tpope/vim-pathogen) is the VIM plugin manager.

```bash
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```

### Install Powerline fonts

Powerline fonts are used by various plugins and *vimrc* and they're nice.

```bash
$ git clone git@github.com:powerline/fonts.git
$ cd fonts
$ ./install.sh
```

### ZSH and its dependencies

This section talks about setting up zsh, yeyh.

#### Install oh-my-zsh

It's our plugin manager and framework for our shell.

```bash
$ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Install our zsh custom plugins

There's a script for that. There's a few of them.

```bash
$ sh .oh-my-zsh.git
```

#### Install home repository

This needs to be done after oh-my-zsh and plugins installed because it overwrites some things.

You should be able to untar the repository archive directly into your `$HOME`
directory.

<!-- TODO: Create an install script to clone the repository, symlink or copy
fils into place. Perform dependency checks, etc. -->

```bash
cd $HOME
curl -sL https://github.com/shakefu/home/archive/master.tar.gz | tar -xzv --strip-components=1
```

#### Install `exa`, the nice ls replacement

This works with our `ls` plugin to make everything shiny.

`brew install exa`

You also need to add the completion scripts for exa for zsh to find them.

```bash
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/completions
curl -L https://raw.githubusercontent.com/ogham/exa/master/contrib/completions.zsh > ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/completions/_exa
```

This path is specifically called out and loaded onto our `fpath` variable which
is where we look for custom functions to autoload.

#### Install fzf fuzzy file finder

Help make searching the filesystem trees faster and easier than before.

```bash
$ git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
$ ~/.fzf/install
```

#### Install thefuck:

Sometimes you just want to curse.

```bash
$ sudo pip install thefuck
```

#### Install `fd` based on the appropriate instructions for the platform

*fd* is awesome and super fast and makes find just be outdated.

[fd installation](https://github.com/sharkdp/fd#installation) is here for all
platforms.

#### Install fonts

We need them for their unicode symbol goodness.

[MesloLGS NF font family](https://github.com/romkatv/powerlevel10k#fonts) is
our baby for the Powerlevel10k prompt.

#### Install pygments

This is used if `less` and `more` are aliased to their colored variants.

```bash
sudo pip install pygments
```

#### Install icdiff

This has to be installed from GitHub directly because they haven't published
the main version yet.

- [icdiff on GitHub](https://github.com/jeffkaufman/icdiff)

#### Install nvm

We use node.js for some tooling, bleh.

- [nvm-sh/nvm](https://github.com/nvm-sh/nvm) script for easy install.

#### Install commitizen

Makes nice commit messages that comply with the standard.

- [commitizen on GitHub](https://github.com/commitizen/cz-cli)

This wants node.js v12, so, something like:

```bash
# Use node.js 12
nvm install v12
nvm use v12
# Install "globally"
npm install -g commitizen
# Link the command from the nvm bin/ into our PATh so we don't have to screw
# with nvm each time we want to use it
ln -s "$(which cz)" "$HOME/.bin/cz"
```

#### Install pre-commit

This runs pre-commit scripts for us with git and makes it easier to not
forget to run local tests and formatters and linters. It's helpful.

- [pre-commit GitHub](https://github.com/pre-commit/pre-commit)

```bash
# Install via pip globally
sudo pip install pre-commit
```

#### Breadcrumbs

- [oh-my-zsh](https://ohmyz.sh/) - zsh plugin manager and framework
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) - super
  configurable zsh prompt theme
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) -
  nice and convenient prompt completion
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) -
  awesome colorized prompt syntax with error highlighting
- [exa](https://the.exa.website/)
- [thefuck](https://github.com/nvbn/thefuck)
- [fd](https://github.com/sharkdp/fd)

### Homebrew dependencies

These are the following homebrew modules that I installed during the setup
process. <!-- Some of these are dependencies, and shouldn't need to be
installed directly. But that can be sorted out later. -->

```bash
$ brew install \
    cmake \
    exa \
    fd \
    fzf \
    git-extras \
    icdiff \
    macvim \
    pygments \
    python \
    thefuck \
    tree \
    zsh-syntax-highlighting
```

<!-- TODO: Document me better* -->
<!--

Full list of brew install:

```
$ brew ls
autoconf
cmake
cscope
fd
fortune
fzf
gdbm
git-extras
libyaml
lua
macvim
openssl@1.1
pam_reattach
pkg-config
pygments
python
python@3.8
readline
ruby
sqlite
terraform
thefuck
tree
xz
zsh-syntax-highlighting
```
-->

### Vim plugins and bundles

After installing the files into your `$HOME`, navigate to `$HOME/.vim/bundle`.
There you should see a `bundles.git` file with the repository links for the needed
plugins for my vimrc.

Use the following snippet to clone all the bundles needed:

```bash
$ cp -r ./.vim/bundle ~/.vim/bundle
$ cd ~/.vim/bundle
$ for name in $(cat bundles.git); do git clone $name; done
```

#### Breadcrumbs

- [Pathogen](https://github.com/tpope/vim-pathogen) - We would add this as a
  subtree but it conflicts with the existing .vim path
  - [src](https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim) -
    To be used with `curl [src] > .vim/autoload/pathogen.vim`.
- [ProjectRoot](https://github.com/dbakker/vim-projectroot) - Handy switching
  the current working directory
- [CtrlP](https://github.com/ctrlpvim/ctrlp.vim) - Easily open files within the
  current project
- [Jedi Vim](https://github.com/davidhalter/jedi-vim) - Awesome Python
  autocompletion
- [Dockerfile.vim](https://github.com/ekalinin/Dockerfile.vim) - Syntax
  highlighting for Dockerfiles
- [Tabmerge](https://github.com/vim-scripts/Tabmerge) - Merging tabs made easy
- [Supertab](https://github.com/ervandew/supertab) - Awesome tab completion
- [YAJS](https://github.com/othree/yajs.vim) - ES6 syntax highlighting and more

