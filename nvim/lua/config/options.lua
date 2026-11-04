-- Register own highlights first, then load the colorscheme -- that
-- fires ColorScheme exactly once and overrides nothing twice.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user_highlights", { clear = true }),
  callback = function()
    -- Own additions only for schemes with a known palette; others stay untouched.
    local palettes = {
      tokyonight = {
        bg = "#222436",
        bg_dark = "#1e2030",
        bg_highlight = "#2f334d",
        visual = "#3b4161",
        fg = "#c8d3f5",
        comment = "#636da6",
        accent = "#82aaff",
        yellow = "#ffc777",
        orange = "#ff966c",
      },
    }
    -- The desktop theme's palette applies to its colorscheme (themes/<name>/nvim.lua).
    local theme = require("config.theme").get()
    if theme.colorscheme and theme.highlights then
      palettes[theme.colorscheme] = theme.highlights
    end
    local colors = palettes[(vim.g.colors_name or ""):match("^[^-]+")]
    if not colors then
      return
    end

    vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.fg, bg = colors.bg_dark })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.accent, bg = colors.bg_dark })
    vim.api.nvim_set_hl(0, "Pmenu", { fg = colors.fg, bg = colors.bg_dark })
    vim.api.nvim_set_hl(0, "PmenuSel", { fg = colors.bg, bg = colors.accent, bold = true })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = colors.bg_highlight })
    vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.comment })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.bg_highlight })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.yellow, bold = true })
    vim.api.nvim_set_hl(0, "LineNr", { fg = colors.comment })
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = colors.comment })
    vim.api.nvim_set_hl(0, "Visual", { bg = colors.visual })
    vim.api.nvim_set_hl(0, "Search", { fg = colors.bg, bg = colors.yellow })
    vim.api.nvim_set_hl(0, "IncSearch", { fg = colors.bg, bg = colors.orange })
    vim.api.nvim_set_hl(0, "Folded", { fg = colors.comment, bg = colors.bg_dark, italic = true })

    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#27D797" })
    vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { fg = "#5c6370" })
    vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = "#5c6370" })
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = colors.accent })
    vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = colors.comment, italic = true })
  end,
})

-- Colorscheme: default here; the one last picked with <leader>uC is remembered in
-- stdpath("state")/colorscheme and preferred on the next start.
-- The default comes from the desktop theme (`theme <name>` also writes it to the state below).
local default_colorscheme = require("config.theme").get().colorscheme or "tokyonight"
local colorscheme_file = vim.fs.joinpath(vim.fn.stdpath("state"), "colorscheme")

local function read_saved_colorscheme()
  local f = io.open(colorscheme_file, "r")
  if not f then
    return nil
  end
  local name = vim.trim(f:read("*a") or "")
  f:close()
  return name ~= "" and name or nil
end

-- Light/dark comes from the desktop theme (nvim.lua: background); set it before the colorscheme
vim.opt.background = require("config.theme").get().background or "dark"

local colorscheme = read_saved_colorscheme() or default_colorscheme
if not pcall(vim.cmd.colorscheme, colorscheme) then
  vim.notify(
    "Colorscheme not found: " .. colorscheme .. ", falling back to " .. default_colorscheme,
    vim.log.levels.WARN
  )
  pcall(vim.cmd.colorscheme, default_colorscheme)
end

-- Save every later change (picker, :colorscheme).
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user_colorscheme_persist", { clear = true }),
  callback = function(ev)
    if not ev.match or ev.match == "" then
      return
    end
    local f = io.open(colorscheme_file, "w")
    if f then
      f:write(ev.match)
      f:close()
    end
  end,
})

-- UI
vim.opt.termguicolors = true
-- background: see above (from the desktop theme, before the colorscheme)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.numberwidth = 4
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.smoothscroll = true
vim.opt.linebreak = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.winminwidth = 5
vim.opt.pumheight = 10
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
vim.opt.fillchars = { eob = " ", fold = "·", foldopen = "", foldclose = "", foldsep = " " }
vim.opt.pumblend = 8
vim.opt.splitkeep = "screen"
vim.opt.winborder = "rounded"
vim.opt.wildmode = "longest:full,full"
vim.opt.timeoutlen = 300
vim.opt.virtualedit = "block"
vim.opt.jumpoptions = "view"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftround = true

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"
-- The default adds -uu (hidden and ignored files); respect .gitignore instead.
vim.opt.grepprg = "rg --vimgrep"

-- Performance
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 250 -- CursorHold -> LSP documentHighlight

-- Clipboard
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Misc
vim.opt.confirm = true
vim.opt.mouse = "a"
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Diagnostics
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = false,
  virtual_lines = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  float = { source = "if_many" }, -- border: 'winborder'
})
