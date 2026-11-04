"""Pixel art wallpaper "wired-wires": power poles and wires, per time of day.
  python3 wallpaper.py              -> wallpapers/{day,dusk,night}.png + wallpaper.png (= dusk)
  python3 wallpaper.py <phase> <out>
Renders 480x270, scaled 4x (nearest) to 1920x1080, with scanlines.
Which phase applies when: wallpaper-phases (bin/theme-wallpaper)."""
import random
import sys

from PIL import Image

W, H, SCALE = 480, 270, 4
HORIZON = 200


def hx(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


P = {k: hx(v) for k, v in {
    "void": "#050605", "bg_dark": "#070807", "bg": "#0c0e0c", "surface": "#161a16",
    "dusk1": "#1a1626", "dusk2": "#2a2140", "dusk3": "#3d2f5c", "dusk4": "#5a4580",
    "green": "#7fd88f", "green_dk": "#2f5a37", "fg": "#c9d6c3", "muted": "#6f7d6b",
    "pole": "#030403",
    "day1": "#1c2430", "day2": "#2c3a48", "day3": "#3f5262", "day4": "#5a6e7c",
}.items()}

BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def dither(x, y, t, a, b):
    return b if t * 16 > BAYER[y % 4][x % 4] + 0.5 else a


def ramp(x, y, t, stops):
    t = min(max(t, 0.0), 0.9999)
    seg = t * (len(stops) - 1)
    i = int(seg)
    return dither(x, y, seg - i, stops[i], stops[i + 1])


PHASES = {
    "day": dict(sky=["day1", "day1", "day2", "day3", "day4", "day4"], stars=0, lights=(0, 0)),
    "dusk": dict(sky=["void", "bg_dark", "dusk1", "dusk2", "dusk3", "dusk4"], stars=45, lights=(0, 3)),
    "night": dict(sky=["void", "void", "bg_dark", "dusk1", "dusk2", "dusk2"], stars=140, lights=(2, 6)),
}


def render(phase):
    cfg = PHASES[phase]
    img = Image.new("RGB", (W, H))
    px = img.load()
    rng = random.Random(3)

    # Sky: black at the top, violet towards the horizon
    sky = [P[k] for k in cfg["sky"]]
    for y in range(HORIZON):
        for x in range(W):
            px[x, y] = ramp(x, y, (y / HORIZON) ** 1.8, sky)

    # a few stars
    for _ in range(cfg["stars"]):
        x, y = rng.randrange(W), rng.randrange(int(HORIZON * 0.5))
        px[x, y] = P["fg"] if rng.random() < 0.2 else P["muted"]

    # Ground + green horizon line
    for y in range(HORIZON, H):
        for x in range(W):
            px[x, y] = ramp(x, y, 1 - (y - HORIZON) / (H - HORIZON), [P["void"], P["bg_dark"], P["bg"]])
    for x in range(W):
        px[x, HORIZON] = P["green"] if (x // 3) % 7 else P["green_dk"]
        px[x, HORIZON + 1] = dither(x, HORIZON + 1, 0.4, P["bg"], P["green_dk"])

    # Roofs (silhouettes) along the horizon
    x = 0
    while x < W:
        w = rng.randint(14, 40)
        h = rng.randint(6, 22)
        for xx in range(x, min(W, x + w)):
            for yy in range(HORIZON - h, HORIZON):
                px[xx, yy] = P["pole"]
        # a few lit windows
        for _ in range(rng.randint(*cfg["lights"])):
            fx, fy = rng.randint(x + 2, x + max(3, w - 3)), rng.randint(HORIZON - h + 2, HORIZON - 3)
            if 0 <= fx < W:
                px[fx, fy] = P["green"] if rng.random() < 0.7 else P["fg"]
        x += w + rng.randint(0, 12)

    # Power poles in perspective (near/large on the left, smaller to the right)
    poles = []
    for i, (pxp, top) in enumerate([(30, 18), (150, 70), (255, 104), (340, 128), (405, 146), (452, 158)]):
        thick = max(1, 5 - i)
        base = HORIZON + max(0, 40 - i * 9)
        for yy in range(top, min(H, base)):
            for t in range(thick):
                px[pxp + t, yy] = P["pole"]
        # Crossbar
        arm = max(4, 36 - i * 6)
        for k, off in enumerate((4, 4 + max(3, 12 - i * 2))):
            for xx in range(pxp - arm // 2, pxp + arm // 2 + thick):
                px[xx, top + off] = P["pole"]
                if i < 2:
                    px[xx, top + off + 1] = P["pole"]
        poles.append((pxp + thick // 2, top, arm))

    # Wires: 4 per pair of neighboring poles, sagging (catenary ~ parabola)
    for (x0, t0, a0), (x1, t1, a1) in zip(poles, poles[1:]):
        for k in range(4):
            side = (k % 2) * 2 - 1
            row = k // 2
            ax, ay = x0 + side * (a0 // 2 - 1), t0 + 4 + row * max(3, 12 - 0)
            bx, by = x1 + side * (a1 // 2 - 1), t1 + 4 + row * max(3, 6)
            sag = (x1 - x0) * 0.12
            for xx in range(min(ax, bx), max(ax, bx) + 1):
                t = (xx - ax) / (bx - ax) if bx != ax else 0
                yy = int(ay + (by - ay) * t + sag * 4 * t * (1 - t))
                if 0 <= yy < H:
                    px[xx, yy] = P["pole"]
    # Wires from the first pole off the image to the left
    x0, t0, a0 = poles[0]
    for k in range(4):
        side = (k % 2) * 2 - 1
        ay = t0 + 4 + (k // 2) * 12
        ax = x0 + side * (a0 // 2 - 1)
        for xx in range(0, ax + 1):
            t = xx / max(1, ax)
            px[xx, int(ay - 10 * (1 - t) + 6 * t * (1 - t))] = P["pole"]

    big = img.resize((W * SCALE, H * SCALE), Image.NEAREST)
    bp = big.load()
    for y in range(0, H * SCALE, SCALE):
        yy = y + SCALE - 1
        for x in range(W * SCALE):
            r, g, b = bp[x, yy]
            bp[x, yy] = (int(r * 0.8), int(g * 0.8), int(b * 0.8))
    return big


if __name__ == "__main__":
    import os

    here = os.path.dirname(os.path.abspath(__file__))
    if len(sys.argv) == 3:
        render(sys.argv[1]).save(sys.argv[2], optimize=True)
    else:
        os.makedirs(os.path.join(here, "wallpapers"), exist_ok=True)
        for ph in PHASES:
            render(ph).save(os.path.join(here, "wallpapers", ph + ".png"), optimize=True)
        render("dusk").save(os.path.join(here, "wallpaper.png"), optimize=True)
    print("ok")
