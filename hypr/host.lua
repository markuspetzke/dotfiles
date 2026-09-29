-- Hardwareprofil kommt aus scripts/hypr-profile.sh, damit Hyprland, hypridle und
-- waybar dieselbe Erkennung nutzen (HYPR_PROFILE > Akku > Hostname).
local M = { name = "unknown", profile = nil, is_desktop = false, is_laptop = false }

local f = io.open("/etc/hostname", "r")
if f then
	M.name = (f:read("*l") or ""):gsub("%s+$", "")
	f:close()
end

local home = os.getenv("HOME") or ""
local p = io.popen('"' .. home .. '/.config/hypr/scripts/hypr-profile.sh" 2>/dev/null')
if p then
	M.profile = (p:read("*l") or ""):gsub("%s+$", "")
	p:close()
end
-- Skript fehlt oder liefert Unsinn: Desktop ist der sichere Default (keine Laptop-Monitorlogik).
if M.profile ~= "desktop" and M.profile ~= "laptop" then
	M.profile = "desktop"
end

M.is_laptop = M.profile == "laptop"
M.is_desktop = M.profile == "desktop"

return M
