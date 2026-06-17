# Tests

Drives the real `scripts/install.sh` for every module inside an Arch container
with a real `yay`, and prints a PASS/FAIL matrix of each module's install and
`--status` exit codes.

```bash
docker build -f test/Dockerfile -t dotfiles-test .
docker run --rm dotfiles-test
```

Heavy and slow — real repo/AUR builds. Host-only commands (`systemctl`,
`mkinitcpio`, `bootctl`, `spicetify`, `xdg-settings`) are shimmed to no-op
(`grub` is installed for real); anything needing GPU drivers or a running
desktop session can't be fully exercised in a container.

CI runs this same image on pushes to `main`, on pull requests, and on manual
dispatch — see `.github/workflows/install-test.yml`. AUR/network hiccups can
make a run flake; just re-run it.
