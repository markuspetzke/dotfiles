-----------------
---- MODULES ----
-----------------

local host = require("./host.lua")
require("./theme.lua")
require("./binds.lua")
require("./monitors.lua")
require("./windowrule.lua")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- Wayland-Umgebung importieren, dann ueber systemd genau eine
	-- Dienstgruppe starten. Dadurch gibt es nach Reloads keine Duplikate.
	hl.exec_cmd(
		"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE; "
			.. "systemctl --user start hypr-session.target"
	)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- hl.env("XCURSOR_SIZE", "24")
-- hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
----- PERMISSIONS -----
-----------------------

-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 12,

		border_size = 2,

		-- Farben kommen aus theme.lua

		resize_on_border = true,
		allow_tearing = false,
		layout = "master",
	},

	decoration = {
		rounding = 9,
		rounding_power = 2,

		shadow = {
			enabled = true,
			range = 10,
			render_power = 3,
		},

		blur = {
			enabled = true,
			size = 4,
			passes = 2,
			vibrancy = 0.15,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Custom Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Animations list
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Master-Layout: neue Fenster rechts als Slave, Master bekommt 55 %.
hl.config({
	master = {
		new_status = "slave",
		new_on_top = false,
		mfact = 0.55,
	},
})

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		-- Fenster, die "Aufmerksamkeit" wollen (z.B. Browser-Link aus Discord), bekommen den Fokus.
		focus_on_activate = true,
		-- Kein Einfuegen per Mittelklick -- auf dem Desktop meist nur versehentlich.
		middle_click_paste = false,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "de",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

	},
})

if host.is_laptop then
	hl.config({
		input = {
			touchpad = {
				natural_scroll = false,
				tap_to_click = true,
				disable_while_typing = true,
			},
		},
	})

	hl.gesture({
		fingers = 3,
		direction = "horizontal",
		action = "workspace",
	})
end

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Smart Gaps: nur ein Fenster auf dem Workspace -> keine Gaps, keine Rundung.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
	name = "no-gaps-wtv1",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})
hl.window_rule({
	name = "no-gaps-f1",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

-- Terminal leicht transparent (Blur aus decoration.blur), alles andere opak.
hl.window_rule({
	name = "kitty-opacity",
	match = { class = "kitty" },
	opacity = "0.92 0.85",
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})
