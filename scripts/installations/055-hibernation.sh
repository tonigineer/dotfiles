# ── Hibernation — swap sizing, resume hook, resume= cmdline, NVIDIA ─────
#
# Four things have to line up, and the module does all four:
#
#   1. mkinitcpio's `resume` hook, after `block` (needs the block devices)
#      and before `filesystems` (must run before root is mounted rw).
#   2. `resume=UUID=…` + `resume_offset=` on the kernel cmdline. Without
#      them /sys/power/resume stays 0:0, the image is ignored, and
#      hibernating looks like a slow poweroff. (Since systemd 255 the hook
#      execs systemd-hibernate-resume and the real resume goes through the
#      `HibernateLocation` EFI variable; the cmdline is the fallback, and
#      the only part `mod_check` can assert against.)
#   3. A resume area at least RAM-sized — see below.
#   4. NVIDIA agreeing to be frozen — see below.
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
# The file is dd'd, not fallocate'd: `iomap_swapfile_activate` rejects
# unwritten extents ("swapon: file has unallocated extents").
#
# `image_size` defaults to 2/5 of RAM, which forces the eviction above. The
# cap is raised to 85% of the resume area — comfortably over RAM, so the
# kernel has no reason to shrink at all.
#
# ── NVIDIA ─────────────────────────────────────────────────────────────
#
# `NVreg_PreserveVideoMemoryAllocations=1` and
# `NVreg_UseKernelSuspendNotifiers=1` are mutually exclusive: with both set
# the restore fails late (`nv_pmops_freeze … returns -5`), because Preserve
# requires /proc/driver/nvidia/suspend, which only exists when the notifiers
# are off. With the open modules the notifier path preserves video memory on
# its own, so drop Preserve. It comes from gpu-screen-recorder's
# /usr/lib/modprobe.d/gsr-nvidia.conf, shadowed here by a same-named file in
# /etc/modprobe.d (which wins outright).
#
# ── Noise ──────────────────────────────────────────────────────────────
#
# `spd5118 …: PM: failed to restore async: error -6` on every resume, once
# per DDR5 stick, is harmless: the RAM temperature sensor's resume callback
# writes before the SMBus controller is back, restore-phase errors are only
# logged (unlike the freeze-phase NVIDIA one, which kills the cycle), and
# the next `sensors` read repairs the register. Silencing it would mean
# blacklisting the module and losing the RAM temperatures.

# ── Configuration ───────────────────────────────────────────────────────

# The hibernation reserve; must be larger than RAM. Empty string = manage swap
# by hand, and configure whatever is already active.
_swapfile=/data/swapfile
_swapfile_bytes=$((64 * 1024 * 1024 * 1024))

# Higher number = preferred by the kernel, so paging stays off the reserve.
_swapfile_prio=5
_swappart_prio=10

_tmpfiles=/etc/tmpfiles.d/hibernation-image-size.conf
_mkinitcpio=/etc/mkinitcpio.conf
_grub=/etc/default/grub
_fstab=/etc/fstab
_marker='# Written by 055-hibernation.sh — shadows the packaged file.'
_fstab_marker='# Added by 055-hibernation.sh — hibernation reserve.'

# ── Helpers ─────────────────────────────────────────────────────────────

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

# True when both video-memory strategies are set at once. Reads modprobe's
# resolved view, so /etc shadowing /usr/lib is accounted for.
_vram_conflict() {
    local conf
    conf="$(modprobe --showconfig 2>/dev/null | grep '^options nvidia ')" || return 1

    printf '%s\n' "$conf" | grep -q 'NVreg_PreserveVideoMemoryAllocations=1' &&
        printf '%s\n' "$conf" | grep -q 'NVreg_UseKernelSuspendNotifiers=1'
}

# Packaged files that turn Preserve on, so each can be shadowed by name.
_preserve_sources() {
    grep -rls 'NVreg_PreserveVideoMemoryAllocations=1' /usr/lib/modprobe.d/ 2>/dev/null
}

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    local uuid offset size src shadow ram rebuild=0

    # 0. The reserve, before anything reads the swap layout.
    _ensure_swapfile || return 1
    _ensure_fstab

    uuid="$(_resume_uuid)"
    offset="$(_resume_offset)"
    size="$(_image_size)"

    # 1. resume hook, inserted between `block` and `filesystems`.
    if [ -f "$_mkinitcpio" ]; then
        sudo sed -i -E '/^HOOKS=/ { /(^|[( ])resume([ )]|$)/! s/(^|[( ])filesystems([ )])/\1resume filesystems\2/ }' \
            "$_mkinitcpio"
        rebuild=1
    else
        echo "No $_mkinitcpio — skipping the resume hook." >&2
    fi

    # 2. resume= / resume_offset=. Rewrite existing values instead of appending,
    #    so re-running after a repartition or resize is safe.
    if [ -n "$uuid" ] && [ -f "$_grub" ]; then
        if grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=.*[ "]resume=' "$_grub"; then
            sudo sed -i -E \
                "s|^(GRUB_CMDLINE_LINUX_DEFAULT=.*[ \"])resume=[^ \"]*|\1resume=UUID=$uuid|" \
                "$_grub"
        else
            sudo sed -i -E \
                "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\")(.*)(\")\$|\1\2 resume=UUID=$uuid\3|" \
                "$_grub"
        fi

        sudo sed -i -E 's|[ ]*resume_offset=[^ "]*||' "$_grub"
        sudo sed -i -E \
            "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\")(.*)(\")\$|\1\2 resume_offset=${offset:-0}\3|" \
            "$_grub"

        # Collapse the leading space an empty previous value would leave.
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

    # 4. Drop Preserve by shadowing whichever packaged file sets it. nvidia is
    #    in the initramfs (see MODULES=) and reads modprobe.d from there, so
    #    this only takes effect after the rebuild below.
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

    # 5. Warn if the reserve is below RAM — nothing above can fix that.
    ram="$(awk '/^MemTotal:/ { print $2 * 1024 }' /proc/meminfo)"
    if [ -n "$ram" ] && [ "$(_resume_bytes)" -lt "$ram" ] 2>/dev/null; then
        echo "Resume area $(_resume_area) is smaller than RAM — a full session may not fit." >&2
    fi

    return 0
}

mod_check() {
    local uuid offset

    ! _vram_conflict || return 1

    [ -z "$_swapfile" ] || [ -s "$_swapfile" ] || return 1

    uuid="$(_resume_uuid)"

    # No swap to point resume= at: the rest is moot.
    [ -n "$uuid" ] || return 0

    # Empty = filefrag needed a password; assert only that the parameter is
    # present, not that it is current.
    offset="$(_resume_offset)"
    [ -n "$offset" ] || offset='[0-9]+'

    grep -qE '^HOOKS=.*(^|[( ])resume([ )])' "$_mkinitcpio" &&
        grep -qE "^GRUB_CMDLINE_LINUX_DEFAULT=.*resume=UUID=$uuid" "$_grub" &&
        grep -qE "^GRUB_CMDLINE_LINUX_DEFAULT=.*resume_offset=$offset([ \"])" "$_grub" &&
        [ -f "$_tmpfiles" ]
}

mod_pre_uninstall() {
    # Out of use before the fstab entry goes, or the file cannot be removed.
    [ -n "$_swapfile" ] && [ -s "$_swapfile" ] &&
        sudo swapoff "$_swapfile" 2>/dev/null

    return 0
}

mod_post_uninstall() {
    local shadow

    # Only the shadows this module wrote, not hand-made overrides.
    for shadow in /etc/modprobe.d/*.conf; do
        [ -f "$shadow" ] && head -1 "$shadow" | grep -qF "$_marker" &&
            sudo rm -f "$shadow"
    done

    if [ -n "$_swapfile" ] && [ -f "$_fstab" ]; then
        sudo sed -i -E "\|^$_fstab_marker\$|d; \|^$_swapfile[[:space:]]|d" "$_fstab"
        sudo rm -f "$_swapfile"
        sudo systemctl daemon-reload || true
    fi

    [ -f "$_mkinitcpio" ] &&
        sudo sed -i -E '/^HOOKS=/ s/(^|[( ])resume /\1/' "$_mkinitcpio" &&
        sudo mkinitcpio -P

    [ -f "$_grub" ] &&
        sudo sed -i -E 's|^(GRUB_CMDLINE_LINUX_DEFAULT=.*[ "])resume=[^ "]*|\1|; s|[ ]*resume_offset=[^ "]*||' "$_grub" &&
        sudo grub-mkconfig -o /boot/grub/grub.cfg

    sudo rm -f "$_tmpfiles"

    return 0
}
