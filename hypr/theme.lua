-- Laedt das aktive Theme (~/.config/theme-current -> themes/<name>, gesetzt mit `theme <name>`)
-- und setzt Rahmen-/Gruppenfarben sowie Theme-Eigenheiten (Rahmenbreite, Abdunkeln).
-- Fehlt der Symlink, gilt themes/retro.
local home = os.getenv("HOME") or ""

local function load_theme(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local src = f:read("a")
	f:close()
	local chunk = load(src, "@" .. path)
	return chunk and chunk() or nil
end

local t = load_theme(home .. "/.config/theme-current/palette.lua")
	or load_theme(home .. "/.config/themes/retro/palette.lua")
local c = t.colors
local opt = t.hypr or {}

-- "#rrggbb" + Alpha (0-255) -> "rgba(rrggbbaa)"
local function rgba(hex, alpha)
	return string.format("rgba(%s%02x)", hex:sub(2), alpha or 0xff)
end

hl.config({
	general = {
		border_size = opt.border_size or 2,
		col = {
			-- Eine Akzentfarbe, kein Verlauf
			active_border = rgba(c.accent),
			inactive_border = rgba(c.surface2),
		},
	},
	decoration = {
		dim_inactive = opt.dim_inactive or false,
		dim_strength = opt.dim_strength or 0.25,
	},
	group = {
		col = {
			border_active = rgba(c.accent),
			border_inactive = rgba(c.surface2),
		},
		groupbar = {
			col = {
				active = rgba(c.accent),
				inactive = rgba(c.surface),
			},
			text_color = c.bg,
			font_family = "DepartureMono Nerd Font",
		},
	},
})

return c
