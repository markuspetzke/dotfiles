#!/usr/bin/env bash
# Ruhezustand nach Leerlauf auf dem Laptop (hypridle-laptop.conf): suspend-then-hibernate,
# wenn Hibernate eingerichtet ist (logind meldet "yes": Swap gross genug, resume konfiguriert),
# sonst normaler Suspend. Wann aus dem Suspend in Hibernate gewechselt wird, regelt
# HibernateDelaySec in /etc/systemd/sleep.conf (ohne Angabe: wenn der Akku etwa 5 % erreicht).
set -u
can=$(busctl call org.freedesktop.login1 /org/freedesktop/login1 \
	org.freedesktop.login1.Manager CanSuspendThenHibernate 2>/dev/null)
if [[ $can == 's "yes"' ]]; then
	exec systemctl suspend-then-hibernate
fi
exec systemctl suspend
