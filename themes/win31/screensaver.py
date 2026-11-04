"""Windows-3.1-Bildschirmschoner: Sternenfeld, das aus der Mitte heranfliegt
(laeuft im Vollbild-Kitty, gestartet von bin/screensaver). Beendet sich bei jeder Taste."""
import os
import random
import select
import sys
import termios
import time
import tty

STAGES = [(0.25, (90, 90, 90), "."), (0.5, (160, 160, 160), "·"), (0.75, (220, 220, 220), "+"), (2.0, (255, 255, 255), "*")]


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
    cx, cy = cols / 2, rows / 2
    rng = random.Random()
    out.write("\x1b[?1049h\x1b[?25l\x1b[?1003h\x1b[48;2;0;0;0m\x1b[2J")

    def new_star():
        return [rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(0.6, 1.0)]

    stars = [new_star() for _ in range(160)]
    for s in stars:
        s[2] = rng.uniform(0.05, 1.0)
    drawn = {}
    while True:
        if key_pressed():
            return
        buf = []
        for pos in list(drawn):
            buf.append(f"\x1b[{pos[1] + 1};{pos[0] + 1}H ")
        drawn.clear()
        for s in stars:
            s[2] -= 0.012
            if s[2] <= 0.02:
                s[:] = new_star()
            x = int(cx + s[0] / s[2] * cx * 0.5)
            y = int(cy + s[1] / s[2] * cy * 0.5)
            if not (0 <= x < cols and 0 <= y < rows):
                s[:] = new_star()
                continue
            nearness = 1 - s[2]
            for limit, color, ch in STAGES:
                if nearness < limit:
                    break
            buf.append(f"\x1b[{y + 1};{x + 1}H\x1b[38;2;{color[0]};{color[1]};{color[2]}m{ch}")
            drawn[(x, y)] = True
        out.write("".join(buf))
        out.flush()
        time.sleep(0.05)


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
