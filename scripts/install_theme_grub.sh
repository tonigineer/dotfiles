#!/usr/bin/env bash

yay -S os-prober

[[ ! -d "/boot/grub/themes/CyberEXS" ]] && sudo git clone https://github.com/HenriqueLopes42/themeGrub.CyberEXS /boot/grub/themes/CyberEXS

# Edit /etc/default/grub
sudo sed -i 's\GRUB_DEFAULT=0\GRUB_DEFAULT=saved\g' /etc/default/grub
sudo sed -i 's\GRUB_TIMEOUT=5\GRUB_TIMEOUT=10\g' /etc/default/grub
sudo sed -i 's\#GRUB_SAVEDEFAULT=true\GRUB_SAVEDEFAULT=true\g' /etc/default/grub
sudo sed -i 's\#GRUB_DISABLE_OS_PROBER=false\GRUB_DISABLE_OS_PROBER=false\g' /etc/default/grub
sudo sed -i 's\GRUB_GFXMODE=auto\GRUB_GFXMODE=800x600\g' /etc/default/grub
sudo sed -i 's\#GRUB_THEME="/path/to/gfxtheme"\GRUB_THEME="/boot/grub/themes/CyberEXS/theme.txt"\g' /etc/default/grub

# NOTE: Before updating config, make sure drives with other OS are mounted
#   lsblk
#   mount /dev/nvmeXXXXXXX /mnt
#   mount /dev/nvmeXXXXXXX /mnt2

# sudo cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak-$(date +"%Y-%m-%d")
# sudo grub-mkconfig -o /boot/grub/grub.cfg

# TODO: edit grub.cfg with `--class efi`, `--class windows11`, names and order
