#!/usr/bin/env bash
# Sleep after idle on the laptop (hypridle-laptop.conf): suspend-then-hibernate
# if hibernation is set up (logind reports "yes": enough swap, resume configured),
# otherwise plain suspend. When to switch from suspend to hibernate is set by
# HibernateDelaySec in /etc/systemd/sleep.conf (unset: when the battery reaches about 5 %).
set -u
can=$(busctl call org.freedesktop.login1 /org/freedesktop/login1 \
	org.freedesktop.login1.Manager CanSuspendThenHibernate 2>/dev/null)
if [[ $can == 's "yes"' ]]; then
	exec systemctl suspend-then-hibernate
fi
exec systemctl suspend
