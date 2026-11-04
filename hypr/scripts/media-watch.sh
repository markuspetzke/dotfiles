#!/usr/bin/env bash
# Beobachtet die Medienwiedergabe ueber playerctl (ereignisbasiert, kein Polling):
#  1. Solange ein Player "Playing" meldet, haelt es eine Idle-Sperre (systemd-inhibit --what=idle).
#     hypridle loest dann keine Stufe aus (Schoner, Sperre, Monitore aus, Suspend), und nach dem
#     Ende der Wiedergabe beginnt die Kette von vorn. Eine Bedingung im on-timeout ("nur wenn
#     nichts laeuft") reicht dafuer nicht: hypridle fuehrt jede Stufe nur einmal pro Leerlauf aus,
#     eine waehrend der Wiedergabe faellige Stufe fiele bis zur naechsten Eingabe ganz aus.
#  2. Bei jedem Wechsel (Play/Pause/Titel) startet es bin/video-tags, wenn das Theme inaktive
#     Fenster abdunkelt: Fenster mit laufendem Video bleiben hell.
# Laeuft als media-watch.service (hypr-session.target).
set -u

inhibit_pid=""

release() {
	if [[ -n $inhibit_pid ]]; then
		kill "$inhibit_pid" 2>/dev/null
		inhibit_pid=""
	fi
}
trap release EXIT
trap 'exit 0' TERM INT

update() {
	if playerctl -a status 2>/dev/null | grep -qx Playing; then
		if [[ -z $inhibit_pid ]] || ! kill -0 "$inhibit_pid" 2>/dev/null; then
			systemd-inhibit --what=idle --who=media-watch --why="Audio/Video laeuft" sleep infinity &
			inhibit_pid=$!
		fi
	else
		release
	fi
	if hyprctl -j getoption decoration:dim_inactive 2>/dev/null | grep -q '"bool": true'; then
		"$HOME/.config/bin/video-tags"
	fi
}

update
# Eine Zeile je Aenderung von Status oder Titel eines beliebigen Players
while read -r _; do
	update
done < <(playerctl -a -F metadata --format '{{playerName}} {{status}} {{title}}' 2>/dev/null)
# playerctl hat sich beendet: systemd startet den Dienst neu
exit 1
