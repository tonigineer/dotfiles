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
# comes from the desktop shell. Noctalia renders
# .config/noctalia/templates/zed.json -> ~/.config/zed/themes/noctalia.json on
# every palette change (gitignored output). That template is a fork of the
# community one, registered as [theme.templates.user.zed] in the noctalia
# settings.toml, so no symlink is needed here — the settings file points at the
# repo path directly.
#
# Code - OSS works the same way: .config/noctalia/templates/vscode.json (a fork
# of the community `vscode` template: sidebar on the editor background, red kept
# for real errors instead of variables/keys/tags) is registered as
# [theme.templates.user.vscode] and rendered into the theme file of the Open VSX
# extension Noctalia.noctaliatheme. Its output path names the extension's
# version folder (…-0.0.5-universal), so an extension update needs that path
# bumped in the settings.

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
