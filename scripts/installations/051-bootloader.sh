# ── Bootloader — GRUB virtuaverse theme ─────────────────────────────────

_repo=https://github.com/Patato777/dotfiles.git
_theme=/boot/grub/themes/virtuaverse/theme.txt

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth=1 --single-branch "$_repo" "$tmp"

    # The installer copies the theme and sets GRUB_THEME, then runs
    # grub-mkconfig — that last step needs a real root device and fails on a
    # container overlayfs, so don't let it fail the module. The theme files and
    # GRUB_THEME line (verified below) are the part we actually control.
    (cd "$tmp/grub" && sudo "$tmp/grub/install_script_grub.sh") || true
}

mod_check() {
    [ -f "$_theme" ] &&
        grep -q '^GRUB_THEME=' /etc/default/grub
}

mod_post_uninstall() {
    echo "No uninstall defined. Edit /etc/default/grub and run grub-mkconfig ..."
}
