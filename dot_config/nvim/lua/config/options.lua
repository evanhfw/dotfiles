-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Omarchy-style: warnna aether sebagai default
vim.g.colorscheme = "aether"
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.clipboard = "osc52" -- clipboard terminal; works over SSH/headless
vim.opt.clipboard = "unnamedplus" -- yank/delete/put memakai system clipboard
