#!/usr/bin/env bash
# Exit 0, wenn nichts den Ruhezustand blockiert. hypridle fragt das vor dem Suspend ab
# (condition_cmd): Haelt ein Programm eine Sperre "sleep" (z. B. backup-hetzner.service ueber
# systemd-inhibit), bleibt der Rechner wach. Sperre und Monitor-Aus laufen trotzdem.
set -u
# Ausgabe z. B.: s "sleep:idle". Ist logind nicht erreichbar, nicht blockieren.
blocked=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
	org.freedesktop.login1.Manager BlockInhibited 2>/dev/null) || exit 0
blocked=${blocked#s }
blocked=${blocked//\"/}
[[ ":$blocked:" != *:sleep:* ]]
