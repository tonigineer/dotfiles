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
# On the desktop (Z790E) and the notebook (X13GEN5). Any host not listed here
# keeps Noctalia's own wallpaper engine: the module installs nothing and enables
# no service there.

_hosts=(Z790E X13GEN5)

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

    # The picker's own settings (layout, transitions, key bindings, the GPU it
    # renders on). Skwd rewrites the file from the settings UI; should it ever
    # replace rather than rewrite it, $HOME would hold a plain file again and
    # `--status wallpaper` would fail, which is the signal to relink. Only this
    # file: the rest of that directory is the matugen template copy Skwd ships.
    #
    # Per host, because Settings → Performance pins the render GPU by UUID
    # (`performance.gpuDevice`), which only exists on the machine that chose it.
    # Settings → Sources stores Wallhaven/Pexels/Unsplash/Steam API keys in here;
    # keep them out, or the file stops being committable.
    host_links=(
        .config/skwd-wall-v2/config.json
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
