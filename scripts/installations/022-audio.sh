# ── Audio — PipeWire stack ──────────────────────────────────────────────

pkgs=(
    pavucontrol
    pipewire
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    playerctl
    wireplumber
)

remove_pkgs=(
    "${pkgs[@]}"
)

# ── Hooks ───────────────────────────────────────────────────────────────

# pipewire-jack provides JACK and conflicts with jack2; drop jack2 first so the
# swap is non-interactive (a fresh pipewire system won't have jack2 anyway).
mod_pre_install() {
    pacman -Qq jack2 >/dev/null 2>&1 && sudo pacman -Rdd --noconfirm jack2
    return 0
}
