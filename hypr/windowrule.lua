local host = require("./host.lua")

hl.window_rule({
	name = "Picture-in-Picture",
	match = { title = "Picture-in-Picture" },

	float = true,
	pin = true, -- bleibt beim Workspace-Wechsel sichtbar
	size = "25% 25%",
	move = "monitor_w-100%-20 monitor_h-100%-20", -- unten rechts
})

-- Dialoge (Datei oeffnen/speichern, Polkit-Prompts) schweben zentriert.
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

	-- Immer auf dem 165-Hz-Hauptmonitor (sonst landet TF2 auf dem Monitor mit der Maus,
	-- z. B. links, wenn Steam dort offen ist). Nur Desktop, der Laptop hat kein DP-2.
	monitor = host.is_desktop and "DP-2" or nil,
	fullscreen = true,
	-- Source engine crasht gerne, wenn der Compositor ihm einen Fullscreen-Wechsel meldet
	-- (SDL macht dann einen Video-Mode-Reset). Fullscreen nur intern in Hyprland umschalten.
	sync_fullscreen = false,
	-- Ausserhalb von Fullscreen nicht kacheln: eine kleinere Fenstergroesse laesst die
	-- Vulkan-Swapchain haengen (Spiel friert ein). Schwebend in Monitorgroesse bleibt alles gleich.
	float = true,
	size = "monitor_w monitor_h",
	move = "0 0",
})

-- hyprlauncher: halbtransparenter Hintergrund (hyprtoolkit.conf) bekommt Blur,
-- der Rest des Bildschirms wird leicht abgedunkelt.
hl.layer_rule({
	name = "hyprlauncher",
	match = { namespace = "^hyprlauncher$" },

	blur = true,
	ignore_alpha = 0.3,
	dim_around = true,
})

-- Bildschirmschoner (bin/screensaver): Vollbild, ohne Animation und Abdunkeln
hl.window_rule({
	name = "screensaver",
	match = { class = "^screensaver$" },

	fullscreen = true,
	no_anim = true,
	no_dim = true,
})
