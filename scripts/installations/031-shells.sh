# ── Shells — Noctalia desktop shell ─────────────────────────────────────
#
# v5, built from git. The old AUR package `noctalia-shell` (v4, Quickshell)
# was dropped when v5 landed; `extra/noctalia` tracks tagged betas, this
# tracks main. It `provides`/`conflicts` noctalia, so the two are exclusive.

# mpvpaper backs Noctalia's mpvpaper plugin on the notebook, which keeps
# Noctalia's own wallpapers; the desktop uses skwd-wall-v2 (058-wallpaper.sh).
pkgs=(
    noctalia-git
    mpvpaper
    pacman-contrib
)

# `pacman-contrib` is left in place: it is a general-purpose pacman utility
# that the rest of the system may rely on.
remove_pkgs=(
    noctalia-git
    mpvpaper
)

# Noctalia keeps its live settings under XDG_STATE_HOME, not XDG_CONFIG_HOME.
# Link the file alone: the rest of that directory is cache, history and
# downloaded plugins/templates that must not enter version control.
#
# It is per host: the panel layout, wallpapers and lockscreen widgets are bound
# to the outputs a machine actually has (eDP-1 on the notebook, DP-1/DP-3 on the
# desktop). Noctalia rewrites this file at runtime, so each machine writes into
# its own settings.<hostname>.toml and never fights the other over it. There is
# no settings.default.toml: a machine without a variant of its own fails the
# install until one is seeded from an existing machine (see README).
host_links=(
    .local/state/noctalia/settings.toml
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_uninstall() {
    rm -rf ~/.local/state/noctalia
}
