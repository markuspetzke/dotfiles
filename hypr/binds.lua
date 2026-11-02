-- Variablen definieren
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "thunar"
local menu = "hyprlauncher"
local host = require("./host.lua")

-- Applications & Windows
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
-- Das OBS-Hauptfenster nie per SUPER+W schliessen (Stream/Aufnahme koennte laufen);
-- OBS-Dialoge (Einstellungen, Eigenschaften) schliessen weiter normal.
hl.bind(mainMod .. " + W", function()
	local w = hl.get_active_window()
	if w and w.class == "com.obsproject.Studio" and w.title:match("^OBS %d") then
		hl.exec_cmd('notify-send -t 2500 "OBS" "SUPER+W ist für OBS gesperrt – über Datei → Beenden schließen"')
		return
	end
	hl.dispatch(hl.dsp.window.close())
end)
-- Vollbild nur in Hyprland (internal 2), dem Programm wird nichts gemeldet (client 0):
-- Browser behalten Tab- und Adressleiste. Video-Vollbild (z.B. YouTube "f") fordert das
-- Programm selbst an und funktioniert unabhaengig davon.
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))
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

-- Screenshot: Bereich in Zwischenablage
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('bash "$HOME/.config/hypr/scripts/screenshot.sh" clipboard'))

-- Fokus / Fenster verschieben / Groesse (HJKL)
local directions = {
	{ "left", "h", -50, 0 },
	{ "right", "l", 50, 0 },
	{ "up", "k", 0, -50 },
	{ "down", "j", 0, 50 },
}

for _, d in ipairs(directions) do
	local dir, key, dx, dy = d[1], d[2], d[3], d[4]
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
	-- relative = true, sonst wird der Wert als absolute Groesse gelesen
	hl.bind(
		mainMod .. " + CTRL + " .. key,
		hl.dsp.window.resize({ x = dx, y = dy, relative = true }),
		{ repeating = true }
	)
end

-- Workspaces (1-4; 5-10 wurden nie benutzt)
for i = 1, 4 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Master-Layout
hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster"))

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

-- Notifications (dunst)
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("dunstctl close-all"))

-- Clipboard-History (cliphist, Auswahl ueber hyprlauncher im dmenu-Modus)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd('bash "$HOME/.config/hypr/scripts/clipboard.sh"'))

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

-- Stream (nur Desktop): OBS-Hotkeys greifen unter Wayland nur mit Fokus auf OBS,
-- daher ueber Hyprland. Skripte liegen in ~/.config/bin (nach ~/.local/bin verlinkt).
if host.is_desktop then
	hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("stream-tode +"))
	hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("stream-tode -"))
	hl.bind(mainMod .. " + CTRL + X", hl.dsp.exec_cmd("stream-tode 0"))
	hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("stream-clip"))
end
