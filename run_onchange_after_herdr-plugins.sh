#!/usr/bin/env bash
# run_onchange: pasang plugin herdr dari GitHub (idempotent)
#
# herdr tidak punya manifest deklaratif untuk plugin dan plugins.json adalah
# state runtime (di-.chezmoiignore), jadi install lewat CLI. Ref di-pin ke
# commit supaya mesin lain tidak diam-diam naik versi.
set -uo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

if ! command -v herdr >/dev/null; then
  echo "==> herdr belum ada, skip plugin"
  exit 0
fi

id=vim-herdr-navigation
repo=paulbkim-dev/vim-herdr-navigation
ref=53e318c772c4d3b7fbd904ac43bcf3e5b5d8b244

if herdr plugin list 2>/dev/null | grep -q -- "- $id "; then
  echo "==> plugin $id sudah terpasang"
  exit 0
fi

echo "==> pasang plugin $id @ ${ref:0:7}"
if ! herdr plugin install "$repo" --ref "$ref" --yes; then
  echo "!! install plugin gagal (biasanya jaringan)."
  echo "   Ulangi: herdr plugin install $repo --ref $ref --yes"
fi
