-- Variables
local mainMod = "SUPER"
-- uwsm-app: every program becomes its own systemd unit (like the launcher and Waybar) instead
-- of running inside Hyprland's service. uwsm's fast client (~10 ms instead of ~90 ms for "uwsm app").
local terminal = "uwsm-app -- kitty"
local fileManager = "uwsm-app -- thunar"
-- The theme's start menu (bin/menu: e.g. the XP start menu), hyprlauncher otherwise
local menu = os.getenv("HOME") .. "/.config/bin/menu"
local host = require("./host.lua")

-- Applications & Windows
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
-- Never close the OBS main window with SUPER+W (a stream/recording might be running);
-- OBS dialogs (settings, properties) still close normally.
hl.bind(mainMod .. " + W", function()
	local w = hl.get_active_window()
	if w and w.class == "com.obsproject.Studio" and w.title:match("^OBS %d") then
		hl.exec_cmd('notify-send -t 2500 "OBS" "SUPER+W is blocked for OBS – close it via File → Exit"')
		return
	end
	hl.dispatch(hl.dsp.window.close())
end)
-- Fullscreen only inside Hyprland (internal 2), nothing is reported to the program (client 0):
-- browsers keep their tab and address bar. Video fullscreen (e.g. YouTube "f") is requested
-- by the program itself and works independently of this.
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
-- Toggle the theme's screen shader (themes/<name>/shader.frag)
hl.bind(mainMod .. " + SHIFT + G", function()
	require("./theme.lua").toggle_shader()
end)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("loginctl lock-session"))
-- With SUPER held, QMK Grave-Escape can send the grave keycode instead of Escape.
-- Only catch it on the Neo65 so other keyboards keep their layout.
hl.bind(mainMod .. " + code:49", hl.dsp.exec_cmd("loginctl lock-session"), {
	device = { inclusive = true, list = { "rdmctmzt-neo65-core-plus" } },
})
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(menu), { release = true })

-- Screenshot: area to clipboard
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('bash "$HOME/.config/hypr/scripts/screenshot.sh" clipboard'))

-- Focus / move window / resize (HJKL)
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
	-- relative = true, otherwise the value is read as an absolute size
	hl.bind(
		mainMod .. " + CTRL + " .. key,
		hl.dsp.window.resize({ x = dx, y = dy, relative = true }),
		{ repeating = true }
	)
end

-- Workspaces (1-4; 5-10 were never used)
for i = 1, 4 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Master layout
hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster"))

-- Laptop profiles: mobile, extended, presentation.
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

-- Clipboard history (cliphist, picked with hyprlauncher in dmenu mode)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd('bash "$HOME/.config/hypr/scripts/clipboard.sh"'))

-- Media Controls
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Laptop: brightness
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

-- Mouse binds (drag and resize)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Stream (desktop only): OBS hotkeys only work with OBS focused under Wayland,
-- so they go through Hyprland. Scripts live in ~/.config/bin (linked into ~/.local/bin).
if host.is_desktop then
	hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("stream-deaths +"))
	hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("stream-deaths -"))
	hl.bind(mainMod .. " + CTRL + X", hl.dsp.exec_cmd("stream-deaths 0"))
	hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("stream-clip"))
end
