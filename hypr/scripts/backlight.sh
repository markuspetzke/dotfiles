#!/usr/bin/env bash
# Laptop idle (hypridle-laptop.conf): dim the screen to 10 % and turn the keyboard
# backlight off; restore the previous values on activity.
#   backlight.sh dim | restore
# brightnessctl saves the value (-s) and restores it (-r). The marker file makes sure
# "restore" only resets what "dim" actually changed (otherwise an old value would come back).
set -u
command -v brightnessctl >/dev/null || exit 0
mark=${XDG_RUNTIME_DIR:-/tmp}/hypr-backlight-dimmed
kbd='*::kbd_backlight'

case ${1:-} in
dim)
	[[ -e $mark ]] && exit 0
	: >"$mark"
	# Only dim, never brighten: below 10 % the brightness stays as it is
	cur=$(brightnessctl -m -c backlight 2>/dev/null | cut -d, -f4 | tr -d %)
	if [[ $cur =~ ^[0-9]+$ ]] && ((cur > 10)); then
		brightnessctl -q -s -c backlight set 10% && echo screen >>"$mark"
	fi
	if brightnessctl -q -s -d "$kbd" set 0 2>/dev/null; then
		echo kbd >>"$mark"
	fi
	;;
restore)
	[[ -e $mark ]] || exit 0
	grep -qx screen "$mark" && brightnessctl -q -r -c backlight
	grep -qx kbd "$mark" && brightnessctl -q -r -d "$kbd" 2>/dev/null
	rm -f "$mark"
	;;
*)
	echo "Usage: $0 dim|restore" >&2
	exit 2
	;;
esac
exit 0
