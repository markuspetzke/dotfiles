-- Theme "Windows 3.1" for Neovim: colorscheme, gruvbox overrides, own highlights.
-- DOS menu box for the start screen; width 46, content gets padded
local function box(lines)
  local w = 44
  local out = { "╔" .. string.rep("═", w) .. "╗" }
  for _, l in ipairs(lines) do
    if l == "-" then
      table.insert(out, "╠" .. string.rep("═", w) .. "╣")
    else
      table.insert(out, "║" .. l .. string.rep(" ", w - vim.fn.strdisplaywidth(l)) .. "║")
    end
  end
  table.insert(out, "╚" .. string.rep("═", w) .. "╝")
  return table.concat(out, "\n")
end
local v = vim.version()

return {
  colorscheme = "gruvbox",
  -- Header of the Neovim start screen (snacks dashboard)
  dashboard_header = box({
    string.format("  NEOVIM                    Version %d.%d.%d", v.major, v.minor, v.patch),
    "  (C) Neovim contributors, Apache-2.0",
    "-",
    "  Please select an option:",
  }),
  gruvbox = {
    contrast = "hard",
    palette_overrides = {
      dark0_hard = "#000000",
      dark0 = "#000000",
      dark0_soft = "#1c1c1c",
      dark1 = "#1c1c1c",
      dark2 = "#2e2e2e",
      dark3 = "#555555",
      dark4 = "#555555",
      light0_hard = "#ffffff",
      light0 = "#ffffff",
      light1 = "#c0c0c0",
      light2 = "#d0d0d0",
      light3 = "#aaaaaa",
      light4 = "#a0a0a0",
      bright_red = "#aa0000",
      bright_green = "#55ff55",
      bright_yellow = "#ffff55",
      bright_blue = "#5555ff",
      bright_purple = "#ff55ff",
      bright_aqua = "#55ffff",
      bright_orange = "#aa5500",
      gray = "#808080",
    },
  },
  highlights = {
    bg = "#000000",
    bg_dark = "#000000",
    bg_highlight = "#1c1c1c",
    visual = "#0000aa",
    fg = "#c0c0c0",
    comment = "#808080",
    accent = "#ffff55",
    yellow = "#ffff55",
    orange = "#aa5500",
  },
}
