hl.window_rule({
	name = "opengl blackbox",
	match = { title = "Test Title" },

	float = true,
})

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

	fullscreen = true,
	-- Source engine crasht gerne, wenn der Compositor ihm einen Fullscreen-Wechsel meldet
	-- (SDL macht dann einen Video-Mode-Reset). Fullscreen nur intern in Hyprland umschalten.
	sync_fullscreen = false,
})
