"""Pixel-Art-Wallpaper "retro-horizon" in der Bernstein-CRT-Palette, je Tageszeit.
  python3 wallpaper.py              -> wallpapers/{morning,noon,evening,night}.png + wallpaper.png (= evening)
  python3 wallpaper.py <phase> <out>
Rendert 480x270 und skaliert 4x (nearest) auf 1920x1080. Welche Phase wann gilt:
wallpaper-phases (bin/theme-wallpaper)."""
import math
import random
import sys

from PIL import Image

W, H, SCALE = 480, 270, 4
HORIZON = 182


def hx(c):
    return tuple(int(c[i : i + 2], 16) for i in (1, 3, 5))


P = {k: hx(v) for k, v in {
    "void": "#100f0c",
    "bg_dark": "#141310",
    "bg": "#1b1a16",
    "surface": "#2a2822",
    "warm": "#3a2c1a",
    "glow": "#5a3a1c",
    "amber": "#e8a33d",
    "amber_hi": "#f2bb5c",
    "orange": "#d97a3a",
    "red": "#c8553d",
    "olive_dk": "#2f3122",
    "olive": "#4a4f33",
    "cream": "#e6dcc3",
    "muted": "#8a8370",
}.items()}

BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def dither(x, y, t, a, b):
    """t in [0,1]: Anteil von b, per 4x4-Bayer-Matrix."""
    return b if t * 16 > BAYER[y % 4][x % 4] + 0.5 else a


def ramp(x, y, t, stops):
    """Mehrstufiger Verlauf ueber Farbliste, zwischen Nachbarn gedithert."""
    t = min(max(t, 0.0), 0.9999)
    seg = t * (len(stops) - 1)
    i = int(seg)
    return dither(x, y, seg - i, stops[i], stops[i + 1])


def ridge(x, seed, base, amp, freqs):
    v = 0.0
    for k, f in enumerate(freqs):
        v += math.sin(x * f + seed * (k + 1) * 1.7) / (k + 1)
    return base - amp * v



PHASES = {
    # Sonne (Mitte x, Mitte y, Radius) oder None; Himmel-Verschiebung; Sterne
    "morning": dict(sun=(int(W * 0.28), HORIZON + 6, 46), sky_shift=0.10, stars=12, moon=None),
    "noon": dict(sun=(int(W * 0.62), HORIZON - 96, 30), sky_shift=0.22, stars=0, moon=None),
    "evening": dict(sun=(W // 2, HORIZON, 64), sky_shift=0.0, stars=70, moon=None),
    "night": dict(sun=None, sky_shift=-0.25, stars=170, moon=(int(W * 0.78), 46, 12)),
}


def render(phase):
    cfg = PHASES[phase]
    img = Image.new("RGB", (W, H))
    px = img.load()
    rng = random.Random(7)
    sun = cfg["sun"]
    glow_x, glow_y = (sun[0], sun[1]) if sun else (cfg["moon"][0], cfg["moon"][1])
    glow_amt = 0.35 if sun else 0.12

    # Himmel
    sky = [P["void"], P["bg_dark"], P["bg"], P["surface"], P["warm"], P["glow"]]
    for y in range(HORIZON):
        for x in range(W):
            t = (y / HORIZON) ** 1.6 + cfg["sky_shift"]
            d = math.hypot(x - glow_x, (y - glow_y) * 1.4)
            t += max(0.0, glow_amt - d / 520)
            px[x, y] = ramp(x, y, t, sky)

    # Sterne
    for _ in range(cfg["stars"]):
        x, y = rng.randrange(W), rng.randrange(int(HORIZON * (0.65 if phase == "night" else 0.45)))
        px[x, y] = P["cream"] if rng.random() < 0.25 else P["muted"]

    # Sonne: Kreis bis zum Horizont, Streifen in der unteren Haelfte
    if sun:
        cx, cy, r = sun
        for y in range(cy - r + 1, min(cy + r, HORIZON)):
            rel = (y - (cy - r)) / (2 * r if cy + r <= HORIZON else r)
            gap = rel > 0.45 and (y % 7) < int((rel - 0.45) * 9)
            if gap:
                continue
            half = int(math.sqrt(max(0, r**2 - (cy - y) ** 2)))
            for x in range(cx - half, cx + half + 1):
                px[x, y] = ramp(x, y, rel, [P["amber_hi"], P["amber"], P["orange"], P["red"]])

    # Mond (Sichel): Kreis minus versetzter Kreis
    if cfg["moon"]:
        mx, my, mr = cfg["moon"]
        for y in range(my - mr, my + mr + 1):
            for x in range(mx - mr, mx + mr + 1):
                if (x - mx) ** 2 + (y - my) ** 2 <= mr * mr and (x - mx - 5) ** 2 + (y - my + 2) ** 2 > (mr - 1) ** 2:
                    px[x, y] = dither(x, y, 0.2, P["cream"], P["muted"])

    # Berge: hintere Kette (Flaeche), vordere Kette (Oliv-dunkel)
    for x in range(W):
        far = int(ridge(x, 1.3, HORIZON - 22, 12, [0.013, 0.031, 0.077]))
        near = int(ridge(x, 4.1, HORIZON - 6, 9, [0.021, 0.05, 0.11]))
        for y in range(max(0, far), HORIZON):
            px[x, y] = dither(x, y, 0.3, P["surface"], P["bg"])
        for y in range(max(0, near), HORIZON):
            px[x, y] = dither(x, y, 0.25, P["olive_dk"], P["olive"])

    # Boden mit Spiegelung von Sonne bzw. Mond
    refl_x = sun[0] if sun else cfg["moon"][0]
    refl_r = (sun[2] if sun else 18) * (1.0 if sun and sun[1] >= HORIZON - 20 else 0.6)
    refl_cols = (P["amber"], P["orange"]) if sun else (P["muted"], P["surface"])
    for y in range(HORIZON, H):
        depth = (y - HORIZON) / (H - HORIZON)
        for x in range(W):
            px[x, y] = ramp(x, y, 1 - depth, [P["void"], P["bg_dark"], P["bg"]])
        if (y - HORIZON) % max(2, int(3 + depth * 9)) == 0:
            half = int(refl_r * (0.9 - depth * 0.6) * (0.7 + 0.3 * math.sin(y * 0.9)))
            for x in range(max(0, refl_x - half), min(W, refl_x + half + 1)):
                fade = 1 - abs(x - refl_x) / max(1, half)
                if fade * (1 - depth) * 16 > BAYER[y % 4][x % 4]:
                    px[x, y] = refl_cols[0] if depth < 0.25 else refl_cols[1]

    # Horizontlinie
    for x in range(W):
        near_sun = sun and sun[1] >= HORIZON - 20 and abs(x - sun[0]) < sun[2]
        px[x, HORIZON] = dither(x, HORIZON, 0.5, P["olive"], P["amber"]) if near_sun else P["olive_dk"]

    # Scanlines: jede 4. Zeile minimal abdunkeln (nach dem Hochskalieren)
    big = img.resize((W * SCALE, H * SCALE), Image.NEAREST)
    bp = big.load()
    for y in range(0, H * SCALE, SCALE):
        yy = y + SCALE - 1
        for x in range(W * SCALE):
            r, g, b = bp[x, yy]
            bp[x, yy] = (int(r * 0.82), int(g * 0.82), int(b * 0.82))
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
        render("evening").save(os.path.join(here, "wallpaper.png"), optimize=True)
    print("ok")
