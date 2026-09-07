# ── Hibernation — swap sizing, resume hook, resume location, NVIDIA ────
#
# Three things have to line up, and the module does all three:
#
#   1. mkinitcpio's `resume` hook, after `block` (needs the block devices)
#      and before `filesystems` (must run before root is mounted rw).
#   2. A way for the initrd to find the image. On EFI that is systemd's
#      `HibernateLocation` variable — written at hibernate time, read back
#      by systemd-hibernate-resume, which the hook execs since systemd 255
#      — so nothing is needed on the cmdline. Off EFI there is no variable,
#      and `resume=UUID=…` + `resume_offset=` go on the cmdline instead;
#      with neither, /sys/power/resume stays 0:0, the image is ignored, and
#      hibernating looks like a slow poweroff. Why EFI drops the cmdline
#      instead of keeping it as a second path: see "Cmdline" below.
#   3. A resume area at least RAM-sized — see below.
#
# ── Sizing ──────────────────────────────────────────────────────────────
#
# A single 16 GiB area is not enough: to hit `image_size` the kernel first
# evicts anonymous pages *to swap*, then writes the image into what is left
# of the same area — ENOSPC at 20%, and the aborted cycle wedges the GPU.
# Lowering `image_size` makes it worse, not better: it only moves bytes from
# the image into swapped-out pages on the same device. Hence two areas:
#
#   /dev/nvme0n1p2   16 GiB partition, pri=10  ← ordinary paging
#   /data/swapfile   64 GiB file,      pri=5   ← hibernation reserve
#
# Higher priority wins for paging, so day-to-day traffic stays off the
# reserve; the image always goes to the resume area, which `_resume_area`
# picks by size. The partition cannot be grown (no free space around it on
# nvme0n1), so the reserve is a file on /data.
#
# That split is the Z790E layout; every machine needs its own path and size,
# which is why the reserve is declared per host under "Configuration".
#
# The file is dd'd, not fallocate'd: `iomap_swapfile_activate` rejects
# unwritten extents ("swapon: file has unallocated extents").
#
# `image_size` defaults to 2/5 of RAM, which forces the eviction above. The
# cap is raised to 85% of the resume area — comfortably over RAM, so the
# kernel has no reason to shrink at all.
#
# ── NVIDIA ─────────────────────────────────────────────────────────────
#
# Leave `NVreg_PreserveVideoMemoryAllocations` alone — it must stay 1, which
# it already is via gpu-screen-recorder's /usr/lib/modprobe.d/gsr-nvidia.conf.
# It does *not* conflict with `NVreg_UseKernelSuspendNotifiers=1`: the
# notifiers only decide who triggers the save (in-kernel, instead of the
# nvidia-{suspend,hibernate,resume} services), not whether video memory is
# saved at all. nvidia-utils' own nvidia-sleep.conf enables the notifiers
# alongside `NVreg_TemporaryFilePath`, which only the Preserve path uses.
#
# With Preserve off the image restores, but every client allocation comes
# back unmapped: `Xid 31 … MMU Fault … FAULT_PDE` against Hyprland and
# quickshell, then `nv_drm_atomic_commit … Error code: -11` and `Flip event
# timeout` on both heads — a resumed kernel with a dead display.
#
# ── Cmdline ────────────────────────────────────────────────────────────
#
# `resume=` on an EFI system is redundant with the EFI variable, and not
# free: the hook writes the device to /sys/power/resume on *every* boot, so
# a boot with no image on disk gets `PM: Image not found (code -22)` from
# the kernel and `Unable to resume from device '…' (259:1) offset …,
# continuing boot process.` from systemd-hibernate-resume — on the console,
# before the journal exists. Both are cosmetic: the write fails precisely
# because there is nothing to resume. Nothing quiets them while the
# parameter is set (they are printed before any log filter applies), but
# with it gone the hook finds no HibernateLocation, logs "not set, skipping"
# at debug level, and exits — a silent cold boot.
#
# Dropping it costs one recovery path: an image on disk whose EFI variable
# the firmware lost (NVRAM reset, power cut mid-hibernate) is no longer
# resumable. Every other failure — efivarfs unwritable, no variable space —
# makes `systemctl hibernate` refuse *before* it suspends, so a live session
# is never at risk. Off EFI systemd will not hibernate without the parameter
# at all ("Not running on EFI and resume= is not set. Hibernation is not
# safe."), which is why `_efi_boot` still writes it there.
#
# ── Sleep delay ────────────────────────────────────────────────────────
#
# Noctalia's session button suspends with `systemctl suspend-then-hibernate`
# on both machines (the `command` override on its suspend action), so the
# handover from RAM to disk is systemd's to schedule and HibernateDelaySec=
# is what bounds it. The setting means two different things per machine:
#
#   X13GEN5   Has a battery, so systemd arms an ACPI _BTP low-battery alarm
#             and hibernates on whichever comes first, the alarm or this
#             delay. Unset, only the alarm is armed and a suspended session
#             has no ceiling at all — which is the case that matters here,
#             because the notebook offers s2idle alone (`cat
#             /sys/power/mem_sleep` → `[s2idle]`, no deep S3) and idles
#             rather than powering the package down, so it keeps draining
#             and should reach disk well before the battery gets low.
#   Z790E     No battery, so the delay is the only trigger. 2h is already
#             systemd's default for that case; writing it out states the
#             same number on both machines instead of leaving one implicit.
#
# HibernateOnACPower= is left at its default (yes), so the countdown runs on
# the notebook plugged in or not; it is a no-op on Z790E, being effective
# only on systems with a battery.

# ── Noise ──────────────────────────────────────────────────────────────
#
# `spd5118 …: PM: failed to restore async: error -6` on every resume, once
# per DDR5 stick, is harmless: the RAM temperature sensor's resume callback
# writes before the SMBus controller is back, restore-phase errors are only
# logged (unlike a freeze-phase failure, which aborts the cycle), and the
# next `sensors` read repairs the register. Silencing it would mean
# blacklisting the module and losing the RAM temperatures.

# ── Configuration ───────────────────────────────────────────────────────

# The hibernation reserve; must be larger than RAM. Empty string = manage swap
# by hand, and configure whatever is already active.
#
# Per host, because the reserve has to sit on a filesystem the machine actually
# has, at a size that machine's RAM actually needs:
#
#   Z790E     64 GiB on /data, a filesystem of its own — the 16 GiB swap
#             partition cannot be grown, see "Sizing" above.
#   X13GEN5   40 GiB on /, the only filesystem with room (/home runs 84% full)
#             and comfortably over its 32 GB of RAM.
#
# An unknown machine gets no reserve rather than a guessed 40+ GiB file on a
# disk this repo knows nothing about. Everything below still runs and
# configures hibernation against whatever swap that machine already has.
case "$(dotfiles_host)" in
Z790E)
    _swapfile=/data/swapfile
    _swapfile_bytes=$((64 * 1024 * 1024 * 1024))
    ;;
X13GEN5)
    _swapfile=/swapfile
    _swapfile_bytes=$((40 * 1024 * 1024 * 1024))
    ;;
*)
    _swapfile=
    _swapfile_bytes=0
    ;;
esac

# Higher number = preferred by the kernel, so paging stays off the reserve.
_swapfile_prio=5
_swappart_prio=10

# How long suspend-then-hibernate stays in RAM before it goes to disk — see
# "Sleep delay" above. Empty string = leave systemd's default in place.
_hibernate_delay=2h

_tmpfiles=/etc/tmpfiles.d/hibernation-image-size.conf
_sleepconf=/etc/systemd/sleep.conf.d/10-hibernate.conf
_mkinitcpio=/etc/mkinitcpio.conf
_grub=/etc/default/grub
_fstab=/etc/fstab
_fstab_marker='# Added by 055-hibernation.sh — hibernation reserve.'

# ── Helpers ─────────────────────────────────────────────────────────────

# True when booted via EFI, where systemd's HibernateLocation variable makes
# the resume= cmdline redundant — see "Cmdline" above.
_efi_boot() {
    [ -d /sys/firmware/efi ]
}

# True when `resume` is already in HOOKS. The array is routinely wrapped across
# lines, so both this and the edit below address it as the range `HOOKS=(` … `)`
# rather than a single line — a line-wise test sees only `HOOKS=(base systemd …`
# and reports a hook that is there as missing, or adds a second one.
_hooks_range='/^HOOKS=\(/,/\)/'

_hooks_have_resume() {
    # -E, like both edits below: `$_hooks_range` escapes its parens for ERE,
    # where they are literal. Under sed's default BRE `\(` opens a group and the
    # range never matches, so the guard would read "no resume hook" every time.
    sed -n -E "${_hooks_range}p" "$_mkinitcpio" 2>/dev/null |
        grep -qE '(^|[( ])resume([ )])'
}

# The swap area the image is written to: the largest active one, so the reserve
# wins regardless of activation order. Falls back to fstab, for before the first
# `swapon` on a fresh install.
_resume_area() {
    local dev

    dev="$(swapon --noheadings --bytes --show=NAME,SIZE 2>/dev/null |
        sort -k2 -n -r | awk 'NR==1 { print $1 }')"

    if [ -z "$dev" ]; then
        dev="$(awk '$1 !~ /^#/ && $3 == "swap" { print $1; exit }' "$_fstab" 2>/dev/null)"
    fi

    printf '%s\n' "$dev"
}

# Echo the size of the resume area in bytes, or nothing if there is none.
_resume_bytes() {
    local dev
    dev="$(_resume_area)"
    [ -n "$dev" ] || return 0

    if [ -f "$dev" ]; then
        stat -c %s "$dev" 2>/dev/null
    else
        swapon --noheadings --bytes --show=NAME,SIZE 2>/dev/null |
            awk -v d="$dev" '$1 == d { print $2; exit }'
    fi
}

# The UUID for resume=: the swap area's own for a partition, the holding
# filesystem's for a swapfile (the kernel resumes from the block device and
# finds the header by offset).
_resume_uuid() {
    local dev

    dev="$(_resume_area)"
    [ -n "$dev" ] || return 0

    if [ -f "$dev" ]; then
        findmnt -no UUID -T "$dev" 2>/dev/null
        return 0
    fi

    case "$dev" in
    UUID=*) printf '%s\n' "${dev#UUID=}" ;;
    *) blkid -s UUID -o value -- "$dev" 2>/dev/null ;;
    esac
}

# resume_offset: 0 for a partition, else the physical block of the swapfile's
# first page — the swap header. -b4096 = PAGE_SIZE units. Fragmentation past
# that first page is irrelevant; the header maps absolute device sectors.
_resume_offset() {
    local dev

    dev="$(_resume_area)"
    [ -n "$dev" ] && [ -f "$dev" ] || {
        printf '0\n'
        return 0
    }

    # -n so `--status` never blocks on a password prompt; empty answer means
    # "cannot verify", not "wrong".
    sudo -n filefrag -v -b4096 "$dev" 2>/dev/null |
        awk '$1 == "0:" { sub(/\.\..*/, "", $4); print $4; exit }'
}

# image_size cap: 85% of the resume area, so a near-exact fit doesn't fail on
# the last page.
_image_size() {
    local bytes

    bytes="$(_resume_bytes)"
    [ -n "$bytes" ] || return 0

    printf '%s\n' $((bytes * 85 / 100))
}

# Create the reserve if declared and absent. dd, not fallocate — see header.
_ensure_swapfile() {
    local dir

    [ -n "$_swapfile" ] || return 0
    [ ! -s "$_swapfile" ] || return 0

    dir="$(dirname "$_swapfile")"
    if [ ! -d "$dir" ]; then
        echo "No $dir — cannot create the hibernation reserve." >&2
        return 1
    fi

    echo "Allocating $((_swapfile_bytes / 1024 / 1024 / 1024)) GiB at $_swapfile …"
    sudo dd if=/dev/zero of="$_swapfile" bs=1M \
        count=$((_swapfile_bytes / 1024 / 1024)) status=progress || return 1
    sudo chmod 600 "$_swapfile"
    sudo chown root:root "$_swapfile"
    sudo mkswap "$_swapfile" >/dev/null || return 1
}

# Priorities on both areas + the reserve registered, so the paging/hibernation
# split survives a reboot.
_ensure_fstab() {
    [ -f "$_fstab" ] || return 0

    # Existing swap partitions page first.
    sudo awk -v pri="$_swappart_prio" '
        $1 !~ /^#/ && $3 == "swap" && ($1 ~ /^UUID=/ || $1 ~ /^\/dev\//) {
            if ($4 !~ /pri=/) $4 = $4 ",pri=" pri
        }
        { print }
    ' "$_fstab" | sudo tee "$_fstab.055.tmp" >/dev/null &&
        sudo mv "$_fstab.055.tmp" "$_fstab"

    [ -n "$_swapfile" ] || return 0

    if ! awk -v f="$_swapfile" '$1 == f && $3 == "swap" { found = 1 } END { exit !found }' "$_fstab"; then
        printf '\n%s\n%s\tnone\tswap\tdefaults,pri=%s\t0 0\n' \
            "$_fstab_marker" "$_swapfile" "$_swapfile_prio" |
            sudo tee -a "$_fstab" >/dev/null
    fi

    sudo systemctl daemon-reload || true
    sudo swapon --all 2>/dev/null || true
}

# The suspend-then-hibernate delay. Written whole every run rather than
# edited: the drop-in carries one setting and this module owns the file, so
# there is nothing in it to preserve. systemd-sleep reads it per cycle, so
# there is nothing to reload either.
_ensure_sleep_conf() {
    [ -n "$_hibernate_delay" ] || return 0

    sudo mkdir -p "$(dirname "$_sleepconf")" || return 1

    printf '%s\n' \
        '# Added by 055-hibernation.sh — suspend-then-hibernate handover.' \
        '[Sleep]' \
        "HibernateDelaySec=$_hibernate_delay" |
        sudo tee "$_sleepconf" >/dev/null || return 1
}

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    local uuid offset size ram rebuild=0

    # 0. The reserve, before anything reads the swap layout.
    _ensure_swapfile || return 1
    _ensure_fstab

    uuid="$(_resume_uuid)"
    offset="$(_resume_offset)"
    size="$(_image_size)"

    # 1. resume hook, inserted between `block` and `filesystems`.
    if [ -f "$_mkinitcpio" ]; then
        if ! _hooks_have_resume; then
            sudo sed -i -E \
                "$_hooks_range s/(^|[( ])filesystems([ )])/\1resume filesystems\2/" \
                "$_mkinitcpio"
        fi
        rebuild=1
    else
        echo "No $_mkinitcpio — skipping the resume hook." >&2
    fi

    # 2. resume= / resume_offset=: stripped on EFI, written off it. Rewrite
    #    existing values instead of appending, so re-running after a
    #    repartition or resize is safe.
    if [ -f "$_grub" ] && { _efi_boot || [ -n "$uuid" ]; }; then
        if _efi_boot; then
            sudo sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ {
                s|[ ]*resume=[^ "]*||; s|[ ]*resume_offset=[^ "]*|| }' "$_grub"
        elif grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=.*[ "]resume=' "$_grub"; then
            sudo sed -i -E \
                "s|^(GRUB_CMDLINE_LINUX_DEFAULT=.*[ \"])resume=[^ \"]*|\1resume=UUID=$uuid|" \
                "$_grub"
        else
            sudo sed -i -E \
                "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\")(.*)(\")\$|\1\2 resume=UUID=$uuid\3|" \
                "$_grub"
        fi

        if ! _efi_boot; then
            sudo sed -i -E 's|[ ]*resume_offset=[^ "]*||' "$_grub"
            sudo sed -i -E \
                "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\")(.*)(\")\$|\1\2 resume_offset=${offset:-0}\3|" \
                "$_grub"
        fi

        # Collapse the leading space an emptied value would leave.
        sudo sed -i -E 's|^(GRUB_CMDLINE_LINUX_DEFAULT=")[[:space:]]+|\1|' "$_grub"

        # Fails on a container overlayfs (no real root device); the edit above
        # is the part this module owns.
        sudo grub-mkconfig -o /boot/grub/grub.cfg || true
    elif [ -z "$uuid" ]; then
        echo "No swap area found — cannot set resume=; hibernation stays unavailable." >&2
    fi

    # 3. Raise the image target above RAM, reapplied on every boot.
    if [ -n "$size" ]; then
        printf 'w /sys/power/image_size - - - - %s\n' "$size" |
            sudo tee "$_tmpfiles" >/dev/null
        sudo systemd-tmpfiles --create "$_tmpfiles" || true
    fi

    [ "$rebuild" -eq 1 ] && sudo mkinitcpio -P

    # 4. The delay the handover to disk runs on.
    _ensure_sleep_conf ||
        echo "Could not write $_sleepconf — suspend-then-hibernate keeps systemd's default delay." >&2

    # 5. Warn if the reserve is below RAM — nothing above can fix that.
    ram="$(awk '/^MemTotal:/ { print $2 * 1024 }' /proc/meminfo)"
    if [ -n "$ram" ] && [ "$(_resume_bytes)" -lt "$ram" ] 2>/dev/null; then
        echo "Resume area $(_resume_area) is smaller than RAM — a full session may not fit." >&2
    fi

    return 0
}

mod_check() {
    local uuid offset

    [ -z "$_swapfile" ] || [ -s "$_swapfile" ] || return 1

    uuid="$(_resume_uuid)"

    # No swap to point resume= at: the rest is moot.
    [ -n "$uuid" ] || return 0

    _hooks_have_resume || return 1
    [ -f "$_tmpfiles" ] || return 1

    # Value and not just presence, so a changed delay is a drifted module.
    [ -z "$_hibernate_delay" ] ||
        grep -qxF "HibernateDelaySec=$_hibernate_delay" "$_sleepconf" 2>/dev/null ||
        return 1

    if _efi_boot; then
        # HibernateLocation carries the location; a leftover cmdline would only
        # add the failed resume attempt to every cold boot.
        ! grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=.*[ "]resume(_offset)?=' "$_grub"
    else
        # Empty = filefrag needed a password; assert only that the parameter is
        # present, not that it is current.
        offset="$(_resume_offset)"
        [ -n "$offset" ] || offset='[0-9]+'

        grep -qE "^GRUB_CMDLINE_LINUX_DEFAULT=.*resume=UUID=$uuid" "$_grub" &&
            grep -qE "^GRUB_CMDLINE_LINUX_DEFAULT=.*resume_offset=$offset([ \"])" "$_grub"
    fi
}

mod_pre_uninstall() {
    # Out of use before the fstab entry goes, or the file cannot be removed.
    [ -n "$_swapfile" ] && [ -s "$_swapfile" ] &&
        sudo swapoff "$_swapfile" 2>/dev/null

    return 0
}

mod_post_uninstall() {
    if [ -n "$_swapfile" ] && [ -f "$_fstab" ]; then
        sudo sed -i -E "\|^$_fstab_marker\$|d; \|^${_swapfile}[[:space:]]|d" "$_fstab"
        sudo rm -f "$_swapfile"
        sudo systemctl daemon-reload || true
    fi

    [ -f "$_mkinitcpio" ] &&
        sudo sed -i -E "$_hooks_range s/(^|[( ])resume /\1/" "$_mkinitcpio" &&
        sudo mkinitcpio -P

    [ -f "$_grub" ] &&
        sudo sed -i -E 's|^(GRUB_CMDLINE_LINUX_DEFAULT=.*[ "])resume=[^ "]*|\1|; s|[ ]*resume_offset=[^ "]*||' "$_grub" &&
        sudo grub-mkconfig -o /boot/grub/grub.cfg

    sudo rm -f "$_tmpfiles" "$_sleepconf"

    return 0
}
