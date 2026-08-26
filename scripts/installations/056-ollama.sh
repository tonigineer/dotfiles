# ── Ollama — context sizing for agentic use + Claude Code wrapper ────────
#
# This module deliberately installs no packages. Ollama on this box came from
# upstream's install.sh (/usr/local/bin/ollama, models under
# /usr/share/ollama, a hand-written /etc/systemd/system/ollama.service) and
# `pacman -Qo` confirms nothing owns it. Adding `ollama` to pkgs would put a
# second, differently-pathed copy alongside the first and leave two units
# fighting over port 11434. What this module owns is the configuration that
# makes the existing install usable as an agent backend.
#
# The problem it solves is a three-way disagreement about the context window:
#
#   1. Ollama picks OLLAMA_CONTEXT_LENGTH from available VRAM when it is
#      unset, which on a 24 GB card is 32768 — regardless of the model
#      advertising 262144 (`ollama show qwen3.8`).
#   2. Claude Code spends ~25k tokens on its system prompt and tool schemas
#      before the first user turn (visible as `task.n_tokens` in the server
#      log for a no-op prompt), leaving ~7k of a 32k window for real work.
#   3. Claude Code has no context-length entry for a local model name, so it
#      assumes 200k and does not auto-compact anywhere near the real limit.
#
# Nothing in that chain reports an error, because llama-server runs with
# --context-shift: on overflow it evicts the oldest tokens instead of
# refusing. The oldest tokens are the system prompt and the tool definitions,
# so the session degrades into a model that no longer knows it can call
# tools. It reads as "the model is bad" rather than "the window is too small".
#
# The two halves of the fix have to agree, so each has one source of truth:
# the drop-in sets the server's real window, and claude-ollama reads that same
# value back out of `systemctl show` to set CLAUDE_CODE_MAX_CONTEXT_TOKENS.
# Editing the drop-in is therefore enough; the wrapper follows.
#
# The module also owns a second, unrelated fix. Ollama treats a /v1/messages
# request that omits the `thinking` field as thinking ENABLED, and Claude Code
# always omits it — MAX_THINKING_TOKENS=0 suppresses the parameter rather than
# sending {"type": "disabled"}, so "off" and "unspecified" are indistinguishable
# on the wire. The reasoning tokens that come back count against max_tokens, and
# a turn that thinks its way to the ceiling is killed with "API Error: Claude's
# response exceeded the N output token maximum". It cannot be defaulted off in
# the model (`PARAMETER think false` is an unknown parameter) or on the server,
# and the field must be present per request, so claude-ollama-proxy.py sits in
# front of Ollama and inserts it. claude-ollama therefore points Claude Code at
# the shim rather than delegating to `ollama launch claude`, which overwrites
# ANTHROPIC_BASE_URL with its own value even when one is already exported.

# shellcheck disable=SC2154  # $dotfiles_dir is provided by install.sh

links=(
    .local/bin/claude-ollama
    .local/bin/claude-ollama-proxy.py
    .config/systemd/user/claude-ollama-proxy.service
)

_unit=ollama.service
_dropin_dir=/etc/systemd/system/ollama.service.d
_dropin="$_dropin_dir/override.conf"
_src_dropin=".config/systemd/system/ollama.service.d/override.conf"
_proxy_unit=claude-ollama-proxy.service

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    if ! command -v ollama >/dev/null 2>&1; then
        echo "ollama is not installed — see https://ollama.com/download;" \
            "the drop-in is written anyway and applies once it is." >&2
    fi

    sudo mkdir -p "$_dropin_dir"
    sudo cp -f "$dotfiles_dir/$_src_dropin" "$_dropin"

    # A restart is required, not a reload: OLLAMA_CONTEXT_LENGTH is read at
    # process start, and already-loaded models keep the slot size they were
    # loaded with until they are evicted.
    sudo systemctl daemon-reload || true
    sudo systemctl restart "$_unit" || true

    # The shim is a user unit: it needs no privileges and should follow the
    # login session rather than the boot.
    systemctl --user daemon-reload || true
    systemctl --user enable --now "$_proxy_unit" || true

    return 0
}

mod_check() {
    # Assert on the file this module owns rather than on live systemd state:
    # `systemctl show` is shimmed to a no-op in the test container, so a
    # runtime assertion would report a failure that only exists there.
    [ -f "$_dropin" ] &&
        cmp -s "$dotfiles_dir/$_src_dropin" "$_dropin"
}

mod_post_uninstall() {
    systemctl --user disable --now "$_proxy_unit" 2>/dev/null || true

    sudo rm -f "$_dropin"
    sudo rmdir "$_dropin_dir" 2>/dev/null || true

    sudo systemctl daemon-reload || true
    sudo systemctl restart "$_unit" || true

    return 0
}
