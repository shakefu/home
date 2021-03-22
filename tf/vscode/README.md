# Terraform things

## Breadcrumbs

- https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
- https://www.simplified.guide/ubuntu/build-chroot-environment
- https://linuxconfig.org/how-to-automatically-chroot-jail-selected-ssh-user-logins

## Mount script

```bash
$ cat /mount.sh
#!/bin/sh
mount --rbind /sys /mnt/ubuntu/sys
mount --rbind /dev /mnt/ubuntu/dev
mount --rbind /run /mnt/ubuntu/run
mount -t proc /proc /mnt/ubuntu/proc
```