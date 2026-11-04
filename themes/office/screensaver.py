"""Office screensaver: the note "Conference room. Five minutes." (Michael Scott), slowly wandering
across the screen (against burn-in). Runs in a fullscreen kitty (bin/screensaver),
quits on any key."""
import os
import select
import sys
import termios
import time
import tty

PAPER, INK, MUTED, BLUE, WALL = (42, 47, 55), (230, 223, 207), (141, 135, 120), (91, 138, 208), (24, 27, 32)


_START = time.time()


def key_pressed():
    """Key or mouse move (terminal mouse reports) -> quit; ignore the first second."""
    if not select.select([sys.stdin], [], [], 0)[0]:
        return False
    os.read(sys.stdin.fileno(), 4096)
    return time.time() - _START > 1.0


def bg(c):
    return f"\x1b[48;2;{c[0]};{c[1]};{c[2]}m"


def fg(c):
    return f"\x1b[38;2;{c[0]};{c[1]};{c[2]}m"


def sign_lines(since):
    inner = 34
    rows = [
        ("", MUTED),
        ("CONFERENCE ROOM.", INK),
        ("FIVE MINUTES.", INK),
        ("", MUTED),
        (f"– M. Scott, since {since}", MUTED),
        ("", MUTED),
    ]
    return inner, rows


def main():
    out = sys.stdout
    cols, rows = os.get_terminal_size()
    since = time.strftime("%H:%M")
    out.write("\x1b[?1049h\x1b[?25l\x1b[?1003h" + bg(WALL) + "\x1b[2J")
    inner, lines = sign_lines(since)
    w, h = inner + 2, len(lines) + 3  # + border + blue header
    x, y, dx, dy = 4.0, 3.0, 0.35, 0.15
    prev = None
    while True:
        if key_pressed():
            return
        buf = []
        if prev:
            px, py = prev
            for i in range(h + 1):
                buf.append(f"\x1b[{py + i + 1};{px + 1}H" + bg(WALL) + " " * (w + 2))
        ix, iy = int(x), int(y)
        # Shadow
        for i in range(1, h + 1):
            buf.append(f"\x1b[{iy + i + 1};{ix + 3}H" + bg((14, 16, 19)) + " " * w)
        # Header
        buf.append(f"\x1b[{iy + 1};{ix + 1}H" + bg(BLUE) + fg((255, 255, 255)) + " DUNDER MIFFLIN · MEMO".ljust(w))
        # Paper
        for i, (text, color) in enumerate(lines):
            buf.append(f"\x1b[{iy + i + 2};{ix + 1}H" + bg(PAPER) + fg(color) + " " + text.center(inner) + " ")
        clock = time.strftime("now %H:%M")
        buf.append(f"\x1b[{iy + len(lines) + 2};{ix + 1}H" + bg(PAPER) + fg(MUTED) + " " + clock.rjust(inner) + " ")
        buf.append(f"\x1b[{iy + len(lines) + 3};{ix + 1}H" + bg(PAPER) + " " * w)
        out.write("".join(buf))
        out.flush()
        prev = (ix, iy)
        x += dx
        y += dy
        if x <= 1 or x + w + 3 >= cols:
            dx = -dx
            x = max(1, min(x, cols - w - 4))
        if y <= 1 or y + h + 2 >= rows:
            dy = -dy
            y = max(1, min(y, rows - h - 3))
        time.sleep(0.12)


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
