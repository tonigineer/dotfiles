#!/usr/bin/env bash

if ! command -v cargo &>/dev/null; then
    echo "Installing rust ... "
    yay -S rustup
    rustup default stable
fi

cd assets/install || exit
cargo build --release

target/release/install
