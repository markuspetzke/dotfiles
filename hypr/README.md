# Hyprland

Lua-Konfiguration fuer Hyprland 0.57, gestartet ueber uwsm. Das Profil wird ueber
`HYPR_PROFILE` (`desktop` oder `laptop`) oder die Akku-Erkennung bestimmt: ein
Systemakku ergibt `laptop`, alles andere `desktop` (`scripts/hypr-profile.sh`).

Zum expliziten Festlegen `export HYPR_PROFILE=laptop` in `~/.config/uwsm/env`
eintragen. Dort stehen auch die uebrigen Session-Variablen.

## Tastenkombinationen

| Tasten | Aktion |
| --- | --- |
| `Super+Escape` | Bildschirm sperren |
| `Super+H/J/K/L` | Fokus links/unten/oben/rechts |
| `Super+Shift+H/J/K/L` | Fenster verschieben |
| `Super+Ctrl+H/J/K/L` | Fenster groesser/kleiner machen |
| `Super+1..4` / `Super+Shift+1..4` | Workspace wechseln / Fenster dorthin schieben |
| `Super+Return` | Fenster mit Master tauschen |
| `Super+Ctrl+F1` | Laptop: nur internes Display |
| `Super+Ctrl+F2` | Laptop: externe Displays rechts erweitern |
| `Super+Ctrl+F3` | Laptop: internes Display auf externe spiegeln |
| `Super` loslassen | Launcher |
| `Super+V` | Clipboard-Verlauf |
| `Super+Shift+S` | Bereich als Screenshot in Zwischenablage |
| `Super+X` / `Shift` / `Ctrl` | Desktop: Todeszaehler +1 / -1 / 0 (Stream) |
| `Super+C` | Desktop: letzte 60 s aus dem OBS-Replay-Puffer speichern |

`Alt+Pfeiltasten` und `Alt+H/J/K/L` bleiben fuer Anwendungen frei.
Auf der Neo65 sperrt auch `Super+code:49` als Fallback fuer QMK Grave-Escape.

## Laptop-Monitore

Ein neuer Laptop-Login startet mit dem erweiterten Profil. Die Auswahl wird in
`~/.config/hypr/.monitor-profile` gespeichert und bleibt ueber Neustarts
erhalten. Sie gilt auch fuer neu angeschlossene Displays.
Das interne Display (`eDP-1`) bleibt in allen Profilen aktiv, ausser der Deckel
ist im Dock zu (siehe Zuklappen). Falls der Laptop einen anderen Anschlussnamen
verwendet, diesen in `monitors.lua` anpassen.
Die Desktop-Belegung mit DP-2/DP-3 bleibt separat konfiguriert.

### Zuklappen

Ob der Laptop schlaeft oder nur sperrt, entscheidet `systemd-logind`. Die
Drop-in-Datei liegt unter `hypr/logind/laptop.conf`. Auf dem Laptop einmal
installieren, sie wirkt nach einem Neustart (`theme-setup --check` meldet, ob sie fehlt):

```sh
sudo install -Dm644 ~/.config/hypr/logind/laptop.conf /etc/systemd/logind.conf.d/90-hypr-laptop.conf
```

| Zustand | logind | Hyprland (`monitors.lua`) |
| --- | --- | --- |
| Akku | Suspend | - |
| Netzteil | sperren | internes Panel aus |
| Dock (externer Monitor) | nichts | `eDP-1` abgeschaltet, alles auf den externen Monitoren |

Aufklappen schaltet `eDP-1` wieder an. Ist Hibernate eingerichtet, kann in der
Datei statt `suspend` auch `suspend-then-hibernate` stehen.

### Inaktivitaet

| Zeit | Desktop (`hypridle.conf`) | Laptop (`hypridle-laptop.conf`) |
| --- | --- | --- |
| 5 min | - | auf 10 % abdunkeln, Tastaturbeleuchtung aus |
| 9 min | Bildschirmschoner des Themes | Bildschirmschoner des Themes |
| 10 min | sperren | sperren |
| 10,5 min | Monitore aus | Monitore aus |
| 15 min | - | auf Akku: Ruhezustand |
| 60 min | Suspend | Ruhezustand, auch am Netzteil |

Gesperrt wird vor dem Abschalten, damit hyprlock einen echten Screenshot als
Hintergrund bekommt. Ruhezustand auf dem Laptop heisst `suspend-then-hibernate`,
wenn Hibernate eingerichtet ist, sonst Suspend (`scripts/idle-sleep.sh`).

Waehrend Audio/Video laeuft, haelt `media-watch.service` eine Idle-Sperre
(`systemd-inhibit --what=idle`). Dann loest keine Stufe aus, und nach dem Ende der
Wiedergabe beginnt die Kette von vorn. Eine Bedingung direkt im `on-timeout`
reicht dafuer nicht: hypridle fuehrt jede Stufe nur einmal pro Leerlauf aus.

Vor dem Suspend prueft hypridle mit `scripts/sleep-allowed.sh`, ob ein Programm den
Ruhezustand blockiert (z. B. `backup-hetzner.service`), und versucht es dann alle
5 Minuten erneut. Sperre und Monitor-Aus laufen trotzdem. `idle-test` spielt die
Kette mit kurzen Zeiten durch.

### Automatische Monitore und Power-Profile

Auf Laptops wird beim Start automatisch zwischen `mobile` (nur `eDP-1`) und
`extended` (externer Monitor rechts) gewaehlt. Monitor-Hotplug schaltet diese
Profile ebenfalls automatisch um; die manuellen `Super+Ctrl+F1/F2/F3`-Shortcuts
bleiben verfuegbar. `presentation` ist weiterhin ein manueller Override.

`power-profile.service` laeuft nur im Laptop-Profil und waehlt bei Netzbetrieb
`balanced` und auf Akku `power-saver`. Netzteil oder Akku erkennt
`scripts/power-source.sh` (auch Laden ueber USB-C). Dafuer muss `power-profiles-daemon` installiert sein:

```sh
sudo pacman -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

Ohne das Paket bleibt der Dienst deaktiviert und veraendert nichts.

### Dienste

Waybar, hypridle, hyprpaper, hyprsunset, dunst, beide Clipboard-Watcher und
`media-watch` laufen als User-Services unter `systemd --user`. Hyprland ruft beim Start nur
`uwsm finalize` auf; sobald uwsm die Session als bereit meldet, startet
`graphical-session.target` das `hypr-session.target` und damit alle Dienste.
Die Dienste haengen ausschliesslich ueber `Wants=` am Target.

Auf jedem Rechner einmalig (macht `bin/theme-setup` mit):

```sh
systemctl --user enable hypr-session.target
```

Nach dem Installieren oder Ändern der Units:

```sh
systemctl --user daemon-reload
systemctl --user restart hypr-session.target
systemctl --user status hypr-session.target
```

Logs findest du mit `journalctl --user -u hypridle -u waybar -u hyprpaper -f`.
Die eigenen Dienste haben Speicher-/Prozesslimits und laufen mit reduzierten
Systemrechten. Die Paketeinheiten von Dunst und hyprpolkitagent erhalten diese
Regeln ueber User-Drop-ins unter `systemd/user/*.service.d/`.

Wegen `NoNewPrivileges` und der Limits erbt alles, was ein Dienst startet, diese
Einschraenkungen (z.B. funktioniert dort kein `sudo`). Programme, die aus Waybar,
dunst, dem Launcher oder per Taste gestartet werden, laufen deshalb ueber
`uwsm-app --` als eigene Unit. `uwsm-app` ist der schnelle Client von uwsm (~10 ms
statt ~90 ms) und spricht mit `wayland-wm-app-daemon.service`, das mit der Session startet.
`hypridle.service` hat bewusst gar keine Sandbox-Optionen: hyprlock braucht das
setuid-Programm `unix_chkpwd` fuer die Passwortpruefung, und in User-Units
blockieren sowohl `NoNewPrivileges` (auch implizit ueber `LockPersonality`,
`RestrictSUIDSGID`, `RestrictRealtime`) als auch die Namespace-Optionen
(`PrivateTmp`, `ProtectSystem`, `ProtectKernel*`, `ProtectControlGroups`) das.

### Waybar-Status

Rechts zeigt Waybar zusaetzlich das Power-Profil (eingebautes Modul
`power-profiles-daemon`, ohne Polling) und den Idle-Inhibitor. Klick auf das
Power-Profil wechselt zum naechsten Profil, Rechtsklick zum vorherigen. Akku, Audio, Netzwerk und die
bestehenden Systemanzeigen bleiben je nach Desktop- oder Laptop-Profil
verfuegbar.

## Abendprofil

`hyprsunset.conf` stellt ab 21:00 auf 4500 K und ab 07:30 auf unveraenderte
Tagesfarben um. Helligkeit/Gamma bleiben bei 100 %.
Autostart erfolgt ueber `hyprsunset.service` (`scripts/run-hyprsunset.sh`).

`scripts/run-hyprsunset.sh` nimmt das Paket (`sudo pacman -S hyprsunset`) und nur
ersatzweise eine Kopie unter `~/.local/bin/hyprsunset`, die keine Updates bekommt.

- `hyprctl hyprsunset identity`: normale Farben bis zum naechsten Profilwechsel.
- `hyprctl hyprsunset temperature 4500`: warme Farben sofort einschalten.

## Pruefung

`dotfiles-check` prueft das ganze Repo und laeuft auch vor jedem Commit. Fuer Hyprland allein:
`hyprctl reload` laedt die Konfiguration neu, `hyprctl configerrors` zeigt Fehler.
`Hyprland --verify-config` stuerzt mit der Lua-Config ab (0.57) und taugt dafuer nicht.
