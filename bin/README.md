# bin

Eigene Skripte, die Hyprland bzw. systemd aufrufen. Sie liegen hier versioniert und
werden nach `~/.local/bin` verlinkt (dort stehen sie im `PATH`):

```sh
for f in ~/.config/bin/*; do [ "${f##*.}" = md ] || ln -sf "$f" ~/.local/bin/; done
```

| Skript | Zweck |
| --- | --- |
| `theme-setup` | Einrichtung der Themes auf einem neuen Rechner (Laptop): Schrift, Skripte, Timer, Theme |
| `theme` | Desktop-Theme wechseln (`theme`, `theme <name>`), siehe `themes/README.md` |
| `idle-test` | Idle-Kette (Bildschirmschoner, Sperre, DPMS) mit kurzen Zeiten testen |
| `launcher-hide` | Programme aus `hypr/launcher-hidden.txt` im Launcher ausblenden (bleiben installiert) |
| `theme-greeter` | Anmeldebildschirm (sysc-greet) an das Theme anpassen; einmalig `sudo greeter-setup` |
| `greeter-setup` | Einmalige Root-Einrichtung fuer `theme-greeter` (mit sudo) |
| `theme-browser` | Browser-Theme (Helium) aus `themes/<name>/browser.json` bauen |
| `video-tags` | Fenster mit laufendem Video markieren, damit sie nicht abgedunkelt werden (Hyprland startet es alle 2 s, nur bei Themes mit Abdunkeln) |
| `theme-wallpaper` | Wallpaper des Themes nach Uhrzeit (Timer alle 10 min) |
| `theme-sound` | Klang des Themes abspielen (dunst, `theme-lock`) |
| `theme-lock` | Sperren mit Theme-Klaengen (hypridle `lock_cmd`) |
| `screensaver` | Bildschirmschoner des Themes starten/stoppen (hypridle) |
| `stream-tode` | Todeszaehler fuer OBS (`Super+X`, `Super+Shift+X`, `Super+Ctrl+X`) |
| `stream-clip` | Replay-Puffer von OBS speichern (`Super+C`) |
| `obs-ws` | Minimaler obs-websocket-v5-Client (Python-Stdlib) |
| `stream-setup-sichern` | OBS/PipeWire-Einrichtung nach `~/Documents/Twitch/setup` (vor `backup-storaged`) |
