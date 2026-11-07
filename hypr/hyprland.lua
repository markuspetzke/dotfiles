-----------------
---- MODULES ----
-----------------

local host = require("./host.lua")
require("./binds.lua")
require("./monitors.lua")
require("./windowrule.lua")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- uwsm: pass WAYLAND_DISPLAY, DISPLAY and HYPRLAND_INSTANCE_SIGNATURE to systemd and
	-- report the compositor unit as ready. That reaches graphical-session.target,
	-- which pulls in hypr-session.target (WantedBy) -- no manual start needed.
	hl.exec_cmd("uwsm finalize")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- Session variables live in ~/.config/uwsm/env: uwsm passes them to Hyprland and to all
-- systemd services alike. Dark mode comes from gsettings (gtk-theme for
-- GTK3, color-scheme for GTK4/libadwaita), not from GTK_THEME.

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 8,
		-- Border width and colors come from the theme (hypr/theme.lua)
		resize_on_border = true,
		allow_tearing = false,
		layout = "master",
	},

	-- Base: square corners, no shadows, no blur. Themes may override this in palette.lua
	-- (e.g. tokyonight: rounding, blur, shadows).
	decoration = {
		rounding = 0,

		shadow = {
			enabled = false,
		},

		blur = {
			enabled = false,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Custom Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Animations list
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "popin 95%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.2, bezier = "linear", style = "popin 95%" })
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

-- Master layout: new windows go right as slaves, the master gets 55 %.
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
		-- Windows that ask for attention (e.g. a browser link from Discord) get focus.
		focus_on_activate = true,
		-- No middle-click paste -- on the desktop it is mostly accidental.
		middle_click_paste = false,
		-- VRR/FreeSync off: with 2 (fullscreen only) FreeSync toggles for every fullscreen window
		-- and the monitors briefly go black.
		vrr = 0,
		-- Wake monitors turned off by hypridle with a key press or mouse move.
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = true,
	},
	-- Direct scanout off: caused sporadic black screens in fullscreen games (TF2 via XWayland).
	render = {
		direct_scanout = 0,
	},
	-- No news/donation popups after Hyprland updates.
	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "de",
		-- Held key: repeat after 300 ms at 40 chars/s (default 600/25).
		repeat_delay = 300,
		repeat_rate = 40,
		follow_mouse = 1,
	},
})

if host.is_laptop then
	hl.config({
		input = {
			touchpad = {
				natural_scroll = true,
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

-- Smart gaps: only one window on the workspace -> no gaps, no rounding.
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

---------------
---- THEME ----
---------------

-- Load last: the active theme (themes/<name>/palette.lua) sets colors and may
-- override looks, animations and window rules from above.
require("./theme.lua")
