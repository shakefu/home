# Default Dockerfile for Go development containers.
# This is based on debian:bullseye-slim and installs the latest Go release.
FROM mcr.microsoft.com/devcontainers/base:bullseye

# Use the root user home dir as our base for installing
WORKDIR /root

# Install required dependencies
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        curl \
        git && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

# Install gh cli tool
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update -yqq && \
    apt-get install -yqq gh && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    rm /etc/apt/sources.list.d/github-cli.list

# Install Go with GO_VERSION
# TODO: This is incompatible with a multi-arch build
ARG GO_VERSION=1.20.5
RUN curl -fsSL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
        -o go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/* /usr/local/bin/

# Do the install in user-space
RUN useradd \
    --create-home \
    --shell /bin/zsh \
    --uid 1000 \
    --gid 1000 \
    --non-unique \
    codespace
USER codespace
WORKDIR /tmp/shakefu/home

# A GitHub token is required to use the gh cli tool
ARG GITHUB_TOKEN

# Download latest shakefu/home
# home-*-linux-amd64.tar.gz
# RUN export GH_TOKEN="${GITHUB_TOKEN}" && \
#     export RELEASE_GLOB="home-*-linux-amd64.tar.gz" && \
#     gh release download --repo shakefu/home --pattern "$RELEASE_GLOB" && \
#     pwd && \
#     ls -lah && \
#     tar -xzf $RELEASE_GLOB && \
#     rm $RELEASE_GLOB

# Build from source
COPY . .
RUN go build --buildvcs=false .

# Install home
RUN ./home setup --debug

# Revert to our default user directory
WORKDIR /workspaces/home
