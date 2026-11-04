"""Windows-XP-Bildschirmschoner: "Rohre" - bunte Leitungen wachsen kreuz und quer ueber
den schwarzen Bildschirm (eigene Terminal-Umsetzung der bekannten Idee). Laeuft im
Vollbild-Kitty (bin/screensaver), beendet sich bei jeder Taste."""
import os
import random
import select
import sys
import termios
import time
import tty

COLORS = [(59, 140, 245), (87, 184, 87), (240, 160, 80), (231, 72, 86), (249, 199, 79), (97, 214, 214), (180, 127, 224)]
DIRS = [(0, -1), (1, 0), (0, 1), (-1, 0)]  # hoch, rechts, runter, links


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
    out.write("\x1b[?1049h\x1b[?25l\x1b[?1003h\x1b[48;2;0;0;0m\x1b[2J")

    def new_pipe():
        return [rng.randrange(cols), rng.randrange(rows), rng.randrange(4), rng.choice(COLORS)]

    pipes = [new_pipe() for _ in range(3)]
    drawn = 0
    while True:
        if key_pressed():
            return
        buf = []
        for p in pipes:
            x, y, d, c = p
            nd = d
            if rng.random() < 0.12:  # abbiegen (nie umkehren)
                nd = (d + rng.choice((1, 3))) % 4
            if nd != d:  # Gelenk: heller Block an der Abbiegung
                j = tuple(min(255, int(v * 1.35) + 40) for v in c)
                buf.append(f"\x1b[{y + 1};{x + 1}H\x1b[38;2;{j[0]};{j[1]};{j[2]}m█")
            else:  # Rohr: voller Block, waagrecht etwas dunkler (wirkt plastischer)
                k = c if nd in (0, 2) else tuple(int(v * 0.8) for v in c)
                buf.append(f"\x1b[{y + 1};{x + 1}H\x1b[38;2;{k[0]};{k[1]};{k[2]}m█")
            dx, dy = DIRS[nd]
            x, y = x + dx, y + dy
            if not (0 <= x < cols and 0 <= y < rows):
                p[:] = new_pipe()
                continue
            p[:] = [x, y, nd, c]
            drawn += 1
        out.write("".join(buf))
        out.flush()
        if drawn > cols * rows * 0.9:  # Bildschirm voll: neu anfangen
            out.write("\x1b[48;2;0;0;0m\x1b[2J")
            pipes = [new_pipe() for _ in range(3)]
            drawn = 0
        time.sleep(0.025)


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
