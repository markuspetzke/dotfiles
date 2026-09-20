# Hyprland

Lua-Konfiguration fuer Hyprland 0.56. Das Profil wird ueber `HYPR_PROFILE`
(`desktop` oder `laptop`), Akku-Erkennung oder als letzter Fallback ueber den
Hostnamen bestimmt.

Zum expliziten Umschalten vor Hyprland: `HYPR_PROFILE=laptop Hyprland`.

## Tastenkombinationen

| Tasten | Aktion |
| --- | --- |
| `Super+Escape` | Bildschirm sperren |
| `Super+Pfeiltasten` | Fensterfokus verschieben |
| `Super+H/J/K/L` | Fokus links/unten/oben/rechts |
| `Super+Shift+Pfeiltasten` oder `H/J/K/L` | Fenster verschieben |
| `Super+Ctrl+Pfeiltasten` oder `H/J/K/L` | Fenster groesser/kleiner machen |
| `Super+Ctrl+,` | Master-Breite auf 55 % |
| `Super+Ctrl+.` | Master-Breite auf 70 % |
| `Super+Ctrl+F1` | Laptop: nur internes Display |
| `Super+Ctrl+F2` | Laptop: externe Displays rechts erweitern |
| `Super+Ctrl+F3` | Laptop: internes Display auf externe spiegeln |
| `Super` loslassen | Launcher |
| `Super+V` | Clipboard-Verlauf |
| `Super+Shift+S` | Bereich als Screenshot in Zwischenablage |
| `Print` | Bereich als Datei im Bilderverzeichnis und in Zwischenablage |

`Alt+Pfeiltasten` und `Alt+H/J/K/L` bleiben fuer Anwendungen frei.
`Super+Shift+L` verschiebt jetzt, wie die anderen Shift-Richtungstasten, ein Fenster nach rechts.
Auf der Neo65 sperrt auch `Super+code:49` als Fallback fuer QMK Grave-Escape.

## Laptop-Monitore

Ein neuer Laptop-Login startet mit dem erweiterten Profil. Die Auswahl wird in
`~/.config/hypr/.monitor-profile` gespeichert und bleibt ueber Neustarts
erhalten. Sie gilt auch fuer neu angeschlossene Displays.
Das interne Display (`eDP-1`) bleibt in allen Profilen aktiv. Falls der Laptop
einen anderen Anschlussnamen verwendet, diesen in `monitors.lua` anpassen.
Die Desktop-Belegung mit DP-2/DP-3 bleibt separat konfiguriert.

### Zuklappen

`hypridle` kann das Lid-Ereignis nicht selbst auswerten; dafuer ist
`systemd-logind` zustaendig. Die passende Drop-in-Datei liegt unter
`hypr/logind/laptop.conf`. Auf dem Laptop einmal installieren:

```sh
sudo install -Dm644 ~/.config/hypr/logind/laptop.conf /etc/systemd/logind.conf.d/90-hypr-laptop.conf
sudo systemctl restart systemd-logind
```

Danach sperrt Zuklappen auf Akku und Netzteil. Im Dock bleibt der Rechner an
und externe Monitore bleiben aktiv. Das gilt systemweit, ist auf einem Desktop
ohne Lid aber wirkungslos.

### Inaktivitaet

Der Laptop verwendet `hypridle-laptop.conf`: Nach 10 Minuten werden die
Displays abgeschaltet, nach 15 Minuten wird die Sitzung vor dem Hibernate
gesperrt und das System geht in Hibernate. Waerend Medienwiedergabe laeuft,
werden diese Aktionen durch `playerctl` unterdrueckt.

Der Desktop verwendet weiterhin `hypridle.conf` mit 10 Minuten DPMS, 20 Minuten
Sperre und 60 Minuten Suspend.

### Automatische Monitore und Power-Profile

Auf Laptops wird beim Start automatisch zwischen `mobile` (nur `eDP-1`) und
`extended` (externer Monitor rechts) gewaehlt. Monitor-Hotplug schaltet diese
Profile ebenfalls automatisch um; die manuellen `Super+Ctrl+F1/F2/F3`-Shortcuts
bleiben verfuegbar. `presentation` ist weiterhin ein manueller Override.

`power-profile.service` waehlt bei Netzbetrieb `balanced` und auf Akku
`power-saver`. Dafuer muss `power-profiles-daemon` installiert sein:

```sh
sudo pacman -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

Ohne das Paket bleibt der Dienst deaktiviert und veraendert nichts.

### Dienste

Waybar, hypridle, hyprpaper, hyprsunset, dunst und beide Clipboard-Watcher
laufen als User-Services unter `systemd --user`. Hyprland importiert beim Start
nur noch die Wayland-Umgebung und aktiviert `hypr-session.target`.

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

### Waybar-Status

Rechts zeigt Waybar zusaetzlich das Monitorprofil, das Power-Profil und den
Status von `hypridle`. Ein Klick auf das Power-Profil wechselt zwischen
`power-saver`, `balanced` und `performance`. Akku, Audio, Netzwerk und die
bestehenden Systemanzeigen bleiben je nach Desktop- oder Laptop-Profil
verfuegbar.

## Abendprofil

`hyprsunset.conf` stellt ab 21:00 auf 4500 K und ab 07:30 auf unveraenderte
Tagesfarben um. Helligkeit/Gamma bleiben bei 100 %.
Autostart erfolgt ueber `scripts/start-hyprsunset.sh`, das doppelte Instanzen vermeidet.

Auf diesem Rechner liegt hyprsunset 0.4.0 unter `~/.local/bin/hyprsunset`,
aus dem signaturgeprueften offiziellen Arch-Paket `hyprsunset-0.4.0-3`.
Eine spaetere Systeminstallation mit `sudo pacman -S hyprsunset` wird bevorzugt;
die lokale Kopie wird nicht automatisch durch pacman aktualisiert.

- `hyprctl hyprsunset identity`: normale Farben bis zum naechsten Profilwechsel.
- `hyprctl hyprsunset temperature 4500`: warme Farben sofort einschalten.

## Pruefung

`Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`

`hyprctl reload` laedt die Konfiguration neu; `hyprctl configerrors` zeigt Fehler.
