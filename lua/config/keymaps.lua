-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Snacks picker: make <a-w> (cycle_win) work from the preview window.
-- When the previewed file is already open, the preview shows that real buffer
-- and snacks never adds its preview keymaps to it, so <a-w> did nothing there.
vim.keymap.set("n", "<a-w>", function()
  local win = vim.api.nvim_get_current_win()
  for _, picker in ipairs(Snacks.picker.get()) do
    if picker.preview.win.win == win then
      return picker:action("cycle_win")
    end
  end
end, { desc = "Cycle picker window (from preview)" })
