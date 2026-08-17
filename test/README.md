# Tests

Drives the real `scripts/install.sh` for every module inside an Arch container
with a real `yay`, and prints a PASS/FAIL matrix of each module's install and
`--status` exit codes.

```bash
docker build --pull --no-cache -f test/Dockerfile -t dotfiles-test .
docker run --rm --security-opt seccomp=unconfined dotfiles-test
```

`--pull --no-cache` matters: a cached base layer keeps an old `glibc` while the
modules pull today's packages, and the resulting partial upgrade shows up as
bogus failures (`node: GLIBC_2.44 not found`, `libelf breaks elfutils`).

`seccomp=unconfined` is needed for 031-shells: compiling `noctalia-git` under
Docker's default seccomp profile makes `cc1plus` die with random `internal
compiler error: Illegal instruction` on a different translation unit each run.

Heavy and slow — real repo/AUR builds. Host-only commands (`systemctl`,
`mkinitcpio`, `bootctl`, `spicetify`, `xdg-settings`) are shimmed to no-op
(`grub` is installed for real); anything needing GPU drivers or a running
desktop session can't be fully exercised in a container.

CI runs this same image on pushes to `main`, on pull requests, and on manual
dispatch — see `.github/workflows/install-test.yml`. AUR/network hiccups can
make a run flake; just re-run it.
