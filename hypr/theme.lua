-- Loads the active theme (~/.config/theme-current -> themes/<name>, set with `theme <name>`)
-- and sets border/group colors plus theme specifics (border width, dimming,
-- rotating gradient border, screen shader). Without the symlink, themes/retro applies.
local home = os.getenv("HOME") or ""
local current = home .. "/.config/theme-current"

local function load_theme(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local src = f:read("a")
	f:close()
	local chunk = load(src, "@" .. path)
	return chunk and chunk() or nil
end

local function exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local t = load_theme(current .. "/palette.lua") or load_theme(home .. "/.config/themes/retro/palette.lua")
-- Laptop: effects that redraw constantly (shader, rotating border) are off by default (battery)
local host = require("./host.lua")
local c = t.colors
local opt = t.hypr or {}

-- "#rrggbb" + Alpha (0-255) -> "rgba(rrggbbaa)"
local function rgba(hex, alpha)
	return string.format("rgba(%s%02x)", hex:sub(2), alpha or 0xff)
end

-- Active border: an accent color or a gradient (border_gradient), optionally rotating.
local active_border = rgba(c.accent)
if opt.border_gradient then
	local cols = {}
	for i, hex in ipairs(opt.border_gradient) do
		cols[i] = rgba(hex)
	end
	active_border = { colors = cols, angle = 45 }
end

hl.config({
	general = {
		border_size = opt.border_size or 2,
		col = {
			active_border = active_border,
			inactive_border = rgba(c.surface2),
		},
	},
	decoration = {
		dim_inactive = opt.dim_inactive or false,
		dim_strength = opt.dim_strength or 0.25,
	},
	group = {
		col = {
			border_active = active_border,
			border_inactive = rgba(c.surface2),
		},
		groupbar = {
			col = {
				active = rgba(c.accent),
				inactive = rgba(c.surface),
			},
			text_color = c.bg,
			font_family = "DepartureMono Nerd Font",
		},
	},
})

-- Set the theme's cursor at startup (bin/theme --session)
hl.on("hyprland.start", function()
	hl.exec_cmd(home .. "/.config/bin/theme --session")
end)

-- Free-form theme overrides (e.g. rounding, blur, gaps, animations, rules)
if opt.config then
	hl.config(opt.config)
end
for _, a in ipairs(opt.animations or {}) do
	hl.animation(a)
end
for _, r in ipairs(opt.window_rules or {}) do
	hl.window_rule(r)
end

-- smart_gaps = false: a single window also keeps gaps, border and rounding
-- (overrides the smart gaps rules from hypr/hyprland.lua, same names)
if opt.smart_gaps == false then
	local cfg = opt.config or {}
	local gi = (cfg.general or {}).gaps_in or 5
	local go = (cfg.general or {}).gaps_out or 10
	local rnd = (cfg.decoration or {}).rounding or 0
	for _, ws in ipairs({ "w[tv1]", "f[1]" }) do
		hl.workspace_rule({ workspace = ws, gaps_out = go, gaps_in = gi })
	end
	for _, name in ipairs({ "no-gaps-wtv1", "no-gaps-f1" }) do
		hl.window_rule({
			name = name,
			match = { float = false, workspace = name == "no-gaps-wtv1" and "w[tv1]" or "f[1]" },
			border_size = opt.border_size or 2,
			rounding = rnd,
		})
	end
end

-- Dimming of inactive windows (dim_inactive): windows with playing video stay bright.
-- Detection (bin/video-tags): a playing medium whose title is in the window title (YouTube etc.),
-- or the window inhibits the screen lock / is a video player -> tag "video".
if opt.dim_inactive then
	hl.window_rule({ name = "no-dim-video", match = { tag = "video" }, no_dim = true })

	-- Detection runs in the background (bin/video-tags) so the compositor never waits for playerctl.
	-- No polling: player changes (play/pause/title) come from media-watch.service, window
	-- changes from here. Several events within 300 ms trigger only one run.
	local script = home .. "/.config/bin/video-tags"
	_G.theme_video_gen = (_G.theme_video_gen or 0) + 1
	local vgen = _G.theme_video_gen
	local pending = false
	local function update_video_tags()
		if vgen ~= _G.theme_video_gen or pending then
			return -- handler of an earlier config load, or a run is already scheduled
		end
		pending = true
		hl.timer(function()
			pending = false
			hl.exec_cmd(script)
		end, { timeout = 300, type = "oneshot" })
	end
	hl.on("window.open", update_video_tags)
	hl.on("window.active", update_video_tags)
	hl.on("window.title", update_video_tags)
	update_video_tags() -- state after a config reload or theme switch
end

if opt.border_loop and not host.is_laptop then
	-- The gradient slowly travels around the active window (like a data stream)
	hl.animation({ leaf = "borderangle", enabled = true, speed = 60, bezier = "linear", style = "loop" })
end

------------------------------------------------------------------------
-- Screen shader (themes/<name>/shader.frag)
-- Super+Shift+G toggles it; it is off automatically in fullscreen games.
------------------------------------------------------------------------
local M = { colors = c }
-- Real path instead of the symlink, so Hyprland recompiles on a theme switch
local p = io.popen('readlink -f "' .. current .. '" 2>/dev/null')
local real = p and (p:read("*l") or "") or ""
if p then
	p:close()
end
local shader = (real ~= "" and real or current) .. "/shader.frag"
M.has_shader = exists(shader)

-- The state survives config reloads (global variable in the Lua state). On the laptop
-- the shader starts off (battery); Super+Shift+G turns it on when needed.
if _G.theme_shader_enabled == nil then
	_G.theme_shader_enabled = not host.is_laptop
end

local function is_game(w)
	if not w then
		return false
	end
	local cls = w.class or ""
	return w.content_type == "game"
		or cls:match("^steam_app_") ~= nil
		or cls == "tf_linux64"
		or cls == "gamescope"
end

local function game_fullscreen()
	for _, m in ipairs(hl.get_monitors() or {}) do
		local ws = m.active_workspace
		if ws and ws.has_fullscreen and is_game(ws.fullscreen_window) then
			return true
		end
	end
	return false
end

local applied = nil
function M.apply_shader()
	local want = M.has_shader and _G.theme_shader_enabled and not game_fullscreen()
	local value = want and shader or ""
	if value ~= applied then
		hl.config({ decoration = { screen_shader = value } })
		applied = value
	end
end

function M.toggle_shader()
	if not M.has_shader then
		hl.exec_cmd('notify-send -t 1500 "Shader" "This theme has no shader"')
		return
	end
	_G.theme_shader_enabled = not _G.theme_shader_enabled
	applied = nil
	M.apply_shader()
	hl.exec_cmd(
		'notify-send -t 1500 "Shader" "' .. (_G.theme_shader_enabled and "on" or "off") .. '"'
	)
end

M.apply_shader()
if M.has_shader then
	-- Handlers of earlier config loads become no-ops (generation counter)
	_G.theme_gen = (_G.theme_gen or 0) + 1
	local gen = _G.theme_gen
	local function on_change()
		if gen == _G.theme_gen then
			M.apply_shader()
		end
	end
	hl.on("window.fullscreen", on_change)
	hl.on("workspace.active", on_change)
	hl.on("window.close", on_change)
end

return M
