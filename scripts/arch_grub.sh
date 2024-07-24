#!/usr/bin/env bash

function install_theme() {
    [[ ! -d "/boot/grub/themes/CyberEXS" ]] && sudo git clone https://github.com/HenriqueLopes42/themeGrub.CyberEXS /boot/grub/themes/CyberEXS

    # Edit /etc/default/grub
    sudo sed -i 's\GRUB_DEFAULT=0\GRUB_DEFAULT=saved\g' /etc/default/grub
    sudo sed -i 's\GRUB_TIMEOUT=5\GRUB_TIMEOUT=10\g' /etc/default/grub
    sudo sed -i 's\#GRUB_SAVEDEFAULT=true\GRUB_SAVEDEFAULT=true\g' /etc/default/grub
    sudo sed -i 's\#GRUB_DISABLE_OS_PROBER=false\GRUB_DISABLE_OS_PROBER=false\g' /etc/default/grub
    sudo sed -i 's\GRUB_GFXMODE=auto\GRUB_GFXMODE=800x600\g' /etc/default/grub
    sudo sed -i 's\#GRUB_THEME="/path/to/gfxtheme"\GRUB_THEME="/boot/grub/themes/CyberEXS/theme.txt"\g' /etc/default/grub
}

pacman -S grub efibootmgr dosfstools mtools os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

install_theme

grub-mkconfig -o /boot/grub/grub.cfg
