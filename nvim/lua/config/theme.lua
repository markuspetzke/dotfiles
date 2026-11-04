-- Active desktop theme (~/.config/theme-current/nvim.lua, set with `theme <name>`).
-- Provides the colorscheme, gruvbox overrides and the palette for own highlights.
-- If the file is missing, themes/retro applies.
local M = {}

local function load(path)
  local ok, t = pcall(dofile, vim.fs.normalize(path))
  return ok and type(t) == "table" and t or nil
end

function M.get()
  if not M._cache then
    M._cache = load("~/.config/theme-current/nvim.lua") or load("~/.config/themes/retro/nvim.lua") or {}
  end
  return M._cache
end

-- Called by `theme <name>` in running instances: reread and apply the palette.
function M.reload()
  M._cache = nil
  local t = M.get()
  vim.o.background = t.background or "dark"
  if t.gruvbox and package.loaded["gruvbox"] then
    require("gruvbox").setup(t.gruvbox)
  end
  if t.colorscheme then
    pcall(vim.cmd.colorscheme, t.colorscheme)
  end
  return t.colorscheme or ""
end

return M
