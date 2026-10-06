#!/usr/bin/env bash

set -eu

# Enable copr
dnf -y copr enable "ngompa/bcachefs"

# Install module as per kernel
KVER="$(ls /lib/modules)"
dnf -y install "kernel-devel-${KVER}"
dnf -y install dkms-*bcachefs

# Move module elsewhere
MOD="$(find /lib/modules -type f -name 'bcachefs.ko*' -print -quit)"
cp -pa "${MOD}" /lib/modules/

# Remove surrounding builddeps
dnf -y --allowerasing remove dkms "kernel-devel-${KVER}"
mkdir -p "/lib/modules/${KVER}/extra/"

# Move module back
mv /lib/modules/bcachefs.ko* "/lib/modules/${KVER}/extra/"

# Register and cleanup
depmod -A
dnf -y autoremove
dnf -y install bcachefs-tools

exit 0
