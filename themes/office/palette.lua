-- Theme "Office": open-plan office after hours. Charcoal, paper beige, company blue,
-- post-it yellow. Dark, slightly rounded, soft shadows, no blur.
return {
	colors = {
		bg = "#1f2329",
		bg_dark = "#181b20",
		surface = "#2a2f37",
		surface2 = "#3d4450",
		fg = "#e6dfcf",
		muted = "#8d8778",
		accent = "#5b8ad0",
		olive = "#7fae5b",
		teal = "#4fa3b0",
		orange = "#d9893a",
		red = "#d0574a",
	},
	hypr = {
		border_size = 2,
		config = {
			general = { gaps_in = 5, gaps_out = 10 },
			decoration = {
				rounding = 5,
				shadow = { enabled = true, range = 14, render_power = 2, color = "rgba(00000070)", offset = "0 3" },
			},
		},
	},
}
