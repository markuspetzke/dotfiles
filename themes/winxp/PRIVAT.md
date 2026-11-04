# Eigene Dateien fuer das Windows-XP-Theme

`private/` ist in `.gitignore` (Microsoft-Material). Ohne diese Dateien nutzt das Theme
eigene Zeichnungen/Klaenge. Danach jeweils `theme winxp`.

| Datei | Wirkung |
| --- | --- |
| `private/wallpaper.png` | Wallpaper (Bliss, 1920x1080), hat Vorrang vor `wallpapers/` |
| `private/logo.png` | Logo: Sperrbildschirm (Position: `logo.conf`) und Pixel-Logo in fastfetch |
| `private/start-icon.png` | Logo im Startknopf der Taskleiste (40 px) |
| `private/icons/<name>.png` | Startmenue-Symbole (documents, pictures, music, folder, computer, control, search, help, run, logoff, shutdown, volume, internet); Ersatz: `icons/` (icons.py) |
| `private/sounds/{notify,critical,lock,unlock,startup,shutdown}.wav` | XP-Klaenge; alle Originale in `private/sounds/xp/` |
| `private/user.png` | Benutzerbild im Startmenue (sonst ~/.face bzw. Kachel) |
| `private/icon-theme/Theme-winxp-icons/` | XP-Ordner/Laufwerke/Papierkorb fuer Thunar (Symbol-Theme, feste Groessen 16-128) |
