-- Theme "Windows XP" (Luna-Stil): blaue Taskleiste, gruener Startknopf, blaue Fensterrahmen,
-- gruene Huegellandschaft. Terminal und Editor dunkel wie die Konsole.
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
		-- Taskleiste unten: auch ein einzelnes Fenster mit Abstand, Rahmen, Rundung
		smart_gaps = false,
		-- Wie die Luna-Titelleisten: Blau-Verlauf
		border_gradient = { "#0054e3", "#3b8cf5" },
		-- XP-Startmenue (startmenu.py): unten links ueber der Taskleiste, ohne Rahmen
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
				-- Fokus bleibt im Menue (sonst nimmt follow_mouse ihn beim Bewegen der Maus weg);
				-- schliessen: Esc, Super/Startknopf erneut, Eintrag waehlen
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
