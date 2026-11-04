#!/usr/bin/env bash
# Exit 0 if nothing blocks sleep. hypridle asks this before suspending
# (condition_cmd): if a program holds a "sleep" inhibitor (e.g. backup-hetzner.service through
# systemd-inhibit), the machine stays awake. Locking and turning the monitors off still happen.
set -u
# Output e.g.: s "sleep:idle". If logind is unreachable, do not block.
blocked=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
	org.freedesktop.login1.Manager BlockInhibited 2>/dev/null) || exit 0
blocked=${blocked#s }
blocked=${blocked//\"/}
[[ ":$blocked:" != *:sleep:* ]]
