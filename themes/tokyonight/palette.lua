-- Theme "Tokyo Night": the setup from before the retro themes (tokyonight moon).
-- Rounded corners, blur, shadows, blue-violet gradient border, slightly transparent kitty.
return {
	colors = {
		bg = "#222436",
		bg_dark = "#1e2030",
		surface = "#2f334d",
		surface2 = "#636da6",
		fg = "#c8d3f5",
		muted = "#636da6",
		accent = "#82aaff",
		olive = "#c3e88d",
		teal = "#86e1fc",
		orange = "#ff966c",
		red = "#ff757f",
	},
	hypr = {
		border_size = 2,
		border_gradient = { "#82aaff", "#c099ff" },
		-- Overrides the square base look from hypr/hyprland.lua
		config = {
			general = { gaps_in = 5, gaps_out = 12 },
			decoration = {
				rounding = 9,
				rounding_power = 2,
				shadow = { enabled = true, range = 10, render_power = 3, color = "rgba(1e2030ee)" },
				blur = { enabled = true, size = 4, passes = 2, vibrancy = 0.15 },
			},
		},
		animations = {
			{ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" },
			{ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" },
			{ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" },
		},
		window_rules = {
			-- Terminal slightly transparent (blur), everything else opaque
			{ name = "kitty-opacity", match = { class = "kitty" }, opacity = "0.92 0.85" },
		},
	},
}
