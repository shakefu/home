# Build home tool from source
FROM golang:1.20 AS build-home

WORKDIR /tmp/shakefu/home
COPY files/ ./files/
COPY install/ ./install/
# TODO: Use SemVer instead of this
COPY go.mod go.sum home.go VERSION ./
RUN go build --buildvcs=false .
RUN mkdir -p /build && \
    cp home /build/home

# Default Dockerfile for Go development containers.
# This is based on debian:bullseye-slim and installs the latest Go release.
# TODO: This is incompatible with a multi-arch build
FROM mcr.microsoft.com/devcontainers/base:bullseye AS base

ARG USER=vscode

# Do work in /tmp since it's not persisted
WORKDIR /tmp

# Don't ask questions
ENV DEBIAN_FRONTEND=noninteractive

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
    shellcheck && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

# Dependencies for building Python
RUN apt-get update -yqq && apt-get install -yqq \
    libffi-dev \
    libncurses-dev \
    libssl-dev \
    openssl && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings

# Install VSCode
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get update -yqq && \
    apt-get install -yqq code && \
    rm -rf /var/lib/apt/lists/*

# Install gh cli tool
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update -yqq && \
    apt-get install -yqq gh && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

# Install Docker CE CLI
RUN apt-get update -yqq && \
    apt-get install -yqq apt-transport-https ca-certificates curl gnupg2 lsb-release && \
    curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null && \
    echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update -yqq && \
    apt-get install -yqq docker-ce-cli

# We have to ensure this user exists before we setup Docker
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

# Create docker-init script which configures user group permissions
RUN echo -e "#!/bin/sh\n\
    sudoIf() { if [ \"\$(id -u)\" -ne 0 ]; then sudo \"\$@\"; else \"\$@\"; fi }\n\
    SOCKET_GID=\$(stat -c '%g' /var/run/docker.sock) \n\
    if [ \"${SOCKET_GID}\" != '0' ]; then\n\
        if [ \"\$(cat /etc/group | grep :\${SOCKET_GID}:)\" = '' ]; then sudoIf groupadd --gid \${SOCKET_GID} docker-host; fi \n\
        if [ \"\$(id ${USER} | grep -E \"groups=.*(=|,)\${SOCKET_GID}\(\")\" = '' ]; then sudoIf usermod -aG \${SOCKET_GID} ${USER}; fi\n\
    fi\n\
    exec \"\$@\"" > /usr/local/share/docker-init.sh \
    && chmod +x /usr/local/share/docker-init.sh

# Install vscode extensions
WORKDIR /tmp/shakefu
COPY .devcontainer/extensions.sh ./extensions.sh
# Switch to user to install extensions correctly
USER ${USER}
RUN /tmp/shakefu/extensions.sh

# Create SSH directory for user
RUN cd ~ && mkdir -p .ssh

# Get the built home binary
COPY --from=build-home /build/home /usr/local/bin/home
# Run our setup
RUN home setup --debug

# Revert to our default user directory
WORKDIR /workspaces/home

# VS Code overrides ENTRYPOINT and CMD when executing `docker run` by default.
# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to
# the Docker socket if "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
# ref: https://github.com/microsoft/vscode-dev-containers/tree/main/containers/docker-from-docker#enabling-non-root-access-to-docker-in-the-container
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# Final output image
# This breaks buildx caching on GHA so we'll skip it for now
# FROM scratch AS final
# ARG USER=vscode
# Copy over the whole filesystem in one whack
# COPY --from=base / /
# Set the user
# USER ${USER}
