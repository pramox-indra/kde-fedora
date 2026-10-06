#!/usr/bin/env bash

# Config file
tee /usr/lib/dracut/dracut.conf.d/bcachefs.conf <<BDCINITSET
# Add bcachefs support
add_drivers+=" bcachefs "
filesystems+=" bcachefs "

# Including binary and symlink just-in-case
install_items+=" /usr/lib/udev/rules.d/64-bcachefs.rules /usr/bin/bcachefs /usr/bin/mount.bcachefs "
BDCINITSET

# Rebuild initramfs
KVER="$(ls /lib/modules)"
export DRACUT_NO_XATTR=1

dracut -vf "/usr/lib/modules/${KVER}/initramfs.img" "$KVER"
