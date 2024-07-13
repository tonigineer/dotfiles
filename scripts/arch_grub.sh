#!/usr/bin/env bash

echo "Installing GRUB"

echo -n "Install dependencies"
pacman -S grub efibootmgr dosfstools mtools os-prober

echo -n "Install Grub"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

echo -n "Create Grub config"
grub-mkconfig -o /boot/grub/grub.cfg
