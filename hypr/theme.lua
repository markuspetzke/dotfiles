-- Gemeinsame Palette (tokyonight-moon), passend zum Neovim-Theme.
-- Wird von hyprland.lua geladen; waybar/kitty/hyprlock nutzen dieselben Werte.
local theme = {
	bg = "#222436",
	bg_dark = "#1e2030",
	fg = "#c8d3f5",
	comment = "#636da6",
	blue = "#82aaff",
	cyan = "#86e1fc",
	magenta = "#c099ff",
	purple = "#fca7ea",
	green = "#c3e88d",
	yellow = "#ffc777",
	orange = "#ff966c",
	red = "#ff757f",
}

-- "#rrggbb" + Alpha (0-255) -> "rgba(rrggbbaa)"
local function rgba(hex, alpha)
	return string.format("rgba(%s%02x)", hex:sub(2), alpha or 0xff)
end

hl.config({
	general = {
		col = {
			active_border = { colors = { rgba(theme.blue, 0xee), rgba(theme.magenta, 0xee) }, angle = 45 },
			inactive_border = rgba(theme.comment, 0xaa),
		},
	},
	decoration = {
		shadow = { color = rgba(theme.bg_dark, 0xee) },
	},
	group = {
		col = {
			border_active = { colors = { rgba(theme.blue, 0xee), rgba(theme.magenta, 0xee) }, angle = 45 },
			border_inactive = rgba(theme.comment, 0xaa),
		},
		groupbar = {
			col = {
				active = rgba(theme.blue, 0xcc),
				inactive = rgba(theme.bg_dark, 0xcc),
			},
			text_color = theme.fg,
			font_family = "FiraCode Nerd Font",
		},
	},
})

return theme
