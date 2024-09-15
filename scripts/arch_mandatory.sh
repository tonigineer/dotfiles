#!/usr/bin/env bash

if [ "$EUID" -qe 0 ]; then
  echo "Do not execute as root!"
  exit
fi

echo "Initial settings for Arch Linux"

echo ">> Configure pacman"
sudo sed -i 's\#Color\Color\g' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads = 5/ILoveCandy\nParallelDownloads = 10/g' /etc/pacman.conf
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

sudo pacman -Sy

echo ">> Configure VIM"
echo "syntax on
filetype on
set noswapfile
set number
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set textwidth=80
set nobackup
set hlsearch
set showmatch

inoremap kj <esc>
inoremap jk <esc>" >~/.vimrc
sudo ln -s ~/.vimrc /root/.vimrc

if [ ! -d "/opt/yay" ]; then
  echo -n ">> Install yay "
  sudo pacman -S base-devel git vim
  cd /opt
  sudo git clone https://aur.archlinux.org/yay.git
  sudo chown -R $USER:wheel ./yay
  cd yay
  makepkg -si
fi

yay -Syyu
