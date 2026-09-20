-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable netrw early; snacks explorer owns file browsing.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Remote-Provider werden nicht genutzt (keine Python/Ruby/Perl/Node-Plugins).
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

require("config.lazy")
require("config.options")

require("config.autocmds")
require("config.keymaps")
