local host = require("./host.lua")

hl.window_rule({
	name = "Picture-in-Picture",
	match = { title = "Picture-in-Picture" },

	float = true,
	pin = true, -- stays visible when switching workspaces
	size = "25% 25%",
	move = "monitor_w-100%-20 monitor_h-100%-20", -- bottom right
})

-- Dialogs (open/save file, polkit prompts) float centered. The German titles match
-- dialogs of programs running with a German locale.
hl.window_rule({
	name = "dialogs-float",
	match = {
		title = "^(Open File|Save File|Save As|Select Folder|Choose Files|Datei öffnen|Datei speichern|Speichern unter|Ordner auswählen)( .*)?$",
	},

	float = true,
	center = true,
})

hl.window_rule({
	name = "polkit-float",
	match = { class = "hyprpolkitagent" },

	float = true,
	center = true,
})

hl.window_rule({
	name = "emulator",
	match = { title = "Emulator" },

	float = true,
})

hl.window_rule({
	name = "tf2",
	match = { class = "tf_linux64" },

	-- Always on the 165 Hz main monitor (otherwise TF2 lands on the monitor with the mouse,
	-- e.g. the left one when Steam is open there). Desktop only, the laptop has no DP-2.
	monitor = host.is_desktop and "DP-2" or nil,
	fullscreen = true,
	-- The Source engine likes to crash when the compositor reports a fullscreen change
	-- (SDL then resets the video mode). Toggle fullscreen only inside Hyprland.
	sync_fullscreen = false,
	-- Do not tile outside fullscreen: a smaller window size makes the Vulkan
	-- swapchain hang (game freezes). Floating at monitor size keeps everything the same.
	float = true,
	size = "monitor_w monitor_h",
	move = "0 0",
})

-- hyprlauncher: the semi-transparent background (hyprtoolkit.conf) gets blur,
-- the rest of the screen is dimmed slightly.
hl.layer_rule({
	name = "hyprlauncher",
	match = { namespace = "^hyprlauncher$" },

	blur = true,
	ignore_alpha = 0.3,
	dim_around = true,
})

-- Screensaver (bin/screensaver): fullscreen, no animation, no dimming
hl.window_rule({
	name = "screensaver",
	match = { class = "^screensaver$" },

	fullscreen = true,
	no_anim = true,
	no_dim = true,
})
