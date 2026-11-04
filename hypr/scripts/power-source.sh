#!/usr/bin/env bash
# Power source of the machine.
#   power-source.sh           # prints "ac" or "battery"
#   power-source.sh ac        # exit 0 on AC power (also without a system battery, i.e. desktop)
#   power-source.sh battery   # exit 0 on battery
# AC power = a source of type Mains or USB (USB-C charging) with online=1. Mouse and
# headset batteries (scope=Device) do not count. Used by hypridle-laptop.conf and
# run-power-profile.sh.
set -u
dir=${POWER_SUPPLY_DIR:-/sys/class/power_supply} # can be overridden for testing

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
	echo "Usage: $0 [ac|battery]" >&2
	exit 2
	;;
esac
