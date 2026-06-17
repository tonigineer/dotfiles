# ── NVIDIA — open driver + DRM modeset ──────────────────────────────────

_conf=/etc/modprobe.d/nvidia.conf

pkgs=(
    nvidia-open
    nvidia-utils
)

remove_pkgs=(
    "${pkgs[@]}"
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    echo "options nvidia_drm modeset=1" | sudo tee "$_conf" >/dev/null
    sudo sed -i -E \
        's/^MODULES=\(\)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
        /etc/mkinitcpio.conf
    sudo mkinitcpio -P
}

mod_check() {
    grep -qF 'options nvidia_drm modeset=1' "$_conf" &&
        grep -qF 'nvidia nvidia_modeset nvidia_uvm nvidia_drm' /etc/mkinitcpio.conf
}
