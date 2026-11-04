# Dotfiles (~/.config)

Arch Linux, Hyprland 0.57 (Lua config) through uwsm, Waybar, Kitty, Dunst, Neovim (lazy.nvim).
The repo `markuspetzke/dotfiles` is **public**. One branch (`master`) for desktop and laptop;
`hypr/scripts/hypr-profile.sh` detects the differences at runtime.
Everything in the repo is in English: docs, comments, script output, theme texts, commit messages.
Exception: strings that must match German program output (e.g. dialog titles in
`hypr/windowrule.lua`). The user talks to Claude in German.

## What is versioned

`.gitignore` is a whitelist (`*`, then `!folder/`). New folders/files must be allowed there,
otherwise they do not end up in the repo. Never versioned:
- `theme-current` (local symlink to the active theme, per machine)
- `themes/*/private/` (copyrighted material: logos, images, sounds)
- `systemd/user/*.wants/`, `hypr/.monitor-profile`

## Layout

| Path | Contents |
| --- | --- |
| `hypr/` | `hyprland.lua` loads `host.lua`, `binds.lua`, `monitors.lua`, `windowrule.lua`, `theme.lua` last. See `hypr/README.md` |
| `hypr/scripts/` | helper scripts, e.g. `hypr-profile.sh` (profile `desktop`/`laptop`: `HYPR_PROFILE` or battery detection) |
| `themes/<name>/` | desktop themes (retro, wired, win31, winxp, office, tokyonight). Files and extras: `themes/README.md` |
| `bin/` | own scripts, linked into `~/.local/bin`. Overview: `bin/README.md` |
| `waybar/` | `style.css` = theme colors + `base.css` + theme overrides; `modules.jsonc` = shared bar settings and modules, `config-{desktop,laptop}.jsonc` only the right-hand modules |
| `systemd/user/` | session services (`hypr-session.target`), backups, timers |
| `uwsm/env` | session variables for Hyprland and all systemd services |
| `nvim/` | Neovim config, see `nvim/README.md`; the theme comes from `themes/<name>/nvim.lua` |
| `bash/`, `git/` | `~/.bashrc` only loads `bash/bashrc`; `git/config` holds the defaults, name/mail and the GitHub SSH rewrite stay local in `~/.gitconfig` |
| `.githooks/` | `pre-commit` runs `bin/dotfiles-check --staged` (enabled through `core.hooksPath`, set by `theme-setup`) |
| `README.md`, `docs/` | overview for GitHub with a screenshot per theme |

## Themes

- Configs only include `~/.config/theme-current/...`. Switch with `theme <name>` (reloads everything).
- New theme: copy a folder; `palette.lua` must exist (that is how `theme` recognizes a theme).
- Generated files (`wallpaper.png`, `sounds/`, `cursor/`) come from `wallpaper.py`,
  `sounds.py`, `cursor.py` in the theme folder: regenerate them after color changes, do not edit by hand.
- When adding theme files/extras, update the tables in `themes/README.md`; new scripts go into `bin/README.md`.

## Working on it

- Check changes live (`hyprctl reload`, `theme <name>`, `hyprctl` / `journalctl --user`).
- Do not switch branches while Hyprland runs: a missing config -> emergency mode.
- Do not slow down the Hyprland config with blocking calls; move slow work into scripts
  (example: `bin/video-tags`).
- Mind the laptop profile: effects that redraw constantly (shader, rotating border) are off there.
- hypridle runs each stage only once per idle period. So "not while X" never goes into
  `on-timeout` as a condition, but becomes an idle inhibitor (`systemd-inhibit`, see `media-watch`)
  or `condition_cmd` + `condition_retry`.
- Start programs from binds/Waybar/dunst through `uwsm-app --`.
- Run `dotfiles-check` before committing (it also runs as a hook). `Hyprland --verify-config`
  crashes with the Lua config; use `hyprctl configerrors` for Hyprland.
- Screenshots for `docs/`: with the `private/` content (that is how the user uses the themes), but
  without media titles in the bar. The `private/` files themselves never go into the repo.
- Commits only under the user's name, no Co-Authored-By line and no mention of Claude.
  Do not push, the user does that.
- Do not run sudo steps (e.g. `bin/greeter-setup`) yourself; tell the user.
