FROM quay.io/fedora/fedora-kinoite:45
MAINTAINER Pramox Indra

# SETUP FILESYSTEM
# RUN rmdir /opt && ln -s -T /var/opt /opt
RUN mkdir /var/roothome

# INSTALL REPOS
RUN dnf -y install dnf5-plugins
RUN dnf -y copr enable ngompa/bcachefs

# BCacheFS KMod
COPY --chmod=0755 ./scripts/* /tmp/scripts/
RUN bash /tmp/scripts/bcfskmod.sh

# Initramfs config
RUN bash /tmp/scripts/bcfsirfs.sh

# CLEAN & CHECK
RUN rm -fr /tmp/scripts
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
