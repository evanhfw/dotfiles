-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


-- Python virtualenv selector
local function map_venv_selector(buf)
  vim.keymap.set("n", "<leader>cv", "<cmd>VenvSelect<cr>", {
    buffer = buf,
    desc = "Select VirtualEnv",
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(args)
    map_venv_selector(args.buf)
  end,
})

if vim.bo.filetype == "python" then
  map_venv_selector(0)
end
