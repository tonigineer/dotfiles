#!/usr/bin/env bash

repo_noctalia=https://github.com/noctalia-dev/noctalia-shell.git
repo_caelestia=https://github.com/caelestia-dots/shell.git

pkgs=(
    matugen-git
    quickshell-git
    caelestia-shell-git
)

status() {
    yay_check "${pkgs[@]}" &&
        [[ $(git -C ~/.config/quickshell/caelestia/ remote get-url origin 2>/dev/null) == "$repo_caelestia" ]] &&
        [[ $(git -C ~/.config/quickshell/noctalia/ remote get-url origin 2>/dev/null) == "$repo_noctalia" ]] &&
        [ -L ~/.config/noctalia ] &&
        [ -L ~/.config/caelestia ] &&
        [ -L ~/.config/matugen ]
}

install() {
    yay_install "${pkgs[@]}"

    git clone $repo_caelestia ~/.config/quickshell/caelestia
    git clone $repo_noctalia ~/.config/quickshell/noctalia/

    safe_symlink .config/noctalia
    safe_symlink .config/caelestia
    safe_symlink .config/matugen

    ln -s ~/.local/state/caelestia/theme/kitty.conf ~/Dotfiles/.config/kitty/themes/caelestia.conf
    ln -s ~/.local/state/caelestia/theme/zed.json ~/Dotfiles/.config/zed/themes/caelestia.json

    # Adapting `caelestia-cli` package
    pypkg_dir=/usr/lib64/python3.13/site-packages/caelestia/

    theme_script=$pypkg_dir/utils/theme.py
    discord_template=$pypkg_dir/data/templates/discord.scss

    # Different icons for gtk
    sudo sed -E -i 's/Papirus-\{mode\.capitalize\(\)\}/Win11/g' "$theme_script"

    # Disable config generation for unused Discord clients
    sudo sed -E -i 's/"Equicord", "Vencord", "BetterDiscord", "equibop", "vesktop", "legcord"/["vesktop"]/g' "$theme_script"

    # Bigger gap for discord title bar. Propably caused by my high fractional scaling.
    sudo sed -z -E -i 's/(--top-bar-height:[[:space:]]*)var\([[:space:]]*--gap[[:space:]]*\)/\1var(--gap * 2)/g' "$discord_template"

    # Change font
    sudo sed -i 's/--font: "figtree";/--font: "Monaspace Krypton";/' "$discord_template"
}

uninstall() {
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/quickshell

    rm -rf ~/.config/noctalia
    rm -rf ~/.config/caelestia
    rm -rf ~/.config/matugen
}
