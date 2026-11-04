-- Theme "Wired": colors for Hyprland (hypr/theme.lua) and Hyprland specifics.
return {
	colors = {
		bg = "#0c0e0c",
		bg_dark = "#070807",
		surface = "#161a16",
		surface2 = "#232a23",
		fg = "#c9d6c3",
		muted = "#6f7d6b",
		accent = "#7fd88f",
		olive = "#9d84d8",
		teal = "#6fb3c8",
		orange = "#d8c060",
		red = "#d8607a",
	},
	hypr = {
		border_size = 1,
		dim_inactive = true,
		dim_strength = 0.25,
		-- Gradient green -> violet, slowly travels around the active window
		border_gradient = { "#7fd88f", "#9d84d8" },
		border_loop = true,
	},
}
