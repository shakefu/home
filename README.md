# Home

This repository contains configuration files that I don't want to have to lose
so I'm putting them under version control.

## Installing

You should be able to untar the repository archive directly into your `$HOME`
directory.

```bash
cd $HOME
curl -sL https://github.com/shakefu/home/archive/master.tar.gz | tar -xzv --strip-components=1
```

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
    python@3.8 \
    thefuck \
    tree \
    zsh-syntax-highlighting
```

<!--
*TODO: Document me better*

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
$ cd ~/.vim/bundle
$ for name in $(cat bundles.git); do git clone $name; done
```

## Breadcrumbs

### Git

Adding a subtree project:

```bash
git remote add -f vim-projectroot git@github.com:dbakker/vim-projectroot.git
git subtree add --prefix .vim/bundle/vim-projectroot vim-projectroot master --squash
```

- [Git subtree merge](https://help.github.com/articles/about-git-subtree-merges/)
- [Alternatives to git submodule](https://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/)


### Vim

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

