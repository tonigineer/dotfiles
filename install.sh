#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if ! command -v cargo &>/dev/null; then
    echo "Installing rust ... "
    yay -S rustup
    rustup default stable
fi

cd "$SCRIPT_DIR/assets/install" || exit 1

cargo build --release
target/release/install
