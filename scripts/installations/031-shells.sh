# ── Shells — Noctalia desktop shell ─────────────────────────────────────
#
# v5, built from git. The old AUR package `noctalia-shell` (v4, Quickshell)
# was dropped when v5 landed; `extra/noctalia` tracks tagged betas, this
# tracks main. It `provides`/`conflicts` noctalia, so the two are exclusive.

pkgs=(
    noctalia-git
)

remove_pkgs=(
    "${pkgs[@]}"
)

# Noctalia keeps its live settings under XDG_STATE_HOME, not XDG_CONFIG_HOME.
# Link the file alone: the rest of that directory is cache, history and
# downloaded plugins/templates that must not enter version control.
links=(
    .local/state/noctalia/settings.toml
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_uninstall() {
    rm -rf ~/.local/state/noctalia
}
