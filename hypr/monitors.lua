local host = require("./host.lua")
local M = {}

if host.is_desktop then
	-- # Main Monitor
	hl.monitor({ output = "DP-2", mode = "1920x1080@160", position = "1920x0", scale = 1 })
	-- # second Monitor
	hl.monitor({ output = "DP-3", mode = "1920x1080@144", position = "0x0", scale = 1 })

	hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
	hl.workspace_rule({ workspace = "2", monitor = "DP-3", default = true })
	hl.workspace_rule({ workspace = "3", monitor = "DP-2" })
	hl.workspace_rule({ workspace = "4", monitor = "DP-2" })

	-- Tablet device block
	hl.device({
		name = "wacom-one-by-wacom-m-pen",
		output = "DP-2",
	})
else
	-- Profil bleibt bei Config-Reloads erhalten; neuer Login startet erweitert.
	-- Der Zustand soll einen Hyprland-Neustart ueberleben, aber pro Benutzer
	-- bleiben. Im Config-Verzeichnis existiert der Elternordner garantiert.
	local config_root = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or ".") .. "/.config")
	local state = config_root .. "/hypr/.monitor-profile"
	local profiles = { mobile = true, extended = true, presentation = true }
	local function external_connected()
		for _, monitor in ipairs(hl.get_monitors()) do
			if monitor.name ~= "eDP-1" and not monitor.disabled then
				return true
			end
		end
		return false
	end
	function M.apply(profile, quiet)
		assert(profiles[profile], "Unknown monitor profile: " .. tostring(profile))
		-- Interner Bildschirm bleibt in allen Profilen aktiv.
		hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1, disabled = false, mirror = "" })
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
			hl.exec_cmd("notify-send 'Monitorprofil' '" .. profile .. "'")
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
	-- Hardwarezustand gewinnt beim Start: extern angeschlossen = erweitert,
	-- sonst mobil. Die manuellen F1/F2/F3-Profile bleiben als Override verfuegbar.
	local ok, connected = pcall(external_connected)
	if ok then
		profile = connected and "extended" or "mobile"
	end
	M.apply(profile, true)

	-- Hotplug: externe Monitore automatisch aktivieren/deaktivieren.
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
end

return M
