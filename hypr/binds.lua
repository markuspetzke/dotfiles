-- Variablen definieren
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "thunar"
local menu = "hyprlauncher"
local host = require("./host.lua")

-- Applications & Windows
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("loginctl lock-session"))
-- QMK Grave-Escape kann mit SUPER den Grave-Keycode statt Escape senden.
-- Nur auf der Neo65 abfangen, damit andere Tastaturen ihre Belegung behalten.
hl.bind(mainMod .. " + code:49", hl.dsp.exec_cmd("loginctl lock-session"), {
	device = { inclusive = true, list = { "rdmctmzt-neo65-core-plus" } },
})
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(menu), { release = true })

-- Screenshot: SUPER+SHIFT+S = Bereich in Zwischenablage, Print = Bereich als Datei + Zwischenablage
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('bash "$HOME/.config/hypr/scripts/screenshot.sh" clipboard'))
hl.bind("Print", hl.dsp.exec_cmd('bash "$HOME/.config/hypr/scripts/screenshot.sh" file'))

-- Fokus / Fenster verschieben / Groesse (Pfeiltasten und HJKL)
local directions = {
	{ "left", "h", -50, 0 },
	{ "right", "l", 50, 0 },
	{ "up", "k", 0, -50 },
	{ "down", "j", 0, 50 },
}

for _, d in ipairs(directions) do
	local arrow, vimkey, dx, dy = d[1], d[2], d[3], d[4]
	for _, key in ipairs({ arrow, vimkey }) do
		hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = arrow }))
		hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = arrow }))
		-- relative = true, sonst wird der Wert als absolute Groesse gelesen
		hl.bind(
			mainMod .. " + CTRL + " .. key,
			hl.dsp.window.resize({ x = dx, y = dy, relative = true }),
			{ repeating = true }
		)
	end
end

-- Workspaces (1-10)
for i = 1, 10 do
	local key = i % 10 -- 10 entspricht Taste 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Master-Layout
hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.layout("focusmaster"))
hl.bind(mainMod .. " + O", hl.dsp.layout("orientationcycle left top"))
hl.bind(mainMod .. " + CTRL + comma", hl.dsp.layout("mfact exact 0.55"))
hl.bind(mainMod .. " + CTRL + period", hl.dsp.layout("mfact exact 0.70"))

-- Laptop-Profile: mobil, erweitert, Praesentation.
if host.is_laptop then
	local monitors = require("./monitors.lua")
	hl.bind(mainMod .. " + CTRL + F1", function()
		monitors.apply("mobile")
	end)
	hl.bind(mainMod .. " + CTRL + F2", function()
		monitors.apply("extended")
	end)
	hl.bind(mainMod .. " + CTRL + F3", function()
		monitors.apply("presentation")
	end)
end

-- Scratchpad (Special Workspace)
hl.bind(mainMod .. " + minus", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:magic" }))

-- Notifications (dunst)
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("dunstctl close-all"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("dunstctl history-pop"))

-- Clipboard-History (cliphist, Auswahl ueber hyprlauncher im dmenu-Modus)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd('bash "$HOME/.config/hypr/scripts/clipboard.sh"'))

-- Workspaces mit Mausrad durchschalten
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Pin (Fenster auf allen Workspaces sichtbar)
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin())

-- Media Controls
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Laptop: Helligkeit
if host.is_laptop then
	hl.bind(
		"XF86MonBrightnessUp",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
		{ locked = true, repeating = true }
	)
	hl.bind(
		"XF86MonBrightnessDown",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
		{ locked = true, repeating = true }
	)
end
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)

-- Mouse Binds (drag und resize)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
