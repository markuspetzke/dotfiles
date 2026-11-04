local host = require("./host.lua")
local M = {}

if host.is_desktop then
	-- # Main Monitor
	-- VRAM stays at 875 MHz with two monitors (~35 W idle), even when both run at
	-- 144 Hz (tested 2026-10-02) -- lowering the refresh rate saves nothing.
	hl.monitor({ output = "DP-2", mode = "1920x1080@165", position = "1920x0", scale = 1 })
	-- # second Monitor
	hl.monitor({ output = "DP-3", mode = "1920x1080@144", position = "0x0", scale = 1 })

	hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
	hl.workspace_rule({ workspace = "2", monitor = "DP-3", default = true })
	hl.workspace_rule({ workspace = "3", monitor = "DP-2" })
	hl.workspace_rule({ workspace = "4", monitor = "DP-2" })

	-- Rival 3: no acceleration (1 cm of mouse travel = always the same distance).
	-- DPI/polling are stored in the mouse itself (rivalcfg).
	hl.device({
		name = "steelseries-steelseries-rival-3",
		accel_profile = "flat",
		-- Desktop pointer only: with "flat" = factor 1 + sensitivity (here 1.5x).
		-- Games with raw input get the unaccelerated values.
		sensitivity = 0.5,
	})

	-- Tablet device block
	hl.device({
		name = "wacom-one-by-wacom-m-pen",
		output = "DP-2",
	})
else
	-- The profile survives config reloads; a new login starts extended.
	-- The state should survive a Hyprland restart but stay per user.
	-- The parent folder is guaranteed to exist in the config directory.
	local config_root = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or ".") .. "/.config")
	local state = config_root .. "/hypr/.monitor-profile"
	local profiles = { mobile = true, extended = true, presentation = true }
	-- External monitor enabled
	local function external_connected()
		for _, monitor in ipairs(hl.get_monitors()) do
			if monitor.name ~= "eDP-1" and not monitor.disabled then
				return true
			end
		end
		return false
	end
	-- External monitor connected, even if currently disabled (profile "mobile")
	local function external_present()
		for _, monitor in ipairs(hl.get_monitors({ all = true })) do
			if monitor.name ~= "eDP-1" then
				return true
			end
		end
		return false
	end

	-- Lid closed? Read from /proc at load time; afterwards the switch binds below keep it current.
	local function read_lid_closed()
		local p = io.popen("cat /proc/acpi/button/lid/*/state 2>/dev/null")
		if not p then
			return false
		end
		local s = p:read("a") or ""
		p:close()
		return s:match("closed") ~= nil
	end
	_G.hypr_lid_closed = read_lid_closed()

	function M.apply(profile, quiet)
		assert(profiles[profile], "Unknown monitor profile: " .. tostring(profile))
		M.current = profile
		-- Internal display: on, except with the lid closed while docked (otherwise mouse, windows and
		-- workspaces end up on the invisible display). "presentation" mirrors eDP-1 and needs it.
		local internal_off = _G.hypr_lid_closed and profile == "extended" and external_present()
		hl.monitor({
			output = "eDP-1",
			mode = "preferred",
			position = "0x0",
			scale = 1,
			disabled = internal_off,
			mirror = "",
		})
		hl.monitor({
			output = "",
			mode = "preferred",
			position = "auto-right",
			scale = 1,
			disabled = profile == "mobile",
			mirror = profile == "presentation" and "eDP-1" or "",
		})
		if state then
			local f = io.open(state, "w")
			if f then
				f:write(profile)
				f:close()
			end
		end
		if not quiet then
			hl.exec_cmd("notify-send 'Monitor profile' '" .. profile .. "'")
		end
	end
	local profile = "extended"
	local f = io.open(state, "r")
	if f then
		local saved = f:read("*a")
		f:close()
		if profiles[saved] then
			profile = saved
		end
	end
	-- The hardware state wins at startup: external monitor connected = extended,
	-- otherwise mobile. The manual F1/F2/F3 profiles remain available as an override.
	local ok, connected = pcall(external_connected)
	if ok then
		profile = connected and "extended" or "mobile"
	end
	M.apply(profile, true)

	-- Hotplug: enable/disable external monitors automatically.
	hl.on("monitor.added", function(monitor)
		if monitor and monitor.name ~= "eDP-1" then
			M.apply("extended")
		end
	end)
	hl.on("monitor.removed", function(monitor)
		if monitor and monitor.name ~= "eDP-1" then
			M.apply("mobile")
		end
	end)

	-- Lid ("Lid Switch", see hyprctl devices). Whether the laptop sleeps or only locks is
	-- decided by logind (hypr/logind/laptop.conf); this is only about the displays.
	-- Closed while docked: eDP-1 off. Closed without an external monitor: only the panel off
	-- (on AC power logind only locks). Open: re-apply the profile, panel on.
	local function on_lid(closed)
		_G.hypr_lid_closed = closed
		-- Do not toggle DPMS directly in the bind (Hyprland wiki), hence the short delay
		hl.timer(function()
			if closed and not external_connected() then
				hl.dispatch(hl.dsp.dpms({ monitor = "eDP-1", action = "off" }))
				return
			end
			M.apply(M.current or "extended", true)
			if not closed then
				hl.dispatch(hl.dsp.dpms({ monitor = "eDP-1", action = "on" }))
			end
		end, { timeout = 500, type = "oneshot" })
	end
	hl.bind("switch:on:Lid Switch", function()
		on_lid(true)
	end, { locked = true })
	hl.bind("switch:off:Lid Switch", function()
		on_lid(false)
	end, { locked = true })
end

return M
