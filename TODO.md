# TODO

- [ ] Remove meld, use VSCode 3-way diff for `git mergetool` in `.gitconfig`
- [ ] Synchronize `brew` dependencies for `arm64`
- [ ] Make .zshrc not hardcode brew
- [ ] Preinstall pyenv in the image
- [ ] Preinstall nodenv in the image
- [ ] Make ssh-agent startup compatible with container (init environment?)
  - Create ~/.ssh dir
  - `_start_agent:18: no such file or directory: /home/vscode/.ssh/environment-codespaces-983517`
- [ ] Install go-outline in container
- [ ] Install gopls in container
