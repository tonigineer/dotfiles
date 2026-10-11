# ── Boot splash — Plymouth "Pixel Orbit" ────────────────────────────────
#
# Carries the GRUB theme (051-bootloader) on past the bootloader. Picking an
# entry clears the screen to the splash's opening frame at once (grub-tweaks.sh
# draws /boot/grub/pixel-orbit-launch.png while GRUB loads the kernel). Plymouth
# takes over that same frame early in the initramfs and sets it moving: the
# satellite circles the Earth, stars twinkle, the launch log types itself in
# and a progress bar fills until SDDM takes the screen (sddm.service is ordered
# after plymouth-quit.service). Shutdown and reboot get the scene too; they run
# on the NVIDIA driver at the monitors' native 3840x2160 instead of the 2560x1440
# firmware framebuffer, so the theme carries an image set for each.
#
# The theme is built with the GRUB one, `./build.py splash`, into
# .local/share/grub-themes/pixel-orbit/out/splash/ (committed); its log comes
# from the entries in /boot/grub/grub.cfg, so rebuild it after they change.
#
# What else this module owns:
#
#   - `plymouth pixel-orbit` in mkinitcpio HOOKS, right after `base`. Plymouth's
#     runtime hook then starts the splash before `udev` waits for every device
#     to settle (`udevadm settle`, ~5 s here for all the USB hubs and
#     receivers); udevd itself already runs, from udev's early hook.
#     `pixel-orbit` is build-only: /etc/initcpio/install/pixel-orbit, written
#     here, puts the fallback entry's log into the fallback image.
#   - `splash` on GRUB_CMDLINE_LINUX_DEFAULT; without it Plymouth does nothing.
#   - /etc/plymouth/plymouthd.conf: the theme, and UseSimpledrmNoLuks=1. NVIDIA
#     is not in the initramfs, so until nvidia_drm loads the only display is
#     the firmware framebuffer GRUB left behind (simpledrm), which Plymouth
#     otherwise ignores for DeviceTimeout (8 s). Without LUKS there is no
#     password prompt to keep off it. When nvidia_drm comes up Plymouth moves
#     over to it, so the screen blinks once for the modeset.

pkgs=(
    plymouth
)

remove_pkgs=(
    "${pkgs[@]}"
)

_theme=pixel-orbit
_theme_dir=/usr/share/plymouth/themes/$_theme
_launch=/boot/grub/pixel-orbit-launch.png
_hook=/etc/initcpio/install/pixel-orbit
_conf=/etc/plymouth/plymouthd.conf
_mkinitcpio=/etc/mkinitcpio.conf
_grub=/etc/default/grub

# ── Helpers ─────────────────────────────────────────────────────────────

# HOOKS may wrap across lines; see _hooks_range in 055-hibernation.sh.
_hooks_range='/^HOOKS=\(/,/\)/'

_hooks_have() {
    sed -n -E "${_hooks_range}p" "$_mkinitcpio" 2>/dev/null |
        grep -qE "(^|[( ])$1([ )])"
}

_cmdline_has_splash() {
    grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT="([^"]* )?splash( [^"]*)?"' "$_grub"
}

_src() {
    printf '%s\n' "$dotfiles_dir/.local/share/grub-themes/pixel-orbit/out/splash"
}

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    local src
    src="$(_src)"

    [ -f "$src/$_theme.plymouth" ] || {
        echo "not built: $src (run ./build.py splash)" >&2
        return 1
    }

    # Replaced whole, so a rebuilt theme leaves nothing stale behind. The
    # opening frame is GRUB's, so it goes to /boot instead of the initramfs.
    sudo rm -rf "/usr/share/plymouth/themes/${_theme:?}"
    sudo cp -r "$src" "$_theme_dir"
    sudo rm "$_theme_dir/launch.png"
    sudo cp "$src/launch.png" "$_launch"

    # Written whole: the package ships it with comments only.
    printf '%s\n' '# Written by 060-bootsplash.sh.' '[Daemon]' "Theme=$_theme" 'UseSimpledrmNoLuks=1' |
        sudo tee "$_conf" >/dev/null

    sudo tee "$_hook" >/dev/null <<'HOOK'
#!/bin/bash
# Written by 060-bootsplash.sh: the fallback image gets the fallback entry's
# launch log for the Pixel Orbit splash (the plymouth hook copied the default's).

build() {
    local dir=/usr/share/plymouth/themes/pixel-orbit f
    [[ "$MKINITCPIO_PROCESS_PRESET" == *-fallback ]] || return 0
    for f in "$dir"/*/fallback/*.png; do  # one fallback/ per image set
        add_file "$f" "${f%/fallback/*}/${f##*/}"
    done
}

help() {
    echo "Pixel Orbit splash: the fallback entry's launch log in the fallback image."
}
HOOK

    # Right after base, wherever an older install put plymouth.
    if ! sed -n -E "${_hooks_range}p" "$_mkinitcpio" | grep -qE '(^|[( ])base plymouth pixel-orbit([ )])'; then
        sudo sed -i -E "$_hooks_range { s/ (plymouth|pixel-orbit)([ )])/\2/g; s/ (plymouth|pixel-orbit)([ )])/\2/g }" "$_mkinitcpio"
        sudo sed -i -E "$_hooks_range s/(^|[( ])base([ )])/\1base plymouth pixel-orbit\2/" "$_mkinitcpio"
        _hooks_have plymouth ||
            echo "No base hook in $_mkinitcpio — add plymouth to HOOKS by hand." >&2
    fi

    _cmdline_has_splash ||
        sudo sed -i -E 's/^(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*)"/\1 splash"/' "$_grub"

    # Fails on a container overlayfs (no real root device), as in 051 and 055.
    sudo grub-mkconfig -o /boot/grub/grub.cfg || true
    sudo mkinitcpio -P
}

mod_check() {
    local src
    src="$(_src)"

    # Installed = built, so a rebuild without a reinstall shows up.
    diff -rq -x launch.png "$src" "$_theme_dir" >/dev/null 2>&1 &&
        cmp -s "$src/launch.png" "$_launch" &&
        [ -f "$_hook" ] &&
        grep -qx "Theme=$_theme" "$_conf" &&
        grep -qx 'UseSimpledrmNoLuks=1' "$_conf" &&
        sed -n -E "${_hooks_range}p" "$_mkinitcpio" | grep -qE '(^|[( ])base plymouth pixel-orbit([ )])' &&
        _cmdline_has_splash &&
        grep -qE '^[[:space:]]*linux[[:space:]].*[[:space:]]splash([[:space:]]|$)' /boot/grub/grub.cfg &&
        # the initramfs was rebuilt since: it carries the theme
        lsinitcpio /boot/initramfs-linux.img 2>/dev/null |
        grep -q "usr/share/plymouth/themes/$_theme/$_theme.script"
}

# Before the package goes: a `plymouth` hook without the package would make
# every later mkinitcpio run (kernel updates) fail.
mod_pre_uninstall() {
    sudo sed -i -E "$_hooks_range { s/ (plymouth|pixel-orbit)([ )])/\2/g; s/ (plymouth|pixel-orbit)([ )])/\2/g }" "$_mkinitcpio"
    sudo sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ { s/ splash([ "])/\1/; s/="splash ?/="/ }' "$_grub"
    sudo rm -rf "/usr/share/plymouth/themes/${_theme:?}"
    sudo rm -f "$_launch" "$_hook"

    sudo grub-mkconfig -o /boot/grub/grub.cfg || true
    sudo mkinitcpio -P
    return 0
}
