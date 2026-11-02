-- Gemeinsame Palette "Bernstein-CRT": warmes Schwarz, Papier-Creme, Bernstein als
-- einziger Akzent; Oliv/Teal nur fuer Status. Gleiche Werte in waybar/style.css,
-- kitty.conf, hyprlock.conf, hyprtoolkit.conf, dunstrc und Neovim (gruvbox-Overrides).
local theme = {
	bg = "#1b1a16",
	bg_dark = "#141310",
	surface = "#2a2822",
	surface2 = "#36332b",
	fg = "#e6dcc3",
	muted = "#8a8370",
	amber = "#e8a33d",
	olive = "#8f9a5b",
	teal = "#5fa8a3",
	orange = "#d97a3a",
	red = "#c8553d",
}

-- "#rrggbb" + Alpha (0-255) -> "rgba(rrggbbaa)"
local function rgba(hex, alpha)
	return string.format("rgba(%s%02x)", hex:sub(2), alpha or 0xff)
end

hl.config({
	general = {
		col = {
			-- Eine Akzentfarbe, kein Verlauf
			active_border = rgba(theme.amber),
			inactive_border = rgba(theme.surface2),
		},
	},
	group = {
		col = {
			border_active = rgba(theme.amber),
			border_inactive = rgba(theme.surface2),
		},
		groupbar = {
			col = {
				active = rgba(theme.amber),
				inactive = rgba(theme.surface),
			},
			text_color = theme.bg,
			font_family = "DepartureMono Nerd Font",
		},
	},
})

return theme
