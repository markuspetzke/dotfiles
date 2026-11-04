-- Aktives Desktop-Theme (~/.config/theme-current/nvim.lua, gesetzt mit `theme <name>`).
-- Liefert Colorscheme, gruvbox-Overrides und die Palette fuer eigene Highlights.
-- Fehlt die Datei, gilt themes/retro.
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

-- Von `theme <name>` in laufenden Instanzen aufgerufen: Palette neu lesen und anwenden.
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
