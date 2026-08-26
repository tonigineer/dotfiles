# ── IDE — Zed + Code - OSS + portals ────────────────────────────────────
#
# Code - OSS is the MIT-licensed VS Code source tree as packaged by Arch in
# `extra`, not the AUR `vscodium-bin` rebuild of the same tree. Both default
# to the Open VSX marketplace and neither carries Microsoft's telemetry keys,
# so the repo package wins on the only axes left: it is signed, it updates
# with the rest of the system, and it tracks upstream ahead of VSCodium.
#
# Its config lives under `Code - OSS` (the nameLong), while extensions go to
# ~/.vscode-oss (the dataFolderName, which VSCodium inherits verbatim — that
# collision is why both editors fight over the same extensions directory).
#
# NOTE: the caelestia zed theme link was dropped with caelestia; theming now
# comes from the desktop shell.

pkgs=(
    code
    gnome-keyring
    libsecret
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
    zed
)

remove_pkgs=(
    code
    zed
)

links=(
    ".config/Code - OSS/User/keybindings.json"
    ".config/Code - OSS/User/settings.json"
    .config/zed/keymap.json
    .config/zed/settings.json
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_uninstall() {
    rm -rf ~/.config/zed "$HOME/.config/Code - OSS"
}
