#!/usr/bin/env bash

pkgs=(
    matugen-git
    quickshell-git
    caelestia-cli
    caelestia-shell-git
    noctalia-shell
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.config/caelestia ] &&
        [ -L ~/.config/noctalia ]
}

install() {
    yay_install "${pkgs[@]}"

    safe_symlink .config/noctalia
    safe_symlink .config/caelestia

    mkdir -p ~/.config/kitty/themes
    mkdir -p ~/.config/zed/themes

    ln -fs ~/.local/state/caelestia/theme/kitty.conf ~/.config/kitty/themes/caelestia.conf
    ln -fs ~/.local/state/caelestia/theme/zed.json ~/.config/zed/themes/caelestia.json

    # Adapting `caelestia-cli` package
    #
    # Note: Kind of a hacky way, since the python package is directly modified, but currently
    # there is no other way. Maybe adding the feature would be nice.
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

    rm -rf ~/.config/noctalia
    rm -rf ~/.config/caelestia
    rm -rf ~/.config/matugen
}
