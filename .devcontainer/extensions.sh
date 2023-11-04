#!/usr/bin/env bash

EXTENSIONS=(
4ops.terraform
aaron-bond.better-comments
bierner.markdown-preview-github-styles
bungcip.better-toml
DavidAnson.vscode-markdownlint
dbaeumer.jshint
dbaeumer.vscode-eslint
eamodio.gitlens
eg2.vscode-npm-script
esbenp.prettier-vscode
gerane.Theme-IRBlack
GitHub.codespaces
GitHub.copilot
GitHub.github-vscode-theme
GitHub.remotehub
github.vscode-github-actions
GitHub.vscode-pull-request-github
golang.go
Gruntfuggly.todo-tree
hashicorp.terraform
jetmartin.bats
jmreicha.tender
joelalejandro.nrql-language
markis.code-coverage
mikestead.dotenv
ms-azuretools.vscode-docker
ms-kubernetes-tools.vscode-kubernetes-tools
ms-python.black-formatter
ms-python.flake8
ms-python.isort
ms-python.python
ms-python.vscode-pylance
ms-toolsai.jupyter-keymap
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode.anycode-c-sharp
ms-vscode.anycode-cpp
ms-vscode.anycode-go
ms-vscode.anycode-java
ms-vscode.anycode-php
ms-vscode.anycode-python
ms-vscode.anycode-rust
ms-vscode.anycode-typescript
ms-vscode.azure-repos
ms-vscode.remote-explorer
ms-vscode.remote-repositories
ms-vsliveshare.vsliveshare
Orta.vscode-jest
pamaron.pytest-runner
redhat.vscode-yaml
renxzen.google-colab-theme
samverschueren.final-newline
stevencl.addDocComments
stkb.rewrap
timonwong.shellcheck
vivaxy.vscode-conventional-commits
vscode-icons-team.vscode-icons
vscodevim.vim
windmilleng.vscode-go-autotest
zeshuaro.vscode-python-poetry
)

echo "Installing extensions..."
for name in "${EXTENSIONS[@]}"; do
    echo "Installing $name ..."
    code --install-extension "$name"
done
echo "Done!"
