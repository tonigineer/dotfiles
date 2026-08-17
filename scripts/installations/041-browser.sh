# shellcheck disable=SC2154  # $dotfiles_dir is provided by install.sh

pkgs=(
    zen-browser-bin
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
)

remove_pkgs=(
    zen-browser-bin
)

# ── Zen chrome overrides ────────────────────────────────────────────────
# Repo-managed fixes on top of Noctalia's generated Zen theme. The override
# file @import's after Noctalia's cache and references its CSS variables, so it
# re-themes automatically on colour-scheme changes (Noctalia only rewrites its
# cache, never the profile's userChrome.css). We wire the @import into every
# Zen profile rather than symlinking, because the profile dir name is random.

_zen_override="$dotfiles_dir/.config/zen/zen-userChrome-overrides.css"
_zen_cache_import="@import \"$HOME/.cache/noctalia/zen-browser/zen-userChrome.css\";"
_zen_override_import="@import \"$_zen_override\";"

# ── Zen prefs ───────────────────────────────────────────────────────────
# user.js is re-applied over prefs.js at every startup, which is what makes the
# icon-font allowlist survive a profile reset. Symlinked rather than appended,
# since unlike userChrome.css there is no @import to defer to.

_zen_user_js="$dotfiles_dir/.config/zen/user.js"

_zen_profiles() {
    # Print each real Zen profile dir (one containing prefs.js).
    local prof
    for prof in "$HOME"/.zen/*/; do
        [ -f "$prof/prefs.js" ] && printf '%s\n' "$prof"
    done
}

_zen_links_user_js() {
    # True if $1 (a profile dir) already links user.js to ours.
    [ -L "${1}user.js" ] &&
        [ "$(realpath -m -- "${1}user.js")" = "$(realpath -m -- "$_zen_user_js")" ]
}

mod_post_install() {
    xdg-settings set default-web-browser zen.desktop || true

    local prof chrome uc wired=0
    while IFS= read -r prof; do
        [ -n "$prof" ] || continue
        chrome="${prof}chrome"
        mkdir -p "$chrome"
        uc="$chrome/userChrome.css"
        [ -f "$uc" ] || : >"$uc"
        # Ensure Noctalia's cache import is present first, then ours after it.
        grep -qF "$_zen_cache_import" "$uc" || printf '%s\n' "$_zen_cache_import" >>"$uc"
        grep -qF "$_zen_override_import" "$uc" || printf '%s\n' "$_zen_override_import" >>"$uc"

        # Link user.js, backing up any pre-existing one (safe_symlink is
        # $HOME-relative, so it can't target a randomly-named profile dir).
        if ! _zen_links_user_js "$prof"; then
            if [ -e "${prof}user.js" ] || [ -L "${prof}user.js" ]; then
                mv -v -- "${prof}user.js" "${prof}user.js.bak"
            fi
            ln -s -- "$_zen_user_js" "${prof}user.js"
            echo "Linked: ${prof}user.js -> $_zen_user_js"
        fi

        wired=1
    done < <(_zen_profiles)

    [ "$wired" = 1 ] ||
        echo "  note: no Zen profile under ~/.zen yet — launch Zen once, then re-run this module"
}

mod_check() {
    [ -f "$_zen_override" ] || return 1
    [ -f "$_zen_user_js" ] || return 1
    # Every existing profile must reference the override and link user.js
    # (no profiles = ok).
    local prof
    while IFS= read -r prof; do
        [ -n "$prof" ] || continue
        grep -qF "$_zen_override_import" "${prof}chrome/userChrome.css" 2>/dev/null || return 1
        _zen_links_user_js "$prof" || return 1
    done < <(_zen_profiles)
    return 0
}

mod_pre_uninstall() {
    # Drop our @import from every profile; leave Noctalia's untouched.
    local prof uc
    while IFS= read -r prof; do
        uc="${prof}chrome/userChrome.css"
        if [ -f "$uc" ]; then
            grep -vF "$_zen_override_import" "$uc" >"$uc.tmp" && mv "$uc.tmp" "$uc"
        fi

        # Unlink user.js and restore any backup; leave a foreign user.js alone.
        if _zen_links_user_js "$prof"; then
            rm -- "${prof}user.js"
            if [ -e "${prof}user.js.bak" ]; then
                mv -v -- "${prof}user.js.bak" "${prof}user.js"
            fi
        fi
    done < <(_zen_profiles)
    return 0
}
