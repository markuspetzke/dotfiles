-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable netrw early; snacks explorer owns file browsing.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.have_nerd_font = true

require("config.lazy")
require("config.options")

require("config.autocmds")
require("config.keymaps")
