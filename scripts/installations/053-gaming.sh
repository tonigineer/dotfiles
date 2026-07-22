# ── Gaming — Steam, gamescope, MangoHud, Vesktop ────────────────────────

# Needs multilib (enabled by 001-pacman) for steam + lib32-* packages.
pkgs=(
    gamescope
    lib32-fontconfig
    mangohud
    steam
    ttf-liberation
    vesktop-bin
    wqy-microhei
)

remove_pkgs=(
    steam
    mangohud
    gamescope
)

links=(
    .config/mangohud
    .config/vesktop/themes/vesktop-overrides.css
)

# ── Vesktop theme overrides ─────────────────────────────────────────────
# Noctalia regenerates ~/.config/vesktop/themes/noctalia.theme.css on every
# colour change, so our tweaks live in a second theme file (symlinked above)
# and are switched on in Vesktop's own settings. Vesktop applies each entry of
# enabledThemes in order, so ours goes last.

_vesktop_theme="vesktop-overrides.css"
_vesktop_settings="$HOME/.config/vesktop/settings/settings.json"

_vesktop_theme_enabled() {
    [ -f "$_vesktop_settings" ] &&
        python3 -c "import json,sys;sys.exit(0 if '$_vesktop_theme' in json.load(open('$_vesktop_settings')).get('enabledThemes',[]) else 1)" 2>/dev/null
}

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    fc-cache -v

    # Vesktop writes settings.json on first launch; skip until it exists.
    if [ ! -f "$_vesktop_settings" ]; then
        echo "  note: no Vesktop settings yet — launch Vesktop once, then re-run this module"
        return 0
    fi

    _vesktop_theme_enabled || python3 - "$_vesktop_settings" "$_vesktop_theme" <<'PY'
import json, sys
path, theme = sys.argv[1], sys.argv[2]
with open(path) as f:
    settings = json.load(f)
themes = settings.setdefault("enabledThemes", [])
if theme not in themes:
    themes.append(theme)
    with open(path, "w") as f:
        json.dump(settings, f, indent=4)
PY
}

mod_check() {
    # No Vesktop settings yet is not a failure; a settings file that exists but
    # does not enable the override is.
    [ -f "$_vesktop_settings" ] || return 0
    _vesktop_theme_enabled
}

mod_post_uninstall() {
    rm -rf ~/.config/mangohud
}
