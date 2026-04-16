#!/usr/bin/env bash
# run_onchange_02_nvim.sh
# Install neovim pre-built binary to /opt
# run_onchange → re-runs automatically when this file changes (version bump)
#
# To upgrade: change NVIM_VERSION below, chezmoi will re-run this script.

set -euo pipefail

# ── Version pin ───────────────────────────────────────────────────────────────
# bump this to trigger re-install via run_onchange
NVIM_VERSION="0.12.1"

# ── Helpers ───────────────────────────────────────────────────────────────────

info()    { echo "[nvim] $*"; }
success() { echo "[nvim] ✓ $*"; }

# ── Arch detection ────────────────────────────────────────────────────────────

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  NVIM_ARCH="x86_64" ;;
  aarch64) NVIM_ARCH="arm64" ;;
  *)
    echo "[nvim] ERROR: Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

NVIM_DIR="nvim-linux-${NVIM_ARCH}"
NVIM_ARCHIVE="${NVIM_DIR}.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_ARCHIVE}"
NVIM_INSTALL_PATH="/opt/${NVIM_DIR}"
NVIM_BIN="${NVIM_INSTALL_PATH}/bin/nvim"

# ── Check current version ─────────────────────────────────────────────────────

if [[ -x "$NVIM_BIN" ]]; then
  CURRENT="$("$NVIM_BIN" --version | head -1 | awk '{print $2}' | tr -d 'v')"
  if [[ "$CURRENT" == "$NVIM_VERSION" ]]; then
    info "neovim $NVIM_VERSION already installed, skipping."
    exit 0
  fi
  info "Upgrading neovim $CURRENT → $NVIM_VERSION"
fi

# ── Download & install ────────────────────────────────────────────────────────

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

info "Downloading neovim $NVIM_VERSION ($NVIM_ARCH)..."
curl -L --progress-bar "$NVIM_URL" -o "$TMPDIR/$NVIM_ARCHIVE"

info "Installing to /opt..."
sudo rm -rf "$NVIM_INSTALL_PATH"
sudo tar -C /opt -xzf "$TMPDIR/$NVIM_ARCHIVE"

success "neovim $NVIM_VERSION installed at $NVIM_INSTALL_PATH"
info "Ensure this is in your PATH: export PATH=\"\$PATH:/opt/${NVIM_DIR}/bin\""
# PATH export is handled in dot_zshrc (chezmoi managed)
