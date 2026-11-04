#!/usr/bin/env python3
"""Windows XP start menu for the winxp theme (own implementation with GTK 3).

Header with the user picture, pinned + frequently used programs on the left (from the
hyprlauncher history), places and system on the right, log off/turn off at the bottom.
Started by bin/menu (start button, Super key). Closes on Esc or focus loss.
User picture: private/user.png, otherwise ~/.face, otherwise a tile with the initial."""
import collections
import getpass
import os
import signal
import subprocess
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("Pango", "1.0")
from gi.repository import Gdk, GdkPixbuf, Gio, GLib, Gtk, Pango  # noqa: E402

HERE = os.path.dirname(os.path.realpath(__file__))
HOME = os.path.expanduser("~")

CSS = b"""
* { font-family: "Tahoma", "Noto Sans", "Liberation Sans", sans-serif; font-size: 12px; }
#menu { background: #ffffff; border: 1px solid #1c4fbf; border-radius: 7px 7px 0 0; }
#header {
    background-image: linear-gradient(to bottom, #6fa5f7 0%, #3a80f0 6%, #2b6de0 30%, #2462d8 70%, #1f5ad1 100%);
    border-top: 1px solid #8cb8ff; border-radius: 6px 6px 0 0; padding: 10px 10px;
}
#username { color: #ffffff; font-size: 17px; font-weight: bold; text-shadow: 1px 1px 1px #0c2f7a; }
#picture { border: 2px solid #ffffff; border-radius: 4px; }
#orange { background-image: linear-gradient(to right, #1d5bd6, #e7792b 20%, #f2a35e 50%, #e7792b 80%, #1d5bd6); min-height: 2px; }
#left { background: #ffffff; padding: 6px 4px; }
#right { background: #d3e5fa; border-left: 1px solid #95bdee; padding: 6px 4px; }
button.item { background: transparent; border: none; box-shadow: none; padding: 3px 6px; border-radius: 0; }
button.item:hover { background: #316ac5; }
button.item:hover label { color: #ffffff; }
label.name { color: #000000; }
label.name.bold { font-weight: bold; }
label.sub { color: #808080; font-size: 11px; }
#right label.name { color: #0b2a6f; }
#right button.item:hover label.name { color: #ffffff; }
separator.left { background: #d6d3ce; min-height: 1px; margin: 4px 6px; }
separator.right { background: #95bdee; min-height: 1px; margin: 4px 6px; }
#allprograms label { font-weight: bold; }
#allprograms-arrow { color: #2f9a2f; font-size: 15px; font-weight: bold; }
#footer {
    background-image: linear-gradient(to bottom, #4a8ff6 0%, #2b6de0 15%, #2462d8 70%, #1a4fc5 100%);
    padding: 6px 8px;
}
#footer button { background: transparent; border: none; box-shadow: none; padding: 2px 8px; }
#footer button:hover { background: rgba(255,255,255,0.15); }
#footer label { color: #ffffff; }
#search { background: #ffffff; color: #000000; border: 1px solid #7f9db9; border-radius: 2px;
          padding: 4px 6px; margin: 4px 6px; box-shadow: none; caret-color: #000000; }
#search:focus { border-color: #316ac5; }
button.item.selected { background: #316ac5; }
button.item.selected label { color: #ffffff; }
label.empty { color: #808080; padding: 10px; }
#shutdown { background: #5a7edc; padding: 14px; }
#shutdown label.title { color: #ffffff; font-size: 15px; font-weight: bold; }
#shutdown button { background: #ffffff; border: 1px solid #003c74; border-radius: 3px; padding: 6px 12px; }
#shutdown button:hover { background: #ffe8a5; }
#shutdown button label { color: #000000; }
"""

PINNED = [("Internet", "helium.desktop", "Helium Browser"), ("Command Prompt", "kitty.desktop", "Kitty")]
PLACES = [
    ("My Documents", "documents", ["thunar", f"{HOME}/Documents"]),
    ("My Pictures", "pictures", ["thunar", f"{HOME}/Pictures"]),
    ("My Music", "music", ["thunar", f"{HOME}/Music"]),
    ("My Downloads", "folder", ["thunar", f"{HOME}/Downloads"]),
    ("My Computer", "computer", ["thunar", "/"]),
    None,
    ("Control Panel", "control", ["thunar", f"{HOME}/.config"]),
    ("Sounds and Audio", "volume", ["pavucontrol"]),
    None,
    ("Help and Support", "help", ["xdg-open", "https://wiki.hyprland.org"]),
    ("Search", "search", None),  # -> hyprlauncher
    ("Run...", "run", None),
]


def launch(cmd):
    subprocess.Popen(["uwsm", "app", "--", *cmd], start_new_session=True,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


# Icons: private/icons/<name>.png (originals, not in git) before icons/<name>.png (icons.py)
ICON_DIRS = [os.path.join(HERE, "private", "icons"), os.path.join(HERE, "icons")]


def icon_image(icon, size):
    if isinstance(icon, str):
        for d in ICON_DIRS:
            f = os.path.join(d, icon + ".png")
            if os.path.isfile(f):
                # The originals are 48 px pixel art: "nearest" would be too blocky, bilinear fits
                pb = GdkPixbuf.Pixbuf.new_from_file(f).scale_simple(size, size, GdkPixbuf.InterpType.BILINEAR)
                return Gtk.Image.new_from_pixbuf(pb)
    if isinstance(icon, Gio.Icon):
        img = Gtk.Image.new_from_gicon(icon, Gtk.IconSize.DIALOG)
    else:
        img = Gtk.Image.new_from_icon_name(icon or "application-x-executable", Gtk.IconSize.DIALOG)
    img.set_pixel_size(size)
    return img


def frequent_apps(skip, limit=6):
    """Most frequent programs from the hyprlauncher history, as Gio.AppInfo."""
    path = os.path.join(HOME, ".local/share/hyprlauncher/desktop.cache")
    try:
        names = [line.strip().lower() for line in open(path) if line.strip()]
    except OSError:
        names = []
    apps = {a.get_name().lower(): a for a in Gio.AppInfo.get_all() if a.should_show()}
    out = []
    for name, _ in collections.Counter(names).most_common():
        app = apps.get(name)
        if app and app.get_id() not in skip and app not in out:
            out.append(app)
        if len(out) >= limit:
            break
    return out


class StartMenu(Gtk.Window):
    def __init__(self):
        super().__init__(title="Start")
        self.set_decorated(False)
        self.set_default_size(460, 580)
        self.set_name("menu")
        self.connect("key-press-event", self.on_key)
        # Only close once the menu had focus (otherwise it quits right when opening)
        self.had_focus = False
        self.connect("focus-in-event", self.on_focus_in)
        self.connect("focus-out-event", lambda *_: self.had_focus and self.quit_soon())
        self.closing = False

        self.stack = Gtk.Stack()
        self.stack.add_named(self.build_menu(), "menu")
        self.stack.add_named(self.build_shutdown(), "shutdown")
        self.add(self.stack)

    # --- Layout ------------------------------------------------------------
    def build_menu(self):
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        header = Gtk.Box(spacing=10)
        header.set_name("header")
        header.pack_start(self.user_picture(), False, False, 0)
        name = Gtk.Label(label=getpass.getuser().capitalize())
        name.set_name("username")
        header.pack_start(name, False, False, 0)
        root.pack_start(header, False, False, 0)
        orange = Gtk.Box()
        orange.set_name("orange")
        root.pack_start(orange, False, False, 0)

        body = Gtk.Box(homogeneous=False)
        left = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        left.set_name("left")
        left.set_size_request(250, -1)
        right = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        right.set_name("right")
        body.pack_start(left, True, True, 0)
        body.pack_start(right, True, True, 0)
        root.pack_start(body, True, True, 0)

        self.left_stack = Gtk.Stack()
        default = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        self.results = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        self.left_stack.add_named(default, "default")
        self.left_stack.add_named(self.results, "results")
        left.pack_start(self.left_stack, True, True, 0)
        outer_left, left = left, default

        pinned_ids = set()
        for title, desktop_id, sub in PINNED:
            try:
                app = Gio.DesktopAppInfo.new(desktop_id)
            except TypeError:
                app = None
            if not app:
                continue
            pinned_ids.add(desktop_id)
            ico = "internet" if title == "Internet" and any(os.path.isfile(os.path.join(d, "internet.png")) for d in ICON_DIRS) else app.get_icon()
            left.pack_start(self.item(ico, title, sub, lambda a=app: launch([a.get_id()]), bold=True, size=32), False, False, 0)
        left.pack_start(self.sep("left"), False, False, 0)
        for app in frequent_apps(pinned_ids):
            left.pack_start(self.item(app.get_icon(), app.get_name(), None, lambda a=app: launch([a.get_id()]), size=32), False, False, 0)
        # Search field: has focus right when opening (press Super, type, Enter)
        self.search = Gtk.SearchEntry()
        self.search.set_name("search")
        self.search.set_placeholder_text("Search programs")
        self.search.set_width_chars(12)
        self.search.connect("search-changed", self.on_search)
        self.search.connect("activate", lambda *_: self.launch_selected())
        self.search.connect("key-press-event", self.on_search_key)
        outer_left.pack_end(self.all_programs(), False, False, 0)
        outer_left.pack_end(self.search, False, False, 0)
        outer_left.pack_end(self.sep("left"), False, False, 0)
        self.apps = [a for a in Gio.AppInfo.get_all() if a.should_show()]
        self.hits, self.sel = [], 0

        for entry in PLACES:
            if entry is None:
                right.pack_start(self.sep("right"), False, False, 0)
                continue
            title, icon, cmd = entry
            action = (lambda c=cmd: launch(c)) if cmd else self.open_launcher
            right.pack_start(self.item(icon, title, None, action, bold=True, size=24), False, False, 0)

        footer = Gtk.Box(spacing=4)
        footer.set_name("footer")
        footer.pack_end(self.footer_button("shutdown", "Turn Off Computer", lambda: self.stack.set_visible_child_name("shutdown")), False, False, 0)
        footer.pack_end(self.footer_button("logoff", "Log Off", lambda: self.run(["loginctl", "lock-session"])), False, False, 0)
        root.pack_start(footer, False, False, 0)
        return root

    def build_shutdown(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18)
        box.set_name("shutdown")
        title = Gtk.Label(label="Turn off computer")
        title.get_style_context().add_class("title")
        box.pack_start(title, False, False, 20)
        row = Gtk.Box(spacing=10, halign=Gtk.Align.CENTER)
        for icon, label, cmd in (("standby", "Stand By", ["systemctl", "suspend"]),
                                 ("shutdown", "Turn Off", ["sh", "-c", f"{HOME}/.config/bin/theme-sound --wait shutdown; systemctl poweroff"]),
                                 ("restart", "Restart", ["sh", "-c", f"{HOME}/.config/bin/theme-sound --wait shutdown; systemctl reboot"])):
            b = Gtk.Button()
            inner = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            inner.pack_start(icon_image(icon, 40), False, False, 0)
            inner.pack_start(Gtk.Label(label=label), False, False, 0)
            b.add(inner)
            b.connect("clicked", lambda _b, c=cmd: self.run(c))
            row.pack_start(b, False, False, 0)
        box.pack_start(row, False, False, 0)
        cancel = Gtk.Button(label="Cancel", halign=Gtk.Align.END)
        cancel.connect("clicked", lambda *_: self.stack.set_visible_child_name("menu"))
        box.pack_end(cancel, False, False, 10)
        return box

    def user_picture(self):
        for p in (os.path.join(HERE, "private/user.png"), os.path.join(HOME, ".face")):
            if os.path.isfile(p):
                try:
                    pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(p, 48, 48, True)
                    img = Gtk.Image.new_from_pixbuf(pb)
                    img.set_name("picture")
                    return img
                except GLib.Error:
                    pass
        tile = Gtk.Label(label=getpass.getuser()[:1].upper())
        tile.set_size_request(48, 48)
        tile.set_name("picture")
        tile.override_background_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(0.94, 0.63, 0.31, 1))
        tile.override_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(1, 1, 1, 1))
        return tile

    def item(self, icon, title, sub, action, bold=False, size=32):
        b = Gtk.Button()
        b.get_style_context().add_class("item")
        row = Gtk.Box(spacing=8)
        row.pack_start(icon_image(icon, size), False, False, 0)
        texts = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, valign=Gtk.Align.CENTER)
        lbl = Gtk.Label(label=title, xalign=0)
        lbl.set_ellipsize(Pango.EllipsizeMode.END)  # shorten long names, the column width stays fixed
        lbl.set_max_width_chars(24)
        lbl.get_style_context().add_class("name")
        if bold:
            lbl.get_style_context().add_class("bold")
        texts.pack_start(lbl, False, False, 0)
        if sub:
            s = Gtk.Label(label=sub, xalign=0)
            s.set_ellipsize(Pango.EllipsizeMode.END)
            s.set_max_width_chars(28)
            s.get_style_context().add_class("sub")
            texts.pack_start(s, False, False, 0)
        row.pack_start(texts, True, True, 0)
        b.add(row)
        b.connect("clicked", lambda *_: (action(), self.quit_soon()))
        return b

    def all_programs(self):
        b = Gtk.Button()
        b.set_name("allprograms")
        b.get_style_context().add_class("item")
        row = Gtk.Box(spacing=8, halign=Gtk.Align.CENTER)
        row.pack_start(Gtk.Label(label="All Programs"), False, False, 0)
        arrow = Gtk.Label(label="▶")
        arrow.set_name("allprograms-arrow")
        row.pack_start(arrow, False, False, 0)
        b.add(row)
        b.connect("clicked", lambda *_: (self.open_launcher(), self.quit_soon()))
        return b

    def footer_button(self, icon, label, action):
        b = Gtk.Button()
        row = Gtk.Box(spacing=6)
        row.pack_start(icon_image(icon, 24), False, False, 0)
        row.pack_start(Gtk.Label(label=label), False, False, 0)
        b.add(row)
        b.connect("clicked", lambda *_: action())
        return b

    def sep(self, side):
        s = Gtk.Separator()
        s.get_style_context().add_class(side)
        return s

    # --- Search ------------------------------------------------------------
    def score(self, app, q):
        name = (app.get_name() or "").lower()
        if name.startswith(q):
            return 0
        if q in name:
            return 1
        extra = " ".join(filter(None, [app.get_description() or "", app.get_executable() or "",
                                       " ".join(getattr(app, "get_keywords", lambda: [])() or [])])).lower()
        return 2 if q in extra else None

    def on_search(self, entry):
        q = entry.get_text().strip().lower()
        for child in self.results.get_children():
            self.results.remove(child)
        if not q:
            self.left_stack.set_visible_child_name("default")
            self.hits = []
            return
        scored = sorted((sc, a.get_name().lower(), a) for a in self.apps if (sc := self.score(a, q)) is not None)
        self.hits = [a for _, _, a in scored[:9]]
        self.sel = 0
        self.buttons = []
        for app in self.hits:
            b = self.item(app.get_icon(), app.get_name(), app.get_description(), lambda a=app: launch([a.get_id()]), size=32)
            self.buttons.append(b)
            self.results.pack_start(b, False, False, 0)
        if not self.hits:
            lbl = Gtk.Label(label="No results")
            lbl.get_style_context().add_class("empty")
            self.results.pack_start(lbl, False, False, 0)
        self.results.show_all()
        self.left_stack.set_visible_child_name("results")
        self.mark()

    def mark(self):
        for i, b in enumerate(getattr(self, "buttons", [])):
            ctx = b.get_style_context()
            (ctx.add_class if i == self.sel else ctx.remove_class)("selected")

    def on_search_key(self, _w, ev):
        if ev.keyval in (Gdk.KEY_Down, Gdk.KEY_Up) and self.hits:
            self.sel = (self.sel + (1 if ev.keyval == Gdk.KEY_Down else -1)) % len(self.hits)
            self.mark()
            return True
        if ev.keyval == Gdk.KEY_Escape and self.search.get_text():
            self.search.set_text("")
            return True
        return False

    def launch_selected(self):
        if self.hits:
            launch([self.hits[self.sel].get_id()])
            self.quit_soon()

    # --- Actions -----------------------------------------------------------
    def open_launcher(self):
        subprocess.Popen(["hyprlauncher", "-t"], start_new_session=True,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def run(self, cmd):
        self.quit_soon()
        subprocess.Popen(cmd, start_new_session=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def on_focus_in(self, *_):
        self.had_focus = True
        return False

    def on_key(self, _w, ev):
        if ev.keyval == Gdk.KEY_Escape:
            if self.stack.get_visible_child_name() == "shutdown":
                self.stack.set_visible_child_name("menu")
            else:
                self.quit_soon()
        return False

    daemon = False

    def quit_soon(self):
        if self.daemon:  # background process: only hide, instantly there on the next call
            GLib.idle_add(self.hide_menu)
            return
        if not self.closing:
            self.closing = True
            GLib.idle_add(Gtk.main_quit)

    def hide_menu(self):
        self.hide()
        self.had_focus = False
        return False

    def show_menu(self):
        self.stack.set_visible_child_name("menu")
        self.search.set_text("")
        self.left_stack.set_visible_child_name("default")
        self.show_all()
        self.search.grab_focus()
        self.present()
        # Hyprland does not give focus to windows of background processes by itself
        GLib.timeout_add(40, lambda: subprocess.Popen(
            ["hyprctl", "dispatch", 'hl.dsp.focus({ window = "class:^xp-startmenu$" })'],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) and False)

    def toggle(self, *_):
        if self.get_visible():
            self.hide_menu()
        else:
            self.show_menu()
        return False  # run only once as an idle callback

    def on_signal(self, *_):
        # Do not show directly in the signal handler (GTK hangs there while mapping),
        # but in the next round of the main loop
        GLib.idle_add(self.toggle)
        return True  # keep the signal handler active


def main():
    # Wayland: the window class (app_id) comes from the program name -> Hyprland rule "xp-startmenu"
    GLib.set_prgname("xp-startmenu")
    provider = Gtk.CssProvider()
    provider.load_from_data(CSS)
    Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER)
    win = StartMenu()
    win.connect("destroy", Gtk.main_quit)
    # --daemon: stays in the background, SIGUSR1 shows/hides it (bin/menu); --show: show right away
    win.daemon = "--daemon" in sys.argv
    if win.daemon:
        # own PID for bin/menu (setsid may fork, $! would be wrong then)
        pidfile = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "theme-startmenu.pid")
        with open(pidfile, "w") as f:
            f.write(str(os.getpid()))
        win.connect("delete-event", lambda *_: win.hide_menu() or True)
        try:  # new name (PyGObject >= 3.50); GLib.unix_signal_add does not fire there
            gi.require_version("GLibUnix", "2.0")
            from gi.repository import GLibUnix
            GLibUnix.signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR1, win.on_signal)
        except (ValueError, ImportError):
            GLib.unix_signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR1, win.on_signal)
    if not win.daemon or "--show" in sys.argv:
        win.show_menu()
    Gtk.main()


if __name__ == "__main__":
    sys.exit(main())
