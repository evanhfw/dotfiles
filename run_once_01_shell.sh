#!/usr/bin/env bash
# run_once_01_shell.sh
# Install: oh-my-zsh, zsh plugins, starship prompt
# Assumes zsh is already installed (run_once_00_base.sh)

set -euo pipefail

# ── Helpers ───────────────────────────────────────────────────────────────────

info()    { echo "[shell] $*"; }
success() { echo "[shell] ✓ $*"; }

has() { command -v "$1" &>/dev/null; }

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  info "oh-my-zsh already installed, skipping."
else
  info "Installing oh-my-zsh..."
  # RUNZSH=no → don't switch shell mid-script
  # CHSH=no   → we handle chsh ourselves below
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "oh-my-zsh installed."
fi

# ── Set zsh as default shell ──────────────────────────────────────────────────

ZSH_PATH="$(which zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  info "Changing default shell to zsh..."
  # Add zsh to /etc/shells if missing (common on minimal systems)
  if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
  success "Default shell set to zsh."
else
  info "zsh is already default shell."
fi

# ── zsh-autosuggestions ───────────────────────────────────────────────────────

AUTOSUGGEST_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ -d "$AUTOSUGGEST_DIR" ]]; then
  info "zsh-autosuggestions already installed, skipping."
else
  info "Installing zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGEST_DIR"
  success "zsh-autosuggestions installed."
fi

# ── zsh-syntax-highlighting ───────────────────────────────────────────────────

SYNTAX_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [[ -d "$SYNTAX_DIR" ]]; then
  info "zsh-syntax-highlighting already installed, skipping."
else
  info "Installing zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$SYNTAX_DIR"
  success "zsh-syntax-highlighting installed."
fi

# ── Starship ──────────────────────────────────────────────────────────────────

if has starship; then
  info "starship already installed, skipping."
else
  info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  success "starship installed."
fi

success "Shell setup complete."
