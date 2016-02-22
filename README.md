# Home

This repository contains configuration files that I don't want to have to lose
so I'm putting them under version control.

## Breadcrumbs

### Git

Adding a subtree project:

```
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

