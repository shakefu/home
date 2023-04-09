# Default Dockerfile for Go development containers.
# This is based on debian:bullseye-slim and installs the latest Go release.
FROM mcr.microsoft.com/devcontainers/base:bullseye

# Use the root user home dir as our base for installing
WORKDIR /root

# Install required dependencies
RUN apt-get update -yqq && \
    apt-get install -yqq \
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

# A GitHub token is required to use the gh cli tool
ARG GITHUB_TOKEN

# Download latest shakefu/home
# home-*-linux-amd64.tar.gz
RUN export GH_TOKEN="${GITHUB_TOKEN}" && \
    export RELEASE_GLOB="home-*-linux-amd64.tar.gz" && \
    gh release download --repo shakefu/home --pattern "$RELEASE_GLOB" && \
    pwd && \
    ls -lah && \
    tar -xzf $RELEASE_GLOB && \
    rm $RELEASE_GLOB

# Install home
RUN ./home setup
