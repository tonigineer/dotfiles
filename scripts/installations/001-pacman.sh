#!/usr/bin/env bash

f=/etc/pacman.conf

status() {
    grep -Eq '^[[:space:]]*ILoveCandy[[:space:]]*$' "$f" &&
        grep -Eq '^[[:space:]]*ParallelDownloads[[:space:]]*=[[:space:]]*10[[:space:]]*$' "$f" &&
        grep -Eq '^[[:space:]]*Color[[:space:]]*$' "$f"
}

install() {
    {
        echo '[multilib]'
        echo 'Include = /etc/pacman.d/mirrorlist'
        echo
    } | sudo tee -a "$f" >/dev/null

    sudo sed -i -E \
        -e 's/^[[:space:]]*#?[[:space:]]*Color[[:space:]]*$/Color/' \
        -e 's/^[[:space:]]*#?[[:space:]]*ILoveCandy[[:space:]]*$/ILoveCandy/' \
        -e 's/^[[:space:]]*#?[[:space:]]*ParallelDownloads[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$/ParallelDownloads = 10/' \
        "$f"

}

uninstall() {
    sudo sed -i -E 's/^[[:space:]]*Color[[:space:]]*$/#Color/' "$f"
    sudo sed -i -E 's/^[[:space:]]*ILoveCandy[[:space:]]*$/#ILoveCandy/' "$f"
    sudo sed -i -E 's/^[[:space:]]*ParallelDownloads[[:space:]]*=[[:space:]]*10[[:space:]]*$/#ParallelDownloads = 10/' "$f"
}
