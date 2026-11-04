#!/usr/bin/env bash
# Laptop-Leerlauf (hypridle-laptop.conf): Bildschirm auf 10 % abdunkeln und Tastatur-
# beleuchtung aus, bei Aktivitaet den vorherigen Wert wiederherstellen.
#   backlight.sh dim | restore
# brightnessctl merkt sich den Wert (-s) und stellt ihn her (-r). Die Merkdatei sorgt dafuer,
# dass "restore" nur zuruecksetzt, was "dim" auch geaendert hat (sonst kaeme ein alter Wert zurueck).
set -u
command -v brightnessctl >/dev/null || exit 0
mark=${XDG_RUNTIME_DIR:-/tmp}/hypr-backlight-dimmed
kbd='*::kbd_backlight'

case ${1:-} in
dim)
	[[ -e $mark ]] && exit 0
	: >"$mark"
	# Nur abdunkeln, nie aufhellen: unter 10 % bleibt die Helligkeit, wie sie ist
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
	echo "Aufruf: $0 dim|restore" >&2
	exit 2
	;;
esac
exit 0
