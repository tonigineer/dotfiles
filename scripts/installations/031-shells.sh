# ── Shells — Noctalia desktop shell ─────────────────────────────────────
#
# shellcheck disable=SC2154  # $dotfiles_dir is provided by install.sh
#
# v5, built from git. The old AUR package `noctalia-shell` (v4, Quickshell)
# was dropped when v5 landed; `extra/noctalia` tracks tagged betas, this
# tracks main. It `provides`/`conflicts` noctalia, so the two are exclusive.

# mpvpaper backs Noctalia's mpvpaper plugin. No host enables that plugin any
# more: both machines draw wallpapers with skwd-wall-v2 (058-wallpaper.sh).
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


# ── Wallhaven API key ───────────────────────────────────────────────────
#
# The settings file above is tracked, and Noctalia stores plugin secrets in it:
# `plugin_settings."noctalia/wallhaven".api_key`. A key committed there lands on
# a public GitHub repo, so .gitattributes marks the file `filter=noctalia-key`
# and the filter keeps the live value out of every commit:
#
#   clean   (worktree -> git)  rewrites the line to `api_key = ""`
#   smudge  (git -> worktree)  puts the key back from the file below
#
# A git filter is *config*, not repo content, so it cannot be committed and has
# to be set per clone — which is what this hook is for. `required = true` makes a
# missing filter a hard error: without it git would silently pass the file
# through unfiltered and commit the key.
#
# The key lives outside the repo on purpose. ~/.local/state/noctalia is Noctalia's
# cache and plugin directory and only settings.toml is linked into the repo, so
# nothing there is tracked. No key file means `api_key = ""`, which Wallhaven
# accepts at anonymous rate limits instead of failing.
_wallhaven_key="$HOME/.local/state/noctalia/wallhaven.key"

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    git -C "$dotfiles_dir" config filter.noctalia-key.clean \
        'sed -E "s/^(api_key = ).*/\1\"\"/"'
    git -C "$dotfiles_dir" config filter.noctalia-key.smudge \
        'sed -E "s|^api_key = \"\"|api_key = \"$(cat '"$_wallhaven_key"' 2>/dev/null)\"|"'
    git -C "$dotfiles_dir" config filter.noctalia-key.required true

    [ -s "$_wallhaven_key" ] ||
        echo "No $_wallhaven_key — Wallhaven runs unauthenticated until one is written." >&2

    return 0
}

# The filter is what keeps the key out of commits, so a clone without it is
# drifted even though every file is in place.
mod_check() {
    git -C "$dotfiles_dir" config --get filter.noctalia-key.clean >/dev/null
}

mod_post_uninstall() {
    rm -rf ~/.local/state/noctalia
}
