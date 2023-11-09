# Default Dockerfile for Go development containers.
# This is based on debian:bullseye-slim and installs the latest Go release.
# TODO: This is incompatible with a multi-arch build
FROM mcr.microsoft.com/devcontainers/base:bullseye AS base

ARG USER=vscode

# Do work in /tmp since it's not persisted
WORKDIR /tmp

# Install required system dependencies
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        apt-transport-https \
        curl \
        git \
        gpg \
        wget \
        zsh && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

# Dependencies that pre-commit uses
RUN apt-get update -yqq && apt-get install -yqq \
    shellcheck \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings

# Install VSCode
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get update -yqq && \
    apt-get install code && \
    rm -rf /var/lib/apt/lists/*

# Kubectl apt repository
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update -yqq && \
    apt-get install kubectl && \
    rm -rf /var/lib/apt/lists/*

# Docker apt repository
RUN	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-apt-keyring.gpg  && \
    echo "deb [signed-by=/etc/apt/keyrings/docker-apt-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update -yqq && \
    apt-get install docker-ce && \
    rm -rf /var/lib/apt/lists/*

# Terraform apt repository
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/hashicorp-apt-keyring.gpg] https://apt.releases.hashicorp.com jammy main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update -yqq && \
    apt-get install terraform && \
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


# Create a vscode user with uid 1000 (this user may already exist)
RUN useradd \
    --create-home \
    --shell /bin/zsh \
    --uid 1000 \
    --gid 1000 \
    --non-unique \
    "${USER}" || true

# Set the shell to zsh
RUN chsh --shell "/usr/bin/zsh" "${USER}"

# Install vscode extensions
WORKDIR /tmp/shakefu
COPY .devcontainer/extensions.sh ./extensions.sh
# Switch to user to install extensions correctly
USER ${USER}
RUN /tmp/shakefu/extensions.sh

# Create SSH directory for user
RUN cd ~ && mkdir -p .ssh

# Build home tool from source
WORKDIR /tmp/shakefu/home
COPY files/ ./files/
COPY install/ ./install/
# TODO: Use SemVer instead of this
COPY go.mod go.sum home.go VERSION ./
RUN go build --buildvcs=false .

# Install home
RUN ./home setup --debug

# Revert to our default user directory
WORKDIR /workspaces/home

# Final output image
FROM scratch AS final

ARG USER=vscode

# Copy over the whole filesystem in one whack
COPY --from=base / /

# Set the user
USER ${USER}
