# Real-install test for the dotfiles modules: runs the ACTUAL installation
# scripts with a real `yay`, so packages are really downloaded/compiled from
# the repos and the AUR, then checks each module executed correctly.
#
#   docker build -f test/Dockerfile -t dotfiles-test .
#   docker run --rm dotfiles-test
#
# Host-only commands that cannot work in a container (systemctl, mkinitcpio,
# bootctl, spicetify, xdg-settings) are shimmed to no-op success so they don't
# mask the thing we actually want to check: did each install() run, land its
# packages, and create non-dangling symlinks. Everything else is real.
#
# `grub` is installed for real (not shimmed) so 051-bootloader's grub-mkconfig
# genuinely generates /boot/grub/grub.cfg with the theme line.
#
# This is heavy: expect a long run and a large image (Steam, the Neovim
# toolchain, gamescope, etc. all build/download for real).
FROM archlinux:latest

# Enable multilib (needed by 053-gaming: steam, lib32-*), then full sync.
# grub provides a real grub-mkconfig + /etc/default/grub for 051-bootloader.
RUN sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf \
    && pacman -Syu --noconfirm --needed base-devel git sudo grub

# No-op shims for commands a container genuinely can't satisfy. Placed in
# /usr/local/bin so they win over /usr/bin for both the user and `sudo`.
RUN for cmd in systemctl mkinitcpio bootctl spicetify xdg-settings; do \
        printf '#!/bin/sh\necho "[shim] %s $*" >&2\nexit 0\n' "$cmd" >"/usr/local/bin/$cmd"; \
        chmod +x "/usr/local/bin/$cmd"; \
    done \
    && mkdir -p /boot/grub

# Non-root user with passwordless sudo (makepkg/yay refuse to run as root).
RUN useradd -m tester \
    && echo 'tester ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/tester

USER tester
WORKDIR /home/tester

# Bootstrap a real yay from the AUR.
RUN git clone https://aur.archlinux.org/yay.git /tmp/yay \
    && cd /tmp/yay \
    && makepkg -si --noconfirm \
    && rm -rf /tmp/yay

WORKDIR /home/tester/Dotfiles
COPY --chown=tester:tester . .

ENTRYPOINT ["bash", "test/run-all.sh"]
