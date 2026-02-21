local vim = vim

vim.opt.swapfile = false
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.lazyvim_check_order = false

-- line number
vim.o.number = true
vim.opt.relativenumber = true

-- vim.cmd.colorscheme "catppuccin"
vim.g.autoformat = true
vim.g.have_nerd_font = true
vim.opt.showmode = false
vim.o.cmdheight = 0
vim.opt.title = false
vim.opt.termguicolors = true
vim.opt.linebreak = true
vim.g.lazyvim_prettier_needs_config = false
vim.diagnostic.config({ virtual_text = true })
vim.diagnostic.config({ virtual_lines = true })
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.lazyredraw = false -- Zeige alle Redraws (wichtig für smooth!)
vim.opt.ttyfast = true -- Schnelleres Terminal
vim.opt.regexpengine = 0 -- Automatische Engine-Wahl
vim.opt.updatetime = 100 -- Von 250ms auf 100ms (für smoothere cursor updates)

-- Dashboard
vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#61afef" })
vim.api.nvim_set_hl(0, "DashboardCenter", { fg = "#98c379" })
vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#7c7c7c", italic = true })
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.foldtext = ""
vim.opt.laststatus = 3 -- global statusline
vim.opt.linebreak = true -- Wrap lines at convenient points
vim.opt.ruler = true -- Disable the default ruler
vim.opt.shiftround = true -- Round indent
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.smoothscroll = true
vim.opt.spelllang = { "en" }
vim.opt.tabstop = 2 -- Number of spaces tabs count for
