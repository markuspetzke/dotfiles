# Eigene Dateien fuer das Office-Theme

Dateien in `private/` werden automatisch benutzt. Der Ordner ist in `.gitignore`
(Logo, Serienbilder, Musik sind urheberrechtlich geschuetzt). Wer sie trotzdem
versionieren will (privates Repo): Zeile `themes/*/private/` aus `.gitignore` entfernen.

| Datei | Wirkung |
| --- | --- |
| `private/wallpaper.png` / `.jpg` / `.webp` | ersetzt das gezeichnete Wallpaper (alle Tageszeiten) |
| `private/logo.png` | Bild ueber der Stempeluhr auf dem Sperrbildschirm (transparentes PNG am besten) |
| `private/sounds/unlock.ogg` | Klang nach dem Entsperren (auch `.wav`, `.flac`, `.mp3`) |
| `private/sounds/notify.*`, `private/sounds/lock.*` | Klang bei Benachrichtigung bzw. beim Sperren |

Danach einmal `theme office`. Klaenge kurz halten (ein paar Sekunden), z. B. mit
`ffmpeg -i titel.mp3 -t 6 -af afade=t=out:st=5:d=1 private/sounds/unlock.ogg`.
Gilt genauso fuer jedes andere Theme (`themes/<name>/private/`).
