# Post-Installation of Arch Linux

Things to do after the installation process for [Arch Linux](https://archlinux.org/).

> [!IMPORTANT]
> Use `nmtui` to set up network connections from [tty](https://wiki.archlinux.org/title/Linux_console).

> [!TIP]
> `bash <(curl -Ls https://raw.githubusercontent.com/tonigineer/dotfiles/main/scripts/arch_mandatory.sh)`

## Mandatory

Installation of [yay](https://github.com/Jguer/yay) for the [Arch User Repository (AUR)](https://wiki.archlinux.org/title/Arch_User_Repository).

```bash
sudo pacman -S base-devel git vim
cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R USERNAME:GROUP ./yay
cd yay
makepkg -si
```

Changes to [pacman](https://wiki.archlinux.org/title/pacman) package manager for people with style and a fast internet connection.

```bash
sudo vim /etc/pacman.conf
# Uncomment the following
ParallelDownloads = 10
Color
# Add the following (must be under [options])
ILoveCandy
```

Some quality of life changes for Vim

```bash
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
inoremap jk <esc>" > ~/.vimrc
```

## Apply Dotfiles

Clone the repo and submodules:

```sh
git clone --recurse-submodules https://github.com/tonigineer/dotfiles.git ~/Dotfiles
```

Run installation script:

```sh
cd ~/Dotfiles
scripts/install.all base
```


## System specifics


### Lenovo X13Gen15

> [!CAUTION]
> No audio device recognized
 
Open `vim /etc/default/grub` and edit parameters as follow:

```sh
# Add `snd_hda_intel.dmic_detect=0` to parameters
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash snd_hda_intel.dmic_detect=0"
```

Finally, update grub with `grub-mkconfig -o /boot/grub/grub.cfg`.

> [!TIP]
> Change font in TTY.

Add the following to `/etc/vconsole.conf`:

```sh
# This is the fallback vconsole configuration provided by systemd.

KEYMAP=us
FONT=ter-132n
```

The needed [terminus-font](https://aur.archlinux.org/packages/terminus-font-ttf) is added via the [install script](../scripts/install.sh).