# Home

This repository contains configuration files that I don't want to have to lose
so I'm putting them under version control.

## Installing

You should be able to untar the repository archive directly into your `$HOME`
directory.

<!-- TODO: Create an install script to clone the repository, symlink or copy
fils into place. Perform dependency checks, etc. -->

```bash
cd $HOME
curl -sL https://github.com/shakefu/home/archive/master.tar.gz | tar -xzv --strip-components=1
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

Install oh-my-zsh since we use it extensively:

```bash
$ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Install our zsh custom plugins (Powerlevel10k and autosuggestions):

```bash
$ sh .oh-my-zsh.git
```

Install fzf fuzzy file finder:

```bash
$ git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
$ ~/.fzf/install
```

Install thefuck:

```bash
$ sudo pip install thefuck
```

... and then [follow the
instructions](https://github.com/romkatv/powerlevel10k#fonts) to install the
font we use (MesloLGS NF).

#### Breadcrumbs

- [oh-my-zsh](https://ohmyz.sh/) - zsh plugin manager and framework
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) - super
  configurable zsh prompt theme
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) -
  nice and convenient prompt completion
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) -
  awesome colorized prompt syntax with error highlighting
- [thefuck](https://github.com/nvbn/thefuck)

### Homebrew dependencies

These are the following homebrew modules that I installed during the setup
process. <!-- Some of these are dependencies, and shouldn't need to be
installed directly. But that can be sorted out later. -->

```bash
$ brew install \
    fd \
    fzf \
    git-extras \
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

