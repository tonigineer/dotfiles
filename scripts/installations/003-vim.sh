#!/usr/bin/env bash

status() {
    [ -L ~/.vimrc ] && sudo [ -L /root/.vimrc ]
}

install() {
    safe_symlink .vimrc
    sudo ln -sf ~/.vimrc /root/.vimrc
}

uninstall() {
    mv ~/.vimrc.bak ~/.vimrc
    sudo rm /root/.vimrc
}
