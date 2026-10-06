FROM quay.io/fedora/fedora-kinoite:44
MAINTAINER Pramox Indra

# SETUP FILESYSTEM
# RUN rmdir /opt && ln -s -T /var/opt /opt
RUN mkdir /var/roothome

# INSTALL REPOS
RUN dnf -y install dnf5-plugins
RUN dnf -y copr enable ngompa/bcachefs

# Prepare bcachefs
RUN <<INSTALLBC
#!/usr/bin/env bash
# Enable copr
dnf -y copr enable "ngompa/bcachefs"

# Install module for available kernel version
KVER="$(ls /lib/modules)"
dnf -y install "kernel-devel-${KVER}"
dnf -y install bcachefs-kmod

# Move the module to a separate location while removing dkms
MOD="$(find /lib/modules -type f -name 'bcachefs.ko*' -print -quit)"
mv "${MOD}" /lib/modules/

# Remove devel files and dkms
dnf -y --allowerasing remove dkms "kernel-devel-${KVER}"
mkdir -p "/lib/modules/${KVER}/extra/"

# Put module back and register it
mv /lib/modules/bcachefs.ko* "/lib/modules/${KVER}/extra/"
depmod -A

# Further cleanup and install userspace tools
dnf -y autoremove
dnf -y install bcachefs-tools

INSTALLBC

# Initramfs config
RUN <<BCINITCF

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

BCINITCF

# CLEAN & CHECK
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
