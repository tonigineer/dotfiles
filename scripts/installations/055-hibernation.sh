# ── Hibernation — resume hook, resume= cmdline, image size, NVIDIA ──────
#
# Hibernation needs BOTH halves wired up: the kernel writes the image to swap
# on the way down, and on the next boot the initramfs has to find it again.
# The restore half is what is usually missing, and it has two requirements:
#
#   1. mkinitcpio's `resume` hook, placed after `block` (it needs the block
#      devices to exist) and before `filesystems` (it must run before root is
#      mounted read-write, or the image is stale against the on-disk fs).
#   2. `resume=UUID=…` on the kernel command line, so the hook knows which
#      swap area to read. Without it /sys/power/resume stays 0:0, the image is
#      silently ignored, and hibernating just looks like a slow poweroff.
#
# The systemd EFI `HibernateLocation` fallback would cover (2), but only for a
# systemd-based initramfs; this one is the busybox/udev flavour, so both the
# hook and the parameter are genuinely required.
#
# Then the kernel's default target image (2/5 of RAM) can be larger than the
# swap area itself, in which case hibernation fails on a busy session. Cap it
# below the real swap size instead.
#
# Finally the NVIDIA driver has to agree to be frozen. Two module parameters
# select mutually exclusive video-memory strategies, and setting both makes
# the restore fail late — after the image has been read back — with:
#
#   NVRM: PreserveVideoMemoryAllocations module parameter is set. System Power
#         Management attempted without driver procfs suspend interface.
#   nvidia: PM: pci_pm_freeze(): nv_pmops_freeze [nvidia] returns -5
#   PM: hibernation: resume failed (-5)
#
# Per the driver README, `NVreg_PreserveVideoMemoryAllocations=1` *requires*
# the `/proc/driver/nvidia/suspend` procfs mechanism — but that node only
# exists when `NVreg_UseKernelSuspendNotifiers=0`. With the open modules the
# notifier path preserves video memory on its own, so the fix is to drop the
# Preserve parameter, not to chase the procfs interface. It is set by
# gpu-screen-recorder's /usr/lib/modprobe.d/gsr-nvidia.conf, so it gets
# shadowed by a same-named file in /etc/modprobe.d (which wins outright).
#
# Not everything that logs an error is a failure. A successful resume still
# prints, once per DDR5 stick:
#
#   spd5118 3-0051: Failed to write b = 0: -6
#   spd5118 3-0051: PM: dpm_run_callback(): spd5118_resume [spd5118] returns -6
#   spd5118 3-0051: PM: failed to restore async: error -6
#
# spd5118 is the temperature sensor on the RAM, reached over the i801 SMBus.
# Its resume callback resets the page-select register, and that write lands
# before the SMBus controller is back — hence ENXIO, and hence "restore async",
# the ordering being the whole point. Two things make it harmless: the
# hibernation core only logs restore-phase device errors instead of aborting
# (unlike a freeze-phase failure such as the NVIDIA one above, which kills the
# cycle outright), and the page pointer is re-selected on every read anyway, so
# the first `sensors` call repairs it. Nothing to fix here — suppressing it
# would mean blacklisting the module and giving up the RAM temperatures.

_tmpfiles=/etc/tmpfiles.d/hibernation-image-size.conf
_mkinitcpio=/etc/mkinitcpio.conf
_grub=/etc/default/grub
_marker='# Written by 055-hibernation.sh — shadows the packaged file.'

# ── Helpers ─────────────────────────────────────────────────────────────

# Echo the UUID of the swap area to resume from, or nothing if there is none.
# Prefers the live swap device and falls back to fstab, so this also works
# before the first `swapon` on a fresh install.
_resume_uuid() {
    local dev

    dev="$(swapon --noheadings --show=NAME 2>/dev/null | head -1)"

    if [ -z "$dev" ]; then
        dev="$(awk '$1 !~ /^#/ && $3 == "swap" { print $1; exit }' /etc/fstab 2>/dev/null)"
    fi

    [ -n "$dev" ] || return 0

    # A swapfile would additionally need resume_offset= (its physical offset
    # within the filesystem); that is out of scope here, so say so and stop.
    if [ -f "$dev" ]; then
        echo "Swap is a file ($dev): resume_offset is required and not handled here." >&2
        return 0
    fi

    case "$dev" in
    UUID=*) printf '%s\n' "${dev#UUID=}" ;;
    *) blkid -s UUID -o value -- "$dev" 2>/dev/null ;;
    esac
}

# Echo the image_size cap in bytes: 85% of the swap area, leaving headroom so
# a nearly-exact fit doesn't fail at the last page.
_image_size() {
    local bytes

    bytes="$(swapon --noheadings --bytes --show=SIZE 2>/dev/null | head -1)"
    [ -n "$bytes" ] || return 0

    printf '%s\n' $((bytes * 85 / 100))
}

# True when the two video-memory strategies are configured at once — the
# combination that makes the restore fail. Reads modprobe's resolved view, so
# it accounts for /etc shadowing /usr/lib rather than guessing from filenames.
_vram_conflict() {
    local conf
    conf="$(modprobe --showconfig 2>/dev/null | grep '^options nvidia ')" || return 1

    printf '%s\n' "$conf" | grep -q 'NVreg_PreserveVideoMemoryAllocations=1' &&
        printf '%s\n' "$conf" | grep -q 'NVreg_UseKernelSuspendNotifiers=1'
}

# Echo the packaged modprobe.d files that turn Preserve on, so each can be
# shadowed by name.
_preserve_sources() {
    grep -rls 'NVreg_PreserveVideoMemoryAllocations=1' /usr/lib/modprobe.d/ 2>/dev/null
}

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    local uuid size src shadow rebuild=0

    uuid="$(_resume_uuid)"
    size="$(_image_size)"

    # 1. resume hook, inserted between `block` and `filesystems`.
    if [ -f "$_mkinitcpio" ]; then
        sudo sed -i -E '/^HOOKS=/ { /(^|[( ])resume([ )]|$)/! s/(^|[( ])filesystems([ )])/\1resume filesystems\2/ }' \
            "$_mkinitcpio"
        rebuild=1
    else
        echo "No $_mkinitcpio — skipping the resume hook." >&2
    fi

    # 2. resume= on the kernel command line. Rewrite an existing value rather
    #    than appending a second one, so re-running after a repartition is safe.
    if [ -n "$uuid" ] && [ -f "$_grub" ]; then
        if grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=.*[ "]resume=' "$_grub"; then
            sudo sed -i -E \
                "s|^(GRUB_CMDLINE_LINUX_DEFAULT=.*[ \"])resume=[^ \"]*|\1resume=UUID=$uuid|" \
                "$_grub"
        else
            sudo sed -i -E \
                "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\")(.*)(\")\$|\1\2 resume=UUID=$uuid\3|" \
                "$_grub"
            # Collapse the leading space an empty previous value would leave.
            sudo sed -i -E 's|^(GRUB_CMDLINE_LINUX_DEFAULT=")[[:space:]]+|\1|' "$_grub"
        fi

        # grub-mkconfig needs a real root device and fails on a container
        # overlayfs; the edit above is the part this module actually owns.
        sudo grub-mkconfig -o /boot/grub/grub.cfg || true
    elif [ -z "$uuid" ]; then
        echo "No swap area found — cannot set resume=; hibernation stays unavailable." >&2
    fi

    # 3. Cap the image below the swap size, reapplied on every boot.
    if [ -n "$size" ]; then
        printf 'w /sys/power/image_size - - - - %s\n' "$size" |
            sudo tee "$_tmpfiles" >/dev/null
        sudo systemd-tmpfiles --create "$_tmpfiles" || true
    fi

    # 4. Drop NVreg_PreserveVideoMemoryAllocations by shadowing whichever
    #    packaged file sets it. nvidia lives in the initramfs (see MODULES=),
    #    so it is loaded during the resume boot and reads modprobe.d from
    #    there — the initramfs has to be rebuilt for this to take effect.
    if _vram_conflict; then
        for src in $(_preserve_sources); do
            shadow="/etc/modprobe.d/$(basename "$src")"
            {
                printf '%s\n' "$_marker"
                sed 's/NVreg_PreserveVideoMemoryAllocations=1/NVreg_PreserveVideoMemoryAllocations=0/' "$src"
            } | sudo tee "$shadow" >/dev/null
            echo "Shadowed $src -> $shadow"
            rebuild=1
        done
    fi

    [ "$rebuild" -eq 1 ] && sudo mkinitcpio -P

    return 0
}

mod_check() {
    local uuid

    ! _vram_conflict || return 1

    uuid="$(_resume_uuid)"

    # Nothing to point resume= at (no swap): the rest is moot.
    [ -n "$uuid" ] || return 0

    grep -qE '^HOOKS=.*(^|[( ])resume([ )])' "$_mkinitcpio" &&
        grep -qE "^GRUB_CMDLINE_LINUX_DEFAULT=.*resume=UUID=$uuid" "$_grub" &&
        [ -f "$_tmpfiles" ]
}

mod_post_uninstall() {
    local shadow

    # Only drop the shadows this module wrote, not hand-made overrides.
    for shadow in /etc/modprobe.d/*.conf; do
        [ -f "$shadow" ] && head -1 "$shadow" | grep -qF "$_marker" &&
            sudo rm -f "$shadow"
    done

    [ -f "$_mkinitcpio" ] &&
        sudo sed -i -E '/^HOOKS=/ s/(^|[( ])resume /\1/' "$_mkinitcpio" &&
        sudo mkinitcpio -P

    [ -f "$_grub" ] &&
        sudo sed -i -E 's|^(GRUB_CMDLINE_LINUX_DEFAULT=.*[ "])resume=[^ "]*|\1|' "$_grub" &&
        sudo grub-mkconfig -o /boot/grub/grub.cfg

    sudo rm -f "$_tmpfiles"

    return 0
}
