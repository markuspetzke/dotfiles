-- The hardware profile comes from scripts/hypr-profile.sh so Hyprland, hypridle and
-- waybar use the same detection (HYPR_PROFILE > system battery, otherwise desktop).
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
-- Script missing or returns nonsense: desktop is the safe default (no laptop monitor logic).
if M.profile ~= "desktop" and M.profile ~= "laptop" then
	M.profile = "desktop"
end

M.is_laptop = M.profile == "laptop"
M.is_desktop = M.profile == "desktop"

return M
