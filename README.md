# Home

This repository contains configuration files that I don't want to have to lose
so I'm putting them under version control.

## Installing

The easiest install is to download the release for your operating system
and architecture and run it.

```bash
export VERSION=1.2.0
curl -fsSL https://github.com/shakefu/home/releases/download/v${VERSION}/home-v${VERSION}-darwin-amd64.tar.gz | tar xz > home
./home setup
```

Alternatively, you can clone this repository, and then run the `home.go`
command to install everything.

```bash
git clone https://github.com/shakefu/home.git
cd home
go run home.go setup
```

#### Breadcrumbs

- [oh-my-zsh](https://ohmyz.sh/) - zsh plugin manager and framework
- [powerlevel10k](https://github.com/romkatv/powerlevel10k) - super
  configurable zsh prompt theme
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) -
  nice and convenient prompt completion
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) -
  awesome colorized prompt syntax with error highlighting
- [exa](https://the.exa.website/) - Better ls 
- [thefuck](https://github.com/nvbn/thefuck) - Autofix commands
- [fd](https://github.com/sharkdp/fd) - Better find
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
- [SwitchResX](https://www.madrau.com/) - Allow Mac to use nonstandard resolutions
- [MAS](https://github.com/mas-cli/mas) - Mac app store CLI
