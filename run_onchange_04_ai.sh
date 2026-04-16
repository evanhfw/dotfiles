#!/usr/bin/env bash
# run_onchange_04_ai.sh
# Install AI / experimental tools
# run_onchange → update when this file changes
#
# IMPORTANT: Each tool is installed in isolation.
# A failure here MUST NOT affect the rest of the environment.
# All installs are wrapped in try/catch-style subshells.

set -uo pipefail
# Note: intentionally NO 'set -e' — we handle errors per-tool

# ── Helpers ───────────────────────────────────────────────────────────────────

info()    { echo "[ai] $*"; }
success() { echo "[ai] ✓ $*"; }
warn()    { echo "[ai] ⚠ $*"; }

has() { command -v "$1" &>/dev/null; }

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Wrapper: run a block, warn on failure, never exit
try_install() {
  local name="$1"
  shift
  if "$@"; then
    success "$name installed."
  else
    warn "$name install FAILED — skipping. Rest of setup is unaffected."
  fi
}

# ── opencode ──────────────────────────────────────────────────────────────────

install_opencode() {
  if has opencode; then
    info "opencode already installed, skipping."
    return 0
  fi
  info "Installing opencode..."
  curl -fsSL https://opencode.ai/install | bash
  npx skills add JuliusBrussee/caveman -a opencode
}

try_install "opencode" install_opencode

install_rtk() {
  if has rtk; then
    info "rtk already installed, skipping."
    return 0
  fi
  info "Installing rtk..."
  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | bash

}

try_install "RTK" install_rtk
# ── Add more AI tools below this line ────────────────────────────────────────
# Pattern:
#
#   install_mytool() {
#     has mytool && { info "mytool already installed, skipping."; return 0; }
#     info "Installing mytool..."
#     # install steps here
#   }
#   try_install "mytool" install_mytool

info "AI tools script complete."
