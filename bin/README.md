# bin

Eigene Skripte, die Hyprland bzw. systemd aufrufen. Sie liegen hier versioniert und
werden nach `~/.local/bin` verlinkt (dort stehen sie im `PATH`):

```sh
for f in ~/.config/bin/*; do [ "${f##*.}" = md ] || ln -sf "$f" ~/.local/bin/; done
```

| Skript | Zweck |
| --- | --- |
| `theme` | Desktop-Theme wechseln (`theme`, `theme <name>`), siehe `themes/README.md` |
| `stream-tode` | Todeszaehler fuer OBS (`Super+X`, `Super+Shift+X`, `Super+Ctrl+X`) |
| `stream-clip` | Replay-Puffer von OBS speichern (`Super+C`) |
| `obs-ws` | Minimaler obs-websocket-v5-Client (Python-Stdlib) |
| `stream-setup-sichern` | OBS/PipeWire-Einrichtung nach `~/Documents/Twitch/setup` (vor `backup-storaged`) |
