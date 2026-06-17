# ── Bash — shell + CLI eye-candy ────────────────────────────────────────

pkgs=(
    asciiquarium-transparent-git
    cmatrix-git
    cbonsai
    curl
    eza
    figlet
    fontconfig
    lolcat
    otf-monaspace
    tar
    terminus-font
    ttf-cascadia-code-nerd
    tty-clock
    unzip
    wget
    zip
)

links=(
    .bashrc
    .aliases
    .bash_profile
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    git config --global credential.helper store
    fc-cache -v
}
