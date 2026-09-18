#!/usr/bin/env bash
# bootstrap.sh — install neovim + LazyVim dengan config yang sama (macOS & Linux)
#
#   git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh
#
# Env:
#   DOTFILES_SKIP_PKGS=1   skip install package (buat tes / kalau deps udah ada)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_CFG="$XDG_CFG/nvim"

log()  { printf '\033[34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# ---------- 1. detect OS ----------
case "$(uname -s)" in
  Darwin) OS=darwin ;;
  Linux)  OS=linux  ;;
  *)      die "OS tidak didukung: $(uname -s)" ;;
esac

if   command -v apt-get >/dev/null; then PM=apt
elif command -v dnf     >/dev/null; then PM=dnf
elif command -v pacman  >/dev/null; then PM=pacman
else                                     PM=none
fi

# ---------- 2. package ----------
install_pkgs() {
  if [ "$OS" = darwin ]; then
    command -v brew >/dev/null || die "Homebrew belum ada → https://brew.sh"
    log "brew install neovim ripgrep fd fzf lazygit tree-sitter-cli node"
    brew install neovim ripgrep fd fzf lazygit tree-sitter-cli node
    return
  fi
  case "$PM" in
    apt)
      log "apt-get install …"
      sudo apt-get update -qq
      sudo apt-get install -y neovim ripgrep fd-find fzf build-essential git curl unzip nodejs npm
      ;;
    dnf)
      log "dnf install …"
      sudo dnf install -y neovim ripgrep fd-find fzf gcc make git curl unzip nodejs npm
      ;;
    pacman)
      log "pacman -S …"
      sudo pacman -S --needed --noconfirm neovim ripgrep fd fzf base-devel git curl unzip nodejs npm
      ;;
    *) warn "package manager tak dikenal — install manual: neovim>=0.9 ripgrep fd fzf gcc git node" ;;
  esac
  command -v tree-sitter >/dev/null 2>&1 ||
    npm i -g tree-sitter-cli >/dev/null 2>&1 ||
    warn "tree-sitter-cli gagal diinstall (opsional)"
}

# ---------- 3. neovim >= 0.9 ----------
nvim_ok() {
  command -v nvim >/dev/null || return 1
  local v maj min
  v="$(nvim --version | head -1 | sed 's/^NVIM v//')"
  maj="${v%%.*}"
  min="$(printf '%s' "$v" | cut -d. -f2)"
  [ "$maj" -gt 0 ] || [ "$min" -ge 9 ]
}

# tarball portable — dipakai kalau nvim repo masih < 0.9 (mis. Ubuntu 22.04)
install_nvim_tarball() {
  local arch asset tmp
  case "$(uname -m)" in
    aarch64|arm64) arch=arm64  ;;
    *)             arch=x86_64 ;;
  esac
  asset="nvim-linux-${arch}.tar.gz"
  tmp="$(mktemp -d)"
  log "download neovim ($asset) → ~/.local"
  curl -fL "https://github.com/neovim/neovim/releases/latest/download/$asset" |
    tar -xz -C "$tmp"
  mkdir -p "$HOME/.local/bin"
  cp -R "$tmp/nvim-linux-${arch}/." "$HOME/.local/"
  rm -rf "$tmp"
  hash -r
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) warn "tambah ini ke shell rc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
  esac
}

# ---------- 4. config ----------
install_config() {
  [ -d "$REPO/nvim" ] || die "folder config nggak ketemu: $REPO/nvim"
  if [ -e "$NVIM_CFG" ]; then
    local bak="$NVIM_CFG.bak-$(date +%Y%m%d-%H%M%S)"
    warn "config lama dipindah → $bak"
    mv "$NVIM_CFG" "$bak"
  fi
  mkdir -p "$XDG_CFG"
  log "copy config → $NVIM_CFG"
  cp -R "$REPO/nvim" "$NVIM_CFG"
}

# ---------- main ----------
[ "${DOTFILES_SKIP_PKGS:-0}" = 1 ] || install_pkgs

if ! nvim_ok; then
  if [ "$OS" = darwin ]; then
    die "nvim belum ada / terlalu tua. Jalankan: brew install neovim"
  fi
  warn "nvim belum ada atau < 0.9 → pakai tarball portable"
  install_nvim_tarball
  nvim_ok || die "nvim masih nggak kepakai — cek PATH"
fi

install_config

log "install plugin (headless Lazy sync, 1–3 menit)"
nvim --headless "+Lazy! sync" +qa || warn "ada plugin gagal — buka nvim lalu cek :Lazy"

log "selesai ✨  jalankan: nvim"
