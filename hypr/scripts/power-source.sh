#!/usr/bin/env bash
# Stromquelle des Rechners.
#   power-source.sh           # gibt "ac" oder "battery" aus
#   power-source.sh ac        # Exit 0 am Netzteil (auch ohne Systemakku, also am Desktop)
#   power-source.sh battery   # Exit 0 auf Akku
# Netzteil = Quelle vom Typ Mains oder USB (Laden ueber USB-C) mit online=1. Maus- und
# Headset-Akkus (scope=Device) zaehlen nicht. Genutzt von hypridle-laptop.conf und
# run-power-profile.sh.
set -u
dir=${POWER_SUPPLY_DIR:-/sys/class/power_supply} # zum Testen ueberschreibbar

battery=false
online=false
for s in "$dir"/*; do
	[[ -r $s/type ]] || continue
	[[ -r $s/scope && $(<"$s/scope") == Device ]] && continue
	case $(<"$s/type") in
	Battery) battery=true ;;
	Mains | USB*) [[ -r $s/online && $(<"$s/online") == 1 ]] && online=true ;;
	esac
done
source=ac
if $battery && ! $online; then
	source=battery
fi

case ${1:-} in
"") printf '%s\n' "$source" ;;
ac | battery) [[ $source == "$1" ]] ;;
*)
	echo "Aufruf: $0 [ac|battery]" >&2
	exit 2
	;;
esac
