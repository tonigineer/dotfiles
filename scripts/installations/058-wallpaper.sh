# ── Wallpaper — Skwd wallpaper suite v2 ─────────────────────────────────
#
# skwd-wall-v2 is the wallpaper engine: the picker (skwd-wall-v2, SUPER+SHIFT+W)
# applies stills, video and Wallpaper Engine scenes through the skwd-paper
# renderers, and the skwd-walld user service (from skwd-deck) restores them at
# login. Noctalia's own wallpaper layer is switched off in every
# settings.<host>.toml (`[wallpaper] enabled = false`) so the two never draw
# over each other.
#
# Colours flow the other way round: with Settings → Theming → Noctalia chosen in
# the picker, Skwd writes ~/.config/noctalia/palettes/skwd-wall.json, which the
# Noctalia settings select as `theme.source = "custom"`,
# `custom_palette = "skwd-wall"`.
#
# Setup follows https://github.com/liixini/skwd-wall (README, Arch section).
#
# Desktop only. The notebook (X13GEN5) keeps Noctalia's own wallpaper engine
# and its mpvpaper/wallhaven plugins (settings.X13GEN5.toml), so on any host
# not listed here the module installs nothing and enables no service.

_hosts=(Z790E)

# shellcheck disable=SC2317  # called from the hooks below
_enabled() {
    [[ " ${_hosts[*]} " == *" $(dotfiles_host) "* ]]
}

if _enabled; then
    pkgs=(
        skwd-wall-v2-bin
        # Optional semantic search in the picker; pulls the skwd-lens-model pack.
        skwd-lens-bin
    )
fi

remove_pkgs=(
    skwd-lens-bin
    skwd-lens-model
    skwd-wall-v2-bin
    skwd-deck-bin
    skwd-paper-bin
)

_unit=skwd-walld.service

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    if ! _enabled; then
        echo "skwd-wall: skipped on $(dotfiles_host) (Noctalia handles wallpapers there)"
        return 0
    fi
    systemctl --user daemon-reload || true
    systemctl --user enable --now "$_unit"
}

mod_check() {
    _enabled || return 0
    # The enablement symlink rather than `systemctl is-enabled`, so the check
    # asserts on a file and works without a running user manager.
    [ -L "$HOME/.config/systemd/user/default.target.wants/$_unit" ]
}

mod_pre_uninstall() {
    systemctl --user disable --now "$_unit" 2>/dev/null || true
}
