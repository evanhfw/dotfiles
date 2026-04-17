#!/usr/bin/env bash
# run_once_00_base.sh
# Install base system packages via apt, pacman, or dnf
# Safe to re-run (run_once guarantees single execution per machine)

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

info()    { echo "[base] $*"; }
success() { echo "[base] ✓ $*"; }
warning() { echo "[base] ⚠ $*"; }

has() { command -v "$1" &>/dev/null; }

# ── Ubuntu apt mirror helper ──────────────────────────────────────────────────

configure_ubuntu_apt_mirror() {
  local mirror_uri="mirror://mirrors.ubuntu.com/mirrors.txt"
  local mirror_uri_escaped="${mirror_uri//&/\\&}"

  [[ -r /etc/os-release ]] || return 0
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || return 0

  if [[ -f /etc/apt/sources.list.d/ubuntu.sources ]]; then
    if grep -Fq "URIs: ${mirror_uri}" /etc/apt/sources.list.d/ubuntu.sources; then
      info "Ubuntu mirrorlist already configured in ubuntu.sources."
    else
      info "Configuring Ubuntu mirrorlist in ubuntu.sources..."
      if ! sudo test -f /etc/apt/sources.list.d/ubuntu.sources.bak; then
        sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
      fi
      sudo sed -i -E "s|^URIs: .*|URIs: ${mirror_uri_escaped}|" /etc/apt/sources.list.d/ubuntu.sources
      success "Ubuntu mirrorlist configured."
    fi
    return 0
  fi

  if [[ -f /etc/apt/sources.list ]]; then
    if grep -Fq "$mirror_uri" /etc/apt/sources.list; then
      info "Ubuntu mirrorlist already configured in sources.list."
    else
      info "Configuring Ubuntu mirrorlist in sources.list..."
      if ! sudo test -f /etc/apt/sources.list.bak; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
      fi
      sudo sed -i -E \
        "s|https?://([a-zA-Z0-9._-]+\\.)?archive.ubuntu.com/ubuntu|${mirror_uri_escaped}|g; s|https?://security.ubuntu.com/ubuntu|${mirror_uri_escaped}|g" \
        /etc/apt/sources.list
      success "Ubuntu mirrorlist configured."
    fi
  fi
}

# ── Detect package manager ───────────────────────────────────────────────────

if has apt-get; then
  PKG_MANAGER="apt"
elif has pacman; then
  PKG_MANAGER="pacman"
elif has dnf; then
  PKG_MANAGER="dnf"
else
  echo "[base] ERROR: No supported package manager found (apt / pacman / dnf)"
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

DNF_PACKAGES=(
  curl wget git unzip zip tar
  p7zip p7zip-plugins
  gnupg2 ca-certificates
  jq
  xclip
  zsh
  tmux
  btop
  gcc gcc-c++ make
)

DNF_OPTIONAL_PACKAGES=(
  direnv
)

# ── Install ───────────────────────────────────────────────────────────────────

if [[ "$PKG_MANAGER" == "apt" ]]; then
  configure_ubuntu_apt_mirror

  info "Updating apt..."
  sudo apt-get update -qq

  info "Installing apt packages..."
  sudo apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"

elif [[ "$PKG_MANAGER" == "pacman" ]]; then
  info "Syncing pacman..."
  sudo pacman -Sy --noconfirm

  info "Installing pacman packages..."
  sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"

elif [[ "$PKG_MANAGER" == "dnf" ]]; then
  info "Installing dnf packages..."
  sudo dnf install -y "${DNF_PACKAGES[@]}"

  for pkg in "${DNF_OPTIONAL_PACKAGES[@]}"; do
    if sudo dnf install -y "$pkg"; then
      success "Optional package installed: $pkg"
    else
      warning "Optional package unavailable, skipping: $pkg"
    fi
  done
fi

success "Base packages installed."
