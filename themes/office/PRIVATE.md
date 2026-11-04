# Your own files for the Office theme

Files in `private/` are used automatically. The folder is in `.gitignore` (logo, show images
and music are copyrighted). To version them anyway (private repo): remove the line
`themes/*/private/` from `.gitignore`.

| File | Effect |
| --- | --- |
| `private/wallpaper.png` / `.jpg` / `.webp` | replaces the drawn wallpaper (all times of day) |
| `private/logo.png` | image above the time clock on the lock screen (a transparent PNG works best) |
| `private/sounds/unlock.ogg` | sound after unlocking (also `.wav`, `.flac`, `.mp3`) |
| `private/sounds/notify.*`, `private/sounds/lock.*` | sound for notifications and when locking |

Run `theme office` once afterwards. Keep sounds short (a few seconds), e.g. with
`ffmpeg -i title.mp3 -t 6 -af afade=t=out:st=5:d=1 private/sounds/unlock.ogg`.
The same works for every other theme (`themes/<name>/private/`).
