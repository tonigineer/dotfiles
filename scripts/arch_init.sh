#!/usr/bin/env bash

echo "Initial settings for Arch Linux"

echo -n ">> Setting timezone "
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

echo -n ">> Setting to HW clock "
hwclock --systohc

echo -n ">> Setting Locale "
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen  # or use vim
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo -n ">> Setting Hostname "
echo "Z790E" > /etc/hostname
echo "
127.0.0.1 localhost
::1 localhost
127.0.0.1 Z790E.localadmin Z790E" >> /etc/hosts

echo -n ">> Enable NetworkManager "
systemctl enable NetworkManager
# [[ $? -eq 0 ]] && echo "✓" || echo "✕" 