# Default Dockerfile for Go development containers.
# This is based on debian:bullseye-slim and installs the latest Go release.
# TODO: This is incompatible with a multi-arch build
FROM mcr.microsoft.com/devcontainers/base:bullseye AS base

# Do work in /tmp since it's not persisted
WORKDIR /tmp

# Install required system dependencies
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        curl \
        git \
        zsh && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

# A GitHub token is required to use the gh cli tool
ARG GITHUB_TOKEN

# Install gh cli tool
# RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
#         -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
#     chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
#     apt-get update -yqq && \
#     apt-get install -yqq gh && \
#     apt-get clean -yqq && \
#     rm -rf /var/lib/apt/lists/* && \
#     rm -rf /usr/share/keyrings/githubcli-archive-keyring.gpg && \
#     rm /etc/apt/sources.list.d/github-cli.list

# Download latest shakefu/home
# home-*-linux-amd64.tar.gz
# RUN export GH_TOKEN="${GITHUB_TOKEN}" && \
#     export RELEASE_GLOB="home-*-linux-amd64.tar.gz" && \
#     gh release download --repo shakefu/home --pattern "$RELEASE_GLOB" && \
#     pwd && \
#     ls -lah && \
#     tar -xzf $RELEASE_GLOB && \
#     rm $RELEASE_GLOB

# Install Go with GO_VERSION
# TODO: This is incompatible with a multi-arch build
ARG GO_VERSION=1.20.5
RUN curl -fsSL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
        -o go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/* /usr/local/bin/

# Create a codespace user with uid 1000
RUN useradd \
    --create-home \
    --shell /bin/zsh \
    --uid 1000 \
    --gid 1000 \
    --non-unique \
    codespace

# Set the shell to zsh
RUN chsh --shell "/usr/bin/zsh" vscode
RUN chsh --shell "/usr/bin/zsh" codespace


# Install vscode extensions
WORKDIR /tmp/shakefu
COPY .devcontainer/extensions.sh ./extensions.sh
# TODO: Remove chmod once executable bit is set
RUN chmod 777 extensions.sh
# Switch to codespace user to install extensions correctly
USER codespace
RUN /tmp/shakefu/extensions.sh

# Build home tool from source
WORKDIR /tmp/shakefu/home
# TODO: Use SemVer instead of this
COPY files/ install/ go.mod go.sum home.go VERSION .
RUN go build --buildvcs=false .

# Install home
RUN ./home setup --debug

# Revert to our default user directory
WORKDIR /workspaces/home

# Final output image
FROM scratch AS final

# Copy over the whole filesystem in one whack
COPY --from=base / /

# Set the user
USER codespace
