-- Theme "Windows XP" (Luna style): blue taskbar, green start button, blue window borders,
-- green hills. Terminal and editor dark like the console.
return {
	colors = {
		bg = "#0c1830",
		bg_dark = "#081022",
		surface = "#1a2c52",
		surface2 = "#7a96df",
		fg = "#ffffff",
		muted = "#c3d3fd",
		accent = "#0054e3",
		olive = "#3c9a3c",
		teal = "#0f8ef6",
		orange = "#f0a050",
		red = "#e04343",
	},
	hypr = {
		border_size = 3,
		-- Taskbar at the bottom: a single window also keeps gaps, border, rounding
		smart_gaps = false,
		-- Like the Luna title bars: blue gradient
		border_gradient = { "#0054e3", "#3b8cf5" },
		-- XP start menu (startmenu.py): bottom left above the taskbar, no border
		window_rules = {
			{
				name = "xp-startmenu",
				match = { class = "^xp-startmenu$" },
				float = true,
				size = "460 580",
				move = "0 monitor_h-610",
				border_size = 0,
				rounding = 0,
				no_anim = true,
				-- Focus stays in the menu (follow_mouse would take it away when moving the mouse);
				-- close: Esc, Super/start button again, pick an entry
				stay_focused = true,
			},
		},
		config = {
			general = { gaps_in = 5, gaps_out = 10 },
			decoration = {
				rounding = 7,
				shadow = { enabled = true, range = 12, render_power = 2, color = "rgba(00000066)", offset = "2 3" },
			},
		},
	},
}
