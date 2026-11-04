# Your own files for the Windows XP theme

`private/` is in `.gitignore` (Microsoft material). Without these files the theme uses its
own drawings and sounds. Run `theme winxp` after adding them.

| File | Effect |
| --- | --- |
| `private/wallpaper.png` | wallpaper (Bliss, 1920x1080), takes precedence over `wallpapers/` |
| `private/logo.png` | logo: lock screen (position: `logo.conf`) and pixel logo in fastfetch |
| `private/start-icon.png` | logo in the taskbar start button (40 px) |
| `private/icons/<name>.png` | start menu icons (documents, pictures, music, folder, computer, control, search, help, run, logoff, shutdown, volume, internet); fallback: `icons/` (icons.py) |
| `private/sounds/{notify,critical,lock,unlock,startup,shutdown}.wav` | XP sounds; all originals in `private/sounds/xp/` |
| `private/user.png` | user picture in the start menu (otherwise ~/.face or a tile) |
| `private/icon-theme/Theme-winxp-icons/` | XP folders/drives/recycle bin for Thunar (icon theme, fixed sizes 16-128) |
