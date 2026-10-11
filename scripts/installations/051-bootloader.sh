# ── Bootloader — GRUB "Pixel Orbit" theme ───────────────────────────────
#
# A pixel-art theme built from the pixel-earth-space wallpaper, in three variants:
# telemetry, telemetry-sans (installed here; smooth text and icons) and
# horizon. Everything lives in .local/share/grub-themes/pixel-orbit/:
#
#   build.py        renders out/<variant>/ (background, PF2 fonts, 9-slice
#                   pixmaps, icons, theme.txt); --preview adds PNG previews
#   install.sh      copies out/<variant> to /boot/grub/themes/pixel-orbit-<variant>
#                   (/boot is vfat, so no symlink), points GRUB_THEME/GRUB_FONT at
#                   it, runs grub-tweaks.sh, then grub-mkconfig
#   grub-tweaks.sh  edits the grub package's /etc/grub.d scripts: the splash's
#                   opening frame instead of the "Loading Linux …" echoes (see
#                   060-bootsplash), --class efi on the firmware entry for its
#                   icon, entry names "Arch Linux" / "Arch Linux (fallback)" /
#                   "Windows 11"
#
# out/ is committed, so installing needs neither the wallpaper nor the Pixelon
# font. Rebuilding does, plus python-pillow, python-numpy and terminus-font.
#
# A grub update restores the stock /etc/grub.d scripts and so drops the tweaks;
# `--status bootloader` then fails, and reinstalling the module reapplies them.

links=(
    .local/share/grub-themes/pixel-orbit
)

_variant=telemetry-sans
_theme_dir=/boot/grub/themes/pixel-orbit-$_variant
_grub=/etc/default/grub

# /etc/default/grub settings the theme is laid out for: the four-row menu (grub
# ≥ 2.16 otherwise adds eight "EFI BootNext" entries) and a countdown long
# enough to read.
_grub_vars=(
    GRUB_TIMEOUT=60
    GRUB_DISABLE_BOOTNEXT=true
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    local kv
    for kv in "${_grub_vars[@]}"; do
        if grep -q "^${kv%%=*}=" "$_grub"; then
            sudo sed -i "s|^${kv%%=*}=.*|$kv|" "$_grub"
        else
            echo "$kv" | sudo tee -a "$_grub" >/dev/null
        fi
    done

    # install.sh ends in grub-mkconfig, which needs a real root device and fails
    # on a container overlayfs, so don't let it fail the module. mod_check
    # asserts the parts this module actually controls.
    "$dotfiles_dir/.local/share/grub-themes/pixel-orbit/install.sh" "$_variant" || true
}

mod_check() {
    local kv
    for kv in "${_grub_vars[@]}"; do
        grep -qx "$kv" "$_grub" || return 1
    done

    [ -f "$_theme_dir/theme.txt" ] &&
        grep -qx "GRUB_THEME=\"$_theme_dir/theme.txt\"" "$_grub" &&
        # grub-tweaks.sh, undone by every grub update
        ! grep -q 'echo "$message" | grub_quote' /etc/grub.d/10_linux &&
        grep -q 'pixel-orbit-launch' /etc/grub.d/10_linux &&
        grep -q -- '--class efi' /etc/grub.d/30_uefi-firmware &&
        grep -q 'Windows 11' /etc/grub.d/30_os-prober
}

mod_post_uninstall() {
    echo "GRUB keeps the theme. To go back, restore $_grub.pre-pixel-orbit and run grub-mkconfig."
}
