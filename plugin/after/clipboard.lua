if vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = "wl-copy"
end

local function use_system_clipboard()
  vim.opt.clipboard = "unnamedplus"
end

use_system_clipboard()

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("custom_system_clipboard", { clear = true }),
  callback = use_system_clipboard,
})
