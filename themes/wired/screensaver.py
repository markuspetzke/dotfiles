"""Wired-Bildschirmschoner (laeuft im Vollbild-Kitty, gestartet von bin/screensaver).
Erst ~2 s Rauschen, dann fallende Spalten aus Hex-Werten. Beendet sich bei jeder Taste."""
import os
import random
import select
import sys
import termios
import time
import tty

GREEN, BRIGHT, DIM, VIOLET, BG = (127, 216, 143), (200, 255, 210), (47, 90, 55), (157, 132, 216), (7, 8, 7)


def fg(c):
    return f"\x1b[38;2;{c[0]};{c[1]};{c[2]}m"


def bg(c):
    return f"\x1b[48;2;{c[0]};{c[1]};{c[2]}m"


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
    rng = random.Random()
    out.write("\x1b[?1049h\x1b[?25l\x1b[?1003h" + bg(BG) + "\x1b[2J")

    # Phase 1: Rauschen
    end = time.time() + 2.0
    while time.time() < end:
        if key_pressed():
            return
        buf = ["\x1b[H"]
        for _ in range(rows):
            buf.append("".join(fg(rng.choice((DIM, DIM, GREEN))) + rng.choice(" ░▒▓") for _ in range(cols)))
        out.write("\n".join(buf))
        out.flush()
        time.sleep(0.06)

    # Phase 2: Hex-Regen (Spaltenbreite 3: "a7 ")
    out.write(bg(BG) + "\x1b[2J")
    ncol = cols // 3
    heads = [rng.randrange(-rows, 0) for _ in range(ncol)]
    speed = [rng.choice((1, 1, 2)) for _ in range(ncol)]
    trail = 14
    while True:
        if key_pressed():
            return
        buf = []
        for i in range(ncol):
            x = i * 3 + 1
            h = heads[i]
            for k in range(speed[i]):
                y = h + k
                if 0 <= y < rows:
                    color = VIOLET if rng.random() < 0.02 else BRIGHT
                    buf.append(f"\x1b[{y + 1};{x}H{fg(color)}{rng.randrange(256):02x}")
                if 0 <= y - 1 < rows:
                    buf.append(f"\x1b[{y};{x}H{fg(GREEN)}{rng.randrange(256):02x}")
                if 0 <= y - trail // 2 < rows:
                    buf.append(f"\x1b[{y - trail // 2 + 1};{x}H{fg(DIM)}{rng.randrange(256):02x}")
                if 0 <= y - trail < rows:
                    buf.append(f"\x1b[{y - trail + 1};{x}H  ")
            heads[i] = h + speed[i]
            if heads[i] - trail > rows:
                heads[i] = rng.randrange(-rows // 2, 0)
                speed[i] = rng.choice((1, 1, 2))
        out.write("".join(buf))
        out.flush()
        time.sleep(0.07)


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
