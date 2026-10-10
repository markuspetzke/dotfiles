-- Zaehlt, wie oft jeder Keybind benutzt wird, um ungenutzte Binds zu finden.
-- Muss vor binds.lua geladen werden: ersetzt hl.bind durch eine Version, die jeden
-- Tastendruck nach ~/.local/state/hypr/bind-usage.log schreibt (Datum<TAB>Tasten).
-- Alle registrierten Binds landen in bind-registry.txt (wird bei jedem Reload neu
-- geschrieben). Auswertung: scripts/bind-usage.sh
local state = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
os.execute("mkdir -p '" .. state .. "'")
local log_path = state .. "/bind-usage.log"
local registry = io.open(state .. "/bind-registry.txt", "w")

local orig_bind = hl.bind

hl.bind = function(keys, dispatcher, opts)
	-- Maus-Binds (Fenster ziehen/skalieren) brauchen den echten Dispatcher, nicht wrappen
	if opts and opts.mouse then
		return orig_bind(keys, dispatcher, opts)
	end
	if registry then
		registry:write(keys, "\n")
		registry:flush()
	end
	return orig_bind(keys, function(...)
		local f = io.open(log_path, "a")
		if f then
			f:write(os.date("%F"), "\t", keys, "\n")
			f:close()
		end
		if type(dispatcher) == "function" then
			return dispatcher(...)
		end
		return hl.dispatch(dispatcher)
	end, opts)
end
