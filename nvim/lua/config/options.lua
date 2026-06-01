local colorscheme = "kanso" -- catppuccin, rose-pine, kanso, kanagawa, horizon
local ok = pcall(vim.cmd.colorscheme, colorscheme)
if not ok then
  vim.notify("Colorscheme not found: " .. colorscheme, vim.log.levels.WARN)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user_highlights", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#27D797" })
    vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { fg = "#5c6370" })
    vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = "#5c6370" })
    vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "DashboardCenter", { fg = "#98c379" })
    vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#7c7c7c", italic = true })
  end,
})
vim.api.nvim_exec_autocmds("ColorScheme", {})

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false
vim.opt.cmdheight = 0
vim.opt.termguicolors = true
vim.opt.title = false
vim.opt.laststatus = 3
vim.opt.ruler = false
vim.opt.scrolloff = 10
vim.opt.smoothscroll = true
vim.opt.linebreak = true

-- Indentation
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.shiftround = true

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.foldtext = ""

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Performance
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 100
vim.opt.regexpengine = 0

-- Clipboard
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Spelling
vim.opt.spelllang = { "en" }

-- Misc
vim.opt.confirm = true

-- Diagnostics
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
})
