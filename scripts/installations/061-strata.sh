# ── Strata — Claude Code against the local Qwen3.8-Flash-Next server ────
#
# Like 056-ollama, this module deliberately installs no packages. Strata's
# Terminal comes from upstream's install.sh, which unpacks it into
# ~/.local/share/strata/terminal/<version> and links ~/.local/bin/strata; it
# needs no root, writes nothing outside $HOME, and pacman owns none of it.
# There is no AUR package to add, and adding one would put a second copy
# alongside the first with two things claiming port 8080.
#
# What this module owns is the wrapper, and the reason it is a wrapper rather
# than a settings file is worth stating because Strata itself recommends the
# other option. `strata connect claude-code --write` merges ANTHROPIC_BASE_URL,
# the model aliases and the context limit into ~/.claude/settings.json. That
# file is read by every Claude Code session on this box, so doing it would
# silently redirect the ones meant to reach Anthropic — there is no per-project
# or per-shell escape from it short of editing the file back. claude-strata
# sets the same environment for one invocation, which is the same wiring
# scoped to the moment it is wanted. The reasoning for each variable is in the
# script.
#
# Not owned here, on purpose:
#
#   - The model files. ~84 GB of generated weights at /data/strata, chosen
#     with --data-dir because /home has ~72 GB free and the IQ3_S download
#     alone is 89.7 GB. /data is the second NVMe and already holds
#     /data/ollama/models for the same reason.
#   - The saved preset. `strata launch --save-preset default` records the
#     launch flags in Strata's own generated settings.json, next to the model
#     registry and the engine it downloaded for this card. That is cache, not
#     configuration: the flags that produced it are in claude-strata, which
#     recreates the preset if it is missing.
#
# The server is not started at boot and has no unit here. Loading pins 50-60 GB
# of weights and hands part of them to the card, which stalls the desktop for
# one to three minutes — too rude for a login, and pointless on the days the
# local model is not used. claude-strata starts it on demand and says what is
# happening; `strata launch --stop` frees it again.

# shellcheck disable=SC2154  # $dotfiles_dir is provided by install.sh

links=(
    .local/bin/claude-strata
)

_installer=https://github.com/Niko1221/Strata/releases/latest/download/install.sh

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    if ! command -v strata >/dev/null 2>&1; then
        echo "strata is not installed — run 'curl -fsSL $_installer | sh';" \
            "the wrapper is linked anyway and works once it is." >&2
    fi

    return 0
}

mod_check() {
    # Assert only on what this module owns. The Terminal, the engine and the
    # 84 GB of weights are upstream's installer's business and are absent in
    # the test container, so asserting on them would report a failure that
    # exists nowhere else; `links` already covers the wrapper.
    [ -x "$dotfiles_dir/.local/bin/claude-strata" ]
}
