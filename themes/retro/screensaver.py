"""Bernstein-CRT-Bildschirmschoner: grosse Uhr in Blockziffern, die langsam ueber den
Bildschirm wandert und an den Raendern abprallt (laeuft im Vollbild-Kitty, gestartet von
bin/screensaver). Beendet sich bei jeder Taste."""
import os
import select
import sys
import termios
import time
import tty

AMBER, DIM, BG = (232, 163, 61), (110, 78, 32), (20, 19, 16)

# 5x5-Ziffern, '#' = Block
FONT = {
    "0": ["###", "# #", "# #", "# #", "###"],
    "1": [" # ", "## ", " # ", " # ", "###"],
    "2": ["###", "  #", "###", "#  ", "###"],
    "3": ["###", "  #", "###", "  #", "###"],
    "4": ["# #", "# #", "###", "  #", "  #"],
    "5": ["###", "#  ", "###", "  #", "###"],
    "6": ["###", "#  ", "###", "# #", "###"],
    "7": ["###", "  #", "  #", "  #", "  #"],
    "8": ["###", "# #", "###", "# #", "###"],
    "9": ["###", "# #", "###", "  #", "###"],
    ":": ["   ", " # ", "   ", " # ", "   "],
    " ": ["   ", "   ", "   ", "   ", "   "],
}
SCALE_X = 3  # ein Font-Pixel = 3 Zeichen breit, 1 Zeile hoch (Zellen sind ca. 1:2)


def render(text):
    rows = []
    for r in range(5):
        line = ""
        for ch in text:
            line += "".join(("█" if p == "#" else " ") * SCALE_X for p in FONT[ch][r]) + " " * SCALE_X
        rows.append(line.rstrip())
    return rows


_START = time.time()


def key_pressed():
    """Taste oder Mausbewegung (Terminal-Mausmeldungen) -> beenden; erste Sekunde ignorieren."""
    if not select.select([sys.stdin], [], [], 0)[0]:
        return False
    os.read(sys.stdin.fileno(), 4096)
    return time.time() - _START > 1.0


def main():
    out = sys.stdout
    cols, rows = os.get_terminal_size()
    out.write("\x1b[?1049h\x1b[?25l\x1b[?1003h" + f"\x1b[48;2;{BG[0]};{BG[1]};{BG[2]}m\x1b[2J")
    w = len(render("00:00")[0])
    h = 7  # 5 Zeilen Uhr + Leerzeile + Datum
    x, y, dx, dy = 2.0, 2.0, 0.6, 0.25
    prev = None
    while True:
        if key_pressed():
            return
        now = time.localtime()
        colon = ":" if now.tm_sec % 2 == 0 else " "
        clock = render(time.strftime("%H", now) + colon + time.strftime("%M", now))
        date = time.strftime("%a %d.%m.%Y", now).upper()

        buf = []
        if prev:  # alte Position loeschen
            px, py = prev
            for i in range(h):
                buf.append(f"\x1b[{py + i + 1};{px + 1}H" + " " * (w + 1))
        ix, iy = int(x), int(y)
        for i, line in enumerate(clock):
            buf.append(f"\x1b[{iy + i + 1};{ix + 1}H\x1b[38;2;{AMBER[0]};{AMBER[1]};{AMBER[2]}m{line}")
        buf.append(f"\x1b[{iy + 7};{ix + 1}H\x1b[38;2;{DIM[0]};{DIM[1]};{DIM[2]}m{date.center(w)}")
        out.write("".join(buf))
        out.flush()
        prev = (ix, iy)

        x += dx
        y += dy
        if x <= 0 or x + w >= cols - 1:
            dx = -dx
            x = max(0, min(x, cols - w - 2))
        if y <= 0 or y + h >= rows - 1:
            dy = -dy
            y = max(0, min(y, rows - h - 2))
        time.sleep(0.08)


if __name__ == "__main__":
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)
        main()
    except KeyboardInterrupt:
        pass
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        sys.stdout.write("\x1b[?1003l\x1b[0m\x1b[?25h\x1b[?1049l")
        sys.stdout.flush()
