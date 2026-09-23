# ── Resume restore — gamemode off, Kraken LCD back, after hibernation ───
#
# Same root → user bridge as 052-greeter-qylock.sh, on the other side of the
# sleep:
#
#   /etc/systemd/system/resume-restore-after-hibernate.service   (written here)
#     After=/WantedBy= the hibernating sleep targets, so it runs once the
#     machine is back. `--no-block` so it never holds up the resume.
#   ~/.config/systemd/user/resume-restore.service                (linked below)
#     runs .local/bin/resume-restore inside the graphical session.
#
# suspend-then-hibernate and hybrid-sleep are included because both can end
# in a hibernation image; resuming from their suspend phase runs the restore
# too, which costs one LCD push and turns gamemode off.

links=(
    .config/systemd/user/resume-restore.service
    .local/bin/resume-restore
)

_resume_unit=/etc/systemd/system/resume-restore-after-hibernate.service

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    sudo tee "$_resume_unit" >/dev/null <<UNIT
[Unit]
Description=Restore the desktop session after resume from hibernation
After=hibernate.target suspend-then-hibernate.target hybrid-sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl --user --machine=$USER@.host --no-block start resume-restore.service

[Install]
WantedBy=hibernate.target suspend-then-hibernate.target hybrid-sleep.target
UNIT

    sudo systemctl daemon-reload
    sudo systemctl enable resume-restore-after-hibernate.service
    systemctl --user daemon-reload
}

mod_check() {
    systemctl --quiet is-enabled resume-restore-after-hibernate.service
}

mod_post_uninstall() {
    sudo systemctl disable resume-restore-after-hibernate.service
    sudo rm -f "$_resume_unit"
    sudo systemctl daemon-reload
    systemctl --user daemon-reload
}
