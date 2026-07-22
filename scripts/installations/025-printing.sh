# ── Printing — CUPS + Avahi (driverless WLAN printers) ──────────────────
#
# Enables printing to network printers that advertise themselves over mDNS
# (AirPrint / Mopria / IPP Everywhere), which is how most modern WLAN
# printers are reached — no vendor driver or PPD required.
#
# Three pieces have to line up, and *all three* are needed:
#
#   1. cups.service       — the print scheduler itself.
#   2. avahi-daemon       — resolves `*.local` mDNS names. Without it CUPS
#                           can see a queue but fails with "Unable to locate
#                           printer" when it tries to reach the host.
#   3. /etc/nsswitch.conf — the `hosts:` line must contain `mdns_minimal
#                           [NOTFOUND=return]`, otherwise glibc never asks
#                           Avahi and `.local` lookups fall through to DNS
#                           and fail. See `ensure_mdns_hosts` below.
#
# ── Adding a printer once this module is installed ──────────────────────
#
# Discover what is on the network (name, host, IP):
#
#   avahi-browse -rtp _ipp._tcp
#
# The `rp=` field in the output is the resource path (almost always
# `ipp/print`). Create the queue with the generic `everywhere` driver — it
# negotiates capabilities with the printer at print time:
#
#   sudo lpadmin -p <QueueName> -E \
#        -v "ipp://<HOST>.local:631/ipp/print" \
#        -m everywhere -D "<Description>" -L "WLAN"
#   sudo lpadmin -d <QueueName>          # make it the system default
#
# Prefer the `.local` hostname over a raw IP: DHCP may hand the printer a
# different address, and mDNS will still resolve the name.
#
# Inspect / troubleshoot:
#
#   lpstat -t                            # queues, URIs, jobs, state
#   lp -d <QueueName> <file>             # print
#   cancel -a <QueueName>                # clear a wedged queue
#   cupsenable <QueueName>               # un-pause after an error
#   sudo lpadmin -x <QueueName>          # delete a queue
#
# Queues live in /etc/cups/printers.conf and are machine-local state, so
# they are deliberately *not* managed by this repo.
# ────────────────────────────────────────────────────────────────────────

# Minimum set that makes driverless network printing work. Optional extras,
# installed by hand if wanted: `system-config-printer` (GTK queue manager),
# `cups-pdf` (print-to-PDF virtual printer).
pkgs=(
    cups
    cups-filters
    ghostscript
    avahi
    nss-mdns
)

# Deliberately no `remove_pkgs`: uninstall only *disables* printing, it never
# removes packages. Every package above is a shared system dependency —
# `avahi` is pulled in by pipewire-pulse, libcups, remmina and tinysparql;
# `ghostscript` by libspectre — so removing them fails the pacman
# transaction at best, and guts unrelated software at worst.

# ── Helpers ─────────────────────────────────────────────────────────────

nsswitch=/etc/nsswitch.conf

# Ensure the `hosts:` line consults Avahi for `.local` names.
#
# Also repairs a duplicated `hosts:` key (`hosts: hosts: mymachines …`),
# which glibc treats as a bogus service name — the effect is that every
# entry on the line is ignored and `.local` resolution silently breaks.
# Idempotent: safe to re-run.
ensure_mdns_hosts() {
    sudo cp -n "$nsswitch" "$nsswitch.dotfiles.bak"

    # Collapse a repeated leading "hosts:" key.
    sudo sed -i -E 's/^hosts:([[:space:]]*hosts:)+/hosts:/' "$nsswitch"

    # Insert mdns_minimal after `mymachines` if present, else right after
    # the key — it must come before `resolve`/`dns` to win `.local`.
    grep -qE '^hosts:.*mdns_minimal' "$nsswitch" ||
        sudo sed -i -E \
            's/^(hosts:[[:space:]]*)(mymachines[[:space:]]+)?/\1\2mdns_minimal [NOTFOUND=return] /' \
            "$nsswitch"
}

# Drop the mdns_minimal entry again, leaving the rest of the line intact.
remove_mdns_hosts() {
    sudo sed -i -E \
        's/^(hosts:.*)[[:space:]]+mdns_minimal[[:space:]]+\[NOTFOUND=return\]/\1/' \
        "$nsswitch"
}

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    ensure_mdns_hosts

    sudo systemctl enable --now avahi-daemon.service
    sudo systemctl enable --now cups.service

    # Let the local user administer queues without a root password prompt
    # from the GUI tools.
    sudo usermod -aG lp,sys "$USER" || true
}

mod_check() {
    systemctl --quiet is-active cups.service &&
        systemctl --quiet is-active avahi-daemon.service &&
        grep -qE '^hosts:.*mdns_minimal' "$nsswitch"
}

# Teardown is "stop printing", not "remove printing". Packages stay put; only
# the services and the nsswitch entry are reverted, so a re-install is just
# `mod_post_install` again.
mod_post_uninstall() {
    sudo systemctl disable --now cups.service || true
    sudo systemctl disable --now cups.socket || true

    # Avahi is left running on purpose — other packages (pipewire-pulse,
    # remmina, tinysparql) rely on the daemon for their own mDNS discovery.
    # Dropping `mdns_minimal` below is enough to switch printing off.
    remove_mdns_hosts
}
