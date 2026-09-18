-- Omarchy-style setup (ala DHH's Omarchy Linux)
-- Theme utama: aether.nvim (default Omarchy), + tema alternatif Omarchy
-- buat cycle via :LazyVim colorscheme / :colorscheme <nama>
return {
  {
    "bjarneo/aether.nvim",
    priority = 1000,
    config = function()
      require("aether").setup({
        transparent = false,
      })
      vim.cmd.colorscheme("aether")
    end,
  },
  -- Tema alternatif bawaan Omarchy (lazy-load: cuma aktif pas dipilih)
  { "kepano/flexoki-neovim", lazy = true, name = "flexoki" },
  { "rebelot/kanagawa.nvim", lazy = true, name = "kanagawa" },
  { "folke/tokyonight.nvim", lazy = true, name = "tokyonight" },
  { "catppuccin/nvim", lazy = true, name = "catppuccin" },
  { "ellisonleao/gruvbox.nvim", lazy = true, name = "gruvbox" },
  { "rose-pine/neovim", lazy = true, name = "rose-pine" },

  -- Warna di atas sudah menang secara urutan (spec ini jalan setelah
  -- `lazyvim.config.init()`). Baris ini cuma bikin intent-nya eksplisit:
  -- LazyVim membaca opsi ini, BUKAN `vim.g.colorscheme`.
  { "LazyVim/LazyVim", opts = { colorscheme = "aether" } },
}