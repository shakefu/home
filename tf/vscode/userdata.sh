#!/bin/bash

function log {
    echo "$*" | tee -a /tmp/userdata.log
}

function cmd {
    local out
    local run
    run="$*"
    echo | tee -a /tmp/userdata.log
    echo "$ $run" | tee -a /tmp/userdata.log
    out=$($run 2>&1)
    echo "$out" | tee -a /tmp/userdata.log
}

function _dependencies {
    log
    log "Updating apt"
    cmd "apt update -y"

    log
    log "Installing dependencies"
    cmd "apt install -y amazon-ec2-utils tree zsh"
}

function _devices {
    log
    log "Updating udev"
    cmd "udevadm control --reload-rules"
    cmd "udevadm trigger -vw"

    log
    log "Checking devices"
    cmd "ls -lh /dev/sd?"
}

function _check_mkfs {
    local dev
    dev="$1"
    log "Checking $dev"
    cmd "file -sL $dev"
    fs=$(file -sL $dev | awk '{print $(NF)}')
    if [[ "$fs" == "data" ]]; then
        log "Formatting $dev"
        cmd "mkfs -t xfs $dev"
    else
        log "  $dev ok"
    fi
}

function _filesystem {
    log "Filsystem mounts currently manual"
}

function userdata {
    _dependencies
    _devices
    _filesystem

    log
    log "Done"
}

# Invoke our main command
userdata