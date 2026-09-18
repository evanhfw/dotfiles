return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = {
    enable = true,
    max_lines = 5,
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 20,
    trim_scope = "outer",
    mode = "cursor", -- "topline" biar tetap di atas pas scroll
  },
}
