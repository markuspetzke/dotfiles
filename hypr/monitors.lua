local host = require("./host.lua")
local M = {}

if host.is_desktop then
	-- # Main Monitor
	-- VRAM bleibt mit zwei Monitoren auf 875 MHz (~35 W Leerlauf), auch wenn beide auf
	-- 144 Hz laufen (getestet 2026-10-02) -- runterstellen spart also nichts.
	hl.monitor({ output = "DP-2", mode = "1920x1080@165", position = "1920x0", scale = 1 })
	-- # second Monitor
	hl.monitor({ output = "DP-3", mode = "1920x1080@144", position = "0x0", scale = 1 })

	hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
	hl.workspace_rule({ workspace = "2", monitor = "DP-3", default = true })
	hl.workspace_rule({ workspace = "3", monitor = "DP-2" })
	hl.workspace_rule({ workspace = "4", monitor = "DP-2" })

	-- Rival 3: ohne Beschleunigung (1 cm Mausweg = immer gleiche Strecke).
	-- DPI/Polling stehen in der Maus selbst (rivalcfg).
	hl.device({
		name = "steelseries-steelseries-rival-3",
		accel_profile = "flat",
		-- Nur Desktop-Zeiger: bei "flat" = Faktor 1 + sensitivity (hier 1,5x).
		-- Spiele mit Raw-Input bekommen die unbeschleunigten Werte.
		sensitivity = 0.5,
	})

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
	-- Externer Monitor eingeschaltet
	local function external_connected()
		for _, monitor in ipairs(hl.get_monitors()) do
			if monitor.name ~= "eDP-1" and not monitor.disabled then
				return true
			end
		end
		return false
	end
	-- Externer Monitor angeschlossen, auch wenn gerade abgeschaltet (Profil "mobile")
	local function external_present()
		for _, monitor in ipairs(hl.get_monitors({ all = true })) do
			if monitor.name ~= "eDP-1" then
				return true
			end
		end
		return false
	end

	-- Deckel zu? Beim Laden aus /proc gelesen, danach halten die Schalter-Binds unten den Wert aktuell.
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
		-- Interner Bildschirm: an, ausser zugeklappt im Dock (sonst landen Maus, Fenster und
		-- Workspaces auf dem unsichtbaren Display). "presentation" spiegelt eDP-1 und braucht ihn.
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

	-- Deckel ("Lid Switch", siehe hyprctl devices). Ob der Laptop schlaeft oder nur sperrt,
	-- entscheidet logind (hypr/logind/laptop.conf); hier geht es nur um die Bildschirme.
	-- Zu im Dock: eDP-1 aus. Zu ohne externen Monitor: nur das Panel aus (am Netzteil sperrt
	-- logind bloss). Auf: Profil neu anwenden, Panel an.
	local function on_lid(closed)
		_G.hypr_lid_closed = closed
		-- DPMS nicht direkt im Bind schalten (Hyprland-Wiki), daher kurz verzoegert
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
