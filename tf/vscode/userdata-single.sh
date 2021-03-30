#!/bin/bash

########
# Notes:
#
# Increase open file limit?
# https://linuxhint.com/permanently_set_ulimit_value/
#
# Increase number of watches allowed?
# https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc


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
    local deps
    deps=(
        amazon-ec2-utils
        debootstrap
    )

    log
    log "Updating apt"
    cmd "apt update -y"

    log
    log "Installing dependencies"
    cmd "apt install -y ${deps[@]}"
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

function _groups {
    local groups
    groups=(
        persist
    )

    for $group in ${groups[@]}; do
        log "Adding group $group"
        cmd "groupadd $group"
    done
}

function _users {
    local users
    users=(
        (
            ["name"]="shakefu"
            ["groups"]="sudo"
            ["sshkey"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkXdM0CqeSVdnWzIfSvCAbK6Sw1R+/bq42lj6lZvuuOCkBwdSzpOvdiQfiRSSFb2SjIEe3osE3+rlheTLlNpseIeb3dl3fnXUdgR91QJMEtjS/f1AuoLhHv8RTObAPVjGnrBzBl+1rgDxqq83V4yIvsruEQtujWu6u0+v5oLhoGJfx4PYTHHRWfv/8FZK0dxeQY0gfp2WcI4AqU65s4v952qFbZHz1jSXCGg0rFkJ41lyDF+nW0uoTLmlmKLbQsPg042ki5490xyioMOcV9CiTJ9wKGqcAxy7bXE8bEuh9X76DIvnwUyA17HY+OTCl7lH+V8eXLzRCXQhT+jneCDfc835yFjlkxM1Ov4b0M4ViWvUE0u+XEhkqDq4cjFcxIlaoJP/xXhMdl9UolGS/l7p1f77ypLE4HCEfIee6jN1A3hzOU1j+jVjgBLUyQY2AQ4zkFfMlWMnvciIrzFQayxcnVFUWQ1I1Jpz74sTFFEh93kDS5mBqnPEtiHg0fnAzP/U= shakefu@Jakes-Air",
        ),
    )
    for user in ${users[@]}; do
        name = ${user[name]}
        # Create user and add specified groups
        log "Creating $name"
        cmd "useradd --create-home --groups $groups $name"

        # Add to default groups
        cmd "usermod -aG persist"

        # Add SSH keys
        cmd "mkdir -p /home/$name/.ssh"
        cmd "echo \"${user[sshkey]}\" > /home/$name/.ssh/authorized_keys"
        cmd "chmod 400 /home/$name/.ssh/authorized_keys"
    done

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
    # Get map of user:device
    # Ensure formatting
    # Mount devices to user chroots
    # Ensure base chroot environment
}

function _config {
    # Configure SSH for chroot jail?
}

function userdata {
    _dependencies
    _devices
    _groups
    _users
    _filesystem

    log
    log "Done"
}

# Invoke our main command
userdata