-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")
require("config.options")

require("config.autocmds")
require("config.keymaps")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "astro",
  callback = function()
    vim.opt_local.iskeyword:remove("-")
  end,
})
-- require("bufferline").setup()
