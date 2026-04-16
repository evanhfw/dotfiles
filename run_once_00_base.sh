#!/usr/bin/env bash
# run_once_00_base.sh
# Install base system packages via apt or pacman
# Safe to re-run (run_once guarantees single execution per machine)

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

info()    { echo "[base] $*"; }
success() { echo "[base] ✓ $*"; }
warning() { echo "[base] ⚠ $*"; }

has() { command -v "$1" &>/dev/null; }

# ── Detect package manager ───────────────────────────────────────────────────

if has apt-get; then
  PKG_MANAGER="apt"
elif has pacman; then
  PKG_MANAGER="pacman"
else
  echo "[base] ERROR: No supported package manager found (apt / pacman)"
  exit 1
fi

info "Detected package manager: $PKG_MANAGER"

# ── Package lists ─────────────────────────────────────────────────────────────

APT_PACKAGES=(
  curl wget git unzip zip tar
  p7zip-full
  gnupg ca-certificates
  jq
  xclip
  zsh
  tmux
  direnv
  btop
  build-essential        # needed by some tools
  software-properties-common
)

PACMAN_PACKAGES=(
  curl wget git unzip zip tar
  p7zip
  gnupg ca-certificates
  jq
  xclip
  zsh
  tmux
  direnv
  btop
  base-devel
)

# ── Install ───────────────────────────────────────────────────────────────────

if [[ "$PKG_MANAGER" == "apt" ]]; then
  info "Updating apt..."
  sudo apt-get update -qq

  info "Installing apt packages..."
  sudo apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"

elif [[ "$PKG_MANAGER" == "pacman" ]]; then
  info "Syncing pacman..."
  sudo pacman -Sy --noconfirm

  info "Installing pacman packages..."
  sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"
fi

success "Base packages installed."
