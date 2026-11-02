"""Pixel-Art-Wallpaper "retro-horizon" in der Bernstein-CRT-Palette.
Rendert 480x270 und skaliert 4x (nearest) auf 1920x1080."""
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


img = Image.new("RGB", (W, H))
px = img.load()
rng = random.Random(7)
sun_cx, sun_cy, sun_r = W // 2, HORIZON, 64

# Himmel
sky = [P["void"], P["bg_dark"], P["bg"], P["surface"], P["warm"], P["glow"]]
for y in range(HORIZON):
    for x in range(W):
        t = (y / HORIZON) ** 1.6
        # Leichter Lichthof um die Sonne
        d = math.hypot(x - sun_cx, (y - sun_cy) * 1.4)
        t += max(0.0, 0.35 - d / 520)
        px[x, y] = ramp(x, y, t, sky)

# Sterne (nur oberes Drittel)
for _ in range(70):
    x, y = rng.randrange(W), rng.randrange(int(HORIZON * 0.45))
    px[x, y] = P["cream"] if rng.random() < 0.25 else P["muted"]

# Sonne mit Streifen, die nach unten breiter werden
for y in range(sun_cy - sun_r + 1, sun_cy):
    rel = (y - (sun_cy - sun_r)) / sun_r  # 0 oben, 1 unten
    band = int(rel * 22)
    gap = rel > 0.45 and (y % 7) < int((rel - 0.45) * 9)
    if gap:
        continue
    half = int(math.sqrt(max(0, sun_r**2 - (sun_cy - y) ** 2)))
    for x in range(sun_cx - half, sun_cx + half + 1):
        px[x, y] = ramp(x, y, rel, [P["amber_hi"], P["amber"], P["orange"], P["red"]])

# Berge: hintere Kette (Flaeche), vordere Kette (Oliv-dunkel)
for x in range(W):
    far = int(ridge(x, 1.3, HORIZON - 22, 12, [0.013, 0.031, 0.077]))
    near = int(ridge(x, 4.1, HORIZON - 6, 9, [0.021, 0.05, 0.11]))
    for y in range(max(0, far), HORIZON):
        px[x, y] = dither(x, y, 0.3, P["surface"], P["bg"])
    for y in range(max(0, near), HORIZON):
        px[x, y] = dither(x, y, 0.25, P["olive_dk"], P["olive"])

# Boden mit Sonnen-Spiegelung
for y in range(HORIZON, H):
    depth = (y - HORIZON) / (H - HORIZON)
    for x in range(W):
        px[x, y] = ramp(x, y, 1 - depth, [P["void"], P["bg_dark"], P["bg"]])
    # Spiegelungsstreifen: duenne Linien, enger am Horizont
    if (y - HORIZON) % max(2, int(3 + depth * 9)) == 0:
        half = int(sun_r * (0.9 - depth * 0.6) * (0.7 + 0.3 * math.sin(y * 0.9)))
        for x in range(sun_cx - half, sun_cx + half + 1):
            fade = 1 - abs(x - sun_cx) / max(1, half)
            if fade * (1 - depth) * 16 > BAYER[y % 4][x % 4]:
                px[x, y] = P["amber"] if depth < 0.25 else P["orange"]

# Horizontlinie
for x in range(W):
    px[x, HORIZON] = dither(x, HORIZON, 0.5, P["olive"], P["amber"]) if abs(x - sun_cx) < sun_r else P["olive_dk"]

# Scanlines: jede 2. Zeile minimal abdunkeln (nach dem Hochskalieren)
big = img.resize((W * SCALE, H * SCALE), Image.NEAREST)
bp = big.load()
for y in range(0, H * SCALE, SCALE):
    yy = y + SCALE - 1
    for x in range(W * SCALE):
        r, g, b = bp[x, yy]
        bp[x, yy] = (int(r * 0.82), int(g * 0.82), int(b * 0.82))

big.save(sys.argv[1], optimize=True)
print("ok", big.size)
