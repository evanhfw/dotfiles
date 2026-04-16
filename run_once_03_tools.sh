#!/usr/bin/env bash
# run_once_03_tools.sh
# Install CLI tools:
#   fzf, zoxide, lazygit, yazi, eza, bat, ripgrep, fd, dust, tldr, fastfetch
#
# Strategy:
#   - Use apt/pacman where the package is up-to-date enough
#   - Fall back to GitHub binary releases for tools that are stale/missing in apt
#   - No cargo, no pip, no npm — binary only

set -euo pipefail

# ── Helpers ───────────────────────────────────────────────────────────────────

info()    { echo "[tools] $*"; }
success() { echo "[tools] ✓ $*"; }
skip()    { echo "[tools] ↷ $1 already installed, skipping."; }

has() { command -v "$1" &>/dev/null; }

ARCH="$(uname -m)"   # x86_64 | aarch64
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Detect package manager
if command -v apt-get &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v pacman &>/dev/null; then
  PKG_MANAGER="pacman"
else
  echo "[tools] ERROR: No supported package manager found."
  exit 1
fi

# ── Pacman bulk install (most tools available in official/AUR) ────────────────

if [[ "$PKG_MANAGER" == "pacman" ]]; then
  info "Installing tools via pacman..."
  sudo pacman -S --noconfirm --needed \
    fzf zoxide lazygit yazi eza bat ripgrep fd dust tealdeer fastfetch
  success "pacman tools installed."
  exit 0
  # On Arch, everything is available and up-to-date — no fallback needed
fi

# ── APT path: mix of apt + GitHub binary releases ────────────────────────────
# apt packages that are reliable enough on Ubuntu/Debian:

info "Installing apt-available tools..."
sudo apt-get install -y --no-install-recommends \
  fzf \
  zoxide \
  ripgrep \
  fd-find \
  tmux

# fd-find installs as 'fdfind' on Ubuntu — symlink to 'fd'
if has fdfind && ! has fd; then
  ln -sf "$(which fdfind)" "$LOCAL_BIN/fd"
  success "symlinked fdfind → fd"
fi

# ── lazygit — GitHub release ──────────────────────────────────────────────────

install_lazygit() {
  info "Installing lazygit..."
  local VERSION
  VERSION=$(curl -sL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')

  local ARCH_STR="x86_64"
  [[ "$ARCH" == "aarch64" ]] && ARCH_STR="arm64"

  local URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VERSION}_Linux_${ARCH_STR}.tar.gz"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' RETURN

  curl -L --progress-bar "$URL" -o "$TMPDIR/lazygit.tar.gz"
  tar -C "$TMPDIR" -xzf "$TMPDIR/lazygit.tar.gz" lazygit
  install -m755 "$TMPDIR/lazygit" "$LOCAL_BIN/lazygit"
  success "lazygit installed."
}

has lazygit && skip "lazygit" || install_lazygit

# ── yazi — GitHub release ─────────────────────────────────────────────────────

install_yazi() {
  info "Installing yazi..."
  local ARCH_STR="x86_64-unknown-linux-musl"
  [[ "$ARCH" == "aarch64" ]] && ARCH_STR="aarch64-unknown-linux-musl"

  local URL="https://github.com/sxyazi/yazi/releases/latest/download/yazi-${ARCH_STR}.zip"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' RETURN

  curl -L --progress-bar "$URL" -o "$TMPDIR/yazi.zip"
  unzip -q "$TMPDIR/yazi.zip" -d "$TMPDIR"
  install -m755 "$TMPDIR/yazi-${ARCH_STR}/yazi" "$LOCAL_BIN/yazi"
  # ya & yazi-fm shell wrappers are optional, skip for now
  success "yazi installed."
}

has yazi && skip "yazi" || install_yazi

# ── eza — GitHub release ──────────────────────────────────────────────────────

install_eza() {
  info "Installing eza..."
  local ARCH_STR="x86_64-unknown-linux-musl"
  [[ "$ARCH" == "aarch64" ]] && ARCH_STR="aarch64-unknown-linux-musl"

  local URL="https://github.com/eza-community/eza/releases/latest/download/eza_${ARCH_STR}.tar.gz"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' RETURN

  curl -L --progress-bar "$URL" -o "$TMPDIR/eza.tar.gz"
  tar -C "$TMPDIR" -xzf "$TMPDIR/eza.tar.gz" ./eza
  install -m755 "$TMPDIR/eza" "$LOCAL_BIN/eza"
  success "eza installed."
}

has eza && skip "eza" || install_eza

# ── bat — GitHub release ──────────────────────────────────────────────────────
# apt has bat but often outdated; use release binary for consistency

install_bat() {
  info "Installing bat..."
  local ARCH_STR="x86_64-unknown-linux-musl"
  [[ "$ARCH" == "aarch64" ]] && ARCH_STR="aarch64-unknown-linux-musl"

  local VERSION
  VERSION=$(curl -sL "https://api.github.com/repos/sharkdp/bat/releases/latest" \
    | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')

  local URL="https://github.com/sharkdp/bat/releases/latest/download/bat-v${VERSION}-${ARCH_STR}.tar.gz"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' RETURN

  curl -L --progress-bar "$URL" -o "$TMPDIR/bat.tar.gz"
  tar -C "$TMPDIR" -xzf "$TMPDIR/bat.tar.gz" --strip-components=1 \
    "bat-v${VERSION}-${ARCH_STR}/bat"
  install -m755 "$TMPDIR/bat" "$LOCAL_BIN/bat"
  success "bat installed."
}

has bat && skip "bat" || install_bat

# ── dust — GitHub release ─────────────────────────────────────────────────────

install_dust() {
  info "Installing dust..."
  local ARCH_STR="x86_64-unknown-linux-musl"
  [[ "$ARCH" == "aarch64" ]] && ARCH_STR="aarch64-unknown-linux-musl"

  local URL="https://github.com/bootandy/dust/releases/latest/download/dust-$(curl -sL \
    https://api.github.com/repos/bootandy/dust/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)-${ARCH_STR}.tar.gz"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' RETURN

  curl -L --progress-bar "$URL" -o "$TMPDIR/dust.tar.gz"
  tar -C "$TMPDIR" -xzf "$TMPDIR/dust.tar.gz" --wildcards "*/dust"
  find "$TMPDIR" -name "dust" -type f -exec install -m755 {} "$LOCAL_BIN/dust" \;
  success "dust installed."
}

has dust && skip "dust" || install_dust

# ── tldr — GitHub release (tealdeer) ─────────────────────────────────────────

install_tldr() {
  info "Installing tldr (tealdeer)..."
  local ARCH_STR="x86_64-unknown-linux-musl"
  [[ "$ARCH" == "aarch64" ]] && ARCH_STR="aarch64-unknown-linux-musl"

  local URL="https://github.com/dbrgn/tealdeer/releases/latest/download/tealdeer-linux-${ARCH_STR}"
  curl -L --progress-bar "$URL" -o "$LOCAL_BIN/tldr"
  chmod 755 "$LOCAL_BIN/tldr"
  # update cache on first install
  "$LOCAL_BIN/tldr" --update &>/dev/null || true
  success "tldr (tealdeer) installed."
}

has tldr && skip "tldr" || install_tldr

# ── fastfetch — GitHub release ────────────────────────────────────────────────

install_fastfetch() {
  info "Installing fastfetch..."
  local ARCH_STR="amd64"
  [[ "$ARCH" == "aarch64" ]] && ARCH_STR="arm64"

  local VERSION
  VERSION=$(curl -sL "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" \
    | grep '"tag_name"' | cut -d'"' -f4)

  local URL="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${ARCH_STR}.deb"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' RETURN

  curl -L --progress-bar "$URL" -o "$TMPDIR/fastfetch.deb"
  sudo dpkg -i "$TMPDIR/fastfetch.deb"
  success "fastfetch installed."
}

has fastfetch && skip "fastfetch" || install_fastfetch

# ── tmux plugin manager (TPM) ─────────────────────────────────────────────────

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
  skip "TPM"
else
  info "Installing TPM..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  success "TPM installed."
fi

success "All tools installed. Binaries in: $LOCAL_BIN"
info "Ensure '$LOCAL_BIN' is in your PATH (handled by dot_zshrc)."
