#!/usr/bin/env bash
# Zeigt, wie oft jeder Hyprland-Keybind benutzt wurde (seltenste zuerst).
# Daten: bind-usage.lua schreibt nach ~/.local/state/hypr/.
state="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
log="$state/bind-usage.log"
reg="$state/bind-registry.txt"
[ -f "$reg" ] || { echo "Noch keine Daten ($reg fehlt)."; exit 1; }

since=$(head -1 "$log" 2>/dev/null | cut -f1)
echo "Gezaehlt seit: ${since:-noch nichts}"
echo
awk -F'\t' '
	NR == FNR { used[$2]++; next }
	!seen[$0]++ { printf "%6d  %s\n", used[$0], $0 }
' "$log" "$reg" 2>/dev/null | sort -n
