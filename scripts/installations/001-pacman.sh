# ── Pacman — multilib, Color, ILoveCandy, ParallelDownloads ─────────────

_conf=/etc/pacman.conf

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    # Enable [multilib] (idempotent — skip if already present).
    if ! grep -qE '^[[:space:]]*\[multilib\]' "$_conf"; then
        printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist\n\n' |
            sudo tee -a "$_conf" >/dev/null
    fi

    # Uncomment / set the cosmetic options that ship commented out.
    sudo sed -i -E \
        -e 's/^[[:space:]]*#?[[:space:]]*Color[[:space:]]*$/Color/' \
        -e 's/^[[:space:]]*#?[[:space:]]*ParallelDownloads[[:space:]]*=.*/ParallelDownloads = 10/' \
        "$_conf"

    # ILoveCandy has no stock (commented) line, so add it under [options].
    grep -qE '^[[:space:]]*ILoveCandy[[:space:]]*$' "$_conf" ||
        sudo sed -i '/^\[options\]/a ILoveCandy' "$_conf"

    sudo pacman -Syy >/dev/null 2>&1 || true
}

mod_check() {
    grep -qE '^[[:space:]]*ILoveCandy[[:space:]]*$' "$_conf" &&
        grep -qE '^[[:space:]]*ParallelDownloads[[:space:]]*=[[:space:]]*10[[:space:]]*$' "$_conf" &&
        grep -qE '^[[:space:]]*Color[[:space:]]*$' "$_conf"
}

mod_post_uninstall() {
    sudo sed -i -E \
        -e 's/^[[:space:]]*Color[[:space:]]*$/#Color/' \
        -e 's/^[[:space:]]*ILoveCandy[[:space:]]*$/#ILoveCandy/' \
        -e 's/^[[:space:]]*ParallelDownloads[[:space:]]*=[[:space:]]*10[[:space:]]*$/#ParallelDownloads = 5/' \
        "$_conf"
}
