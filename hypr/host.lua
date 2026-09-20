-- Hardwareprofil: HYPR_PROFILE=desktop/laptop gewinnt; danach wird ein Akku
-- erkannt. Der Hostname bleibt als Rueckwaertskompatibilitaet erhalten.
local M = { name = "unknown", profile = nil, is_desktop = false, is_laptop = false }

local f = io.open("/etc/hostname", "r")
if f then
	M.name = (f:read("*l") or ""):gsub("%s+$", "")
	f:close()
end

local override = os.getenv("HYPR_PROFILE")
if override == "desktop" or override == "laptop" then
	M.profile = override
else
	for i = 0, 9 do
		local battery = io.open("/sys/class/power_supply/BAT" .. i .. "/type", "r")
		if battery then
			M.profile = "laptop"
			battery:close()
			break
		end
	end
	M.profile = M.profile or (M.name == "GLaDOS" and "desktop" or "laptop")
end

M.is_laptop = M.profile == "laptop"
M.is_desktop = M.profile == "desktop"

return M
