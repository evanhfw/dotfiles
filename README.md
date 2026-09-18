# dotfiles

Chezmoi-managed dotfiles. Target: **macOS**, **Ubuntu 26.04**, **Arch Linux**.

## Bootstrap

```bash
# 1. pasang chezmoi
#    Ubuntu: sudo apt install chezmoi   (atau: sh -c "$(curl -fsLS get.chezmoi.io)")
#    Arch:   sudo pacman -S chezmoi
#    macOS:  brew install chezmoi

# 2. clone + apply (script install paket ikut jalan)
chezmoi init --apply git@github.com:evanhfw/dotfiles.git
```

`chezmoi init --apply` melakukan:
1. clone repo ini ke `~/.local/share/chezmoi`
2. render template + copy file ke home (`chezmoi apply`)
3. jalankan `run_onchange_before_install-packages.sh.tmpl` → install paket
4. jalankan `run_onchange_after_mise-install.sh.tmpl` → `mise install`
5. jalankan `run_onchange_after_sync-lazy-plugins.sh.tmpl` → sync plugin LazyVim

> Login shell **diubah ke zsh** oleh script install (step 3) kalau belum.
> Log out / login ulang setelah bootstrap selesai.

## Isi

| Path | Isi |
|---|---|
| `dot_zshenv` + `dot_config/zsh/` | zsh: XDG, history, completion (carapace), eza/bat, mise, zoxide, fzf, yazi, direnv, starship. **Tanpa oh-my-zsh.** |
| `dot_config/nvim/` | LazyVim + extras (yanky, docker, git, go, json, markdown, python, toml, yaml), colorscheme **aether**, basedpyright+ruff, treesitter-context |
| `dot_config/mise/` | versi pinned: bun, node (LTS), pnpm, rust, uv |
| `dot_config/herdr/` | multiplexer: prefix `ctrl+space`, pane nav `ctrl+alt+hjkl` + arrows |
| `dot_config/yazi/` | file manager: `linemode=size`, opener nvim, keymap |
| `dot_config/pi/` | pi coding agent: provider + packages |

## Struktur penting

- **`.chezmoiignore`** — file yang tidak di-copy ke home (runtime state, scope per-OS)
- **`.chezmoiremove.tmpl`** — file yang dihapus dari home (sisa tmux lama)
- **`.gitignore`** — repo ini **PUBLIC**: kredensial & runtime state tidak pernah masuk
- **`run_onchange_*`** — idempotent; jalan ulang hanya kalau isinya berubah
  (`hash:` di header). Untuk memaksa jalan lagi: naikkan `# retry:` di
  `run_onchange_before_install-packages.sh.tmpl`.

## Setelah edit

```bash
chezmoi edit ~/.config/nvim/init.lua   # edit dari source dir
chezmoi diff                            # lihat apa yang akan berubah
chezmoi apply
chezmoi cd && git add -A && git commit -m "..." && git push
```

## Secrets

Repo ini tidak menyimpan kredensial. Kalau butuh file rahasia, pakai
`chezmoi add --encrypt` (age). Kunci dekripsi di `~/.config/chezmoi/key.txt`
— **jangan** pernah di-commit.
