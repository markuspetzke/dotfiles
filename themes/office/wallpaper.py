"""Pixel-Wallpaper "office": Grossraumbuero (Rasterdecke, Neonroehre, Fenster mit Jalousien,
Trennwand mit Post-its, Schreibtisch mit Kaffeetasse), eigene Zeichnung, je Tageszeit.
  python3 wallpaper.py              -> wallpapers/{day,evening,night}.png + wallpaper.png (= day)
  python3 wallpaper.py <phase> <out>
Rendert 480x270, skaliert 4x (nearest) auf 1920x1080."""
import os
import random
import sys

from PIL import Image

W, H, SCALE = 480, 270, 4
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def hx(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


def dither(x, y, t, a, b):
    return b if t * 16 > BAYER[y % 4][x % 4] + 0.5 else a


def ramp(x, y, t, stops):
    t = min(max(t, 0.0), 0.9999)
    seg = t * (len(stops) - 1)
    i = int(seg)
    return dither(x, y, seg - i, stops[i], stops[i + 1])


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c)


# 3x5-Pixelschrift fuer Schilder und die Tasse ('#' = Pixel)
FONT = {
    "A": ["###", "# #", "###", "# #", "# #"], "B": ["## ", "# #", "## ", "# #", "## "],
    "C": ["###", "#  ", "#  ", "#  ", "###"], "D": ["## ", "# #", "# #", "# #", "## "],
    "E": ["###", "#  ", "## ", "#  ", "###"], "F": ["###", "#  ", "## ", "#  ", "#  "],
    "I": ["###", " # ", " # ", " # ", "###"], "L": ["#  ", "#  ", "#  ", "#  ", "###"],
    "M": ["#   #", "## ##", "# # #", "#   #", "#   #"], "N": ["#   #", "##  #", "# # #", "#  ##", "#   #"],
    "O": ["###", "# #", "# #", "# #", "###"], "P": ["###", "# #", "###", "#  ", "#  "],
    "R": ["## ", "# #", "## ", "# #", "# #"], "S": ["###", "#  ", "###", "  #", "###"],
    "T": ["###", " # ", " # ", " # ", " # "], "U": ["# #", "# #", "# #", "# #", "###"],
    "W": ["#   #", "#   #", "# # #", "## ##", "#   #"], "'": [" # ", " # ", "   ", "   ", "   "],
    " ": ["   ", "   ", "   ", "   ", "   "], ".": ["   ", "   ", "   ", "   ", " # "],
}


def text_width(text, scale=1):
    """Breite in Pixeln: Glyphenbreite + 1 Pixel Abstand (M, N, W sind 5 breit)."""
    return sum(len(FONT.get(ch, FONT[" "])[0]) + 1 for ch in text) * scale - scale


PHASES = {
    "day": dict(sky=["#6f93b5", "#86a6c2", "#a6bccf"], light=0.62, warm=0.0, lamp=1.0, city=False),
    "evening": dict(sky=["#2c375c", "#94506a", "#b87a48", "#c99a5e"], light=0.52, warm=0.35, lamp=1.0, city=False),
    "night": dict(sky=["#0a0e1a", "#151d31", "#1f2842"], light=0.38, warm=0.0, lamp=1.15, city=True),
}


def render(phase):
    cfg = PHASES[phase]
    L = cfg["light"]
    sky = [hx(c) for c in cfg["sky"]]
    rng = random.Random(11)
    img = Image.new("RGB", (W, H))
    px = img.load()

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            px[x, y] = c

    def rect(x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                px[x, y] = c

    wall = shade(hx("#d9cfb8"), L)
    wall_dk = shade(hx("#c9bea4"), L)
    # Wand mit leichter Struktur
    for y in range(40, 200):
        for x in range(W):
            px[x, y] = dither(x, y, 0.15, wall, wall_dk)

    rect(0, 200, W, 206, shade(hx("#b8ad94"), L))  # Fussleiste

    # Rasterdecke
    tile, grid = shade(hx("#e8e4da"), L), shade(hx("#c8c0ae"), L)
    for y in range(0, 40):
        for x in range(W):
            px[x, y] = grid if (x % 40 == 0 or y % 20 == 0) else dither(x, y, 0.1, tile, shade(tile, 0.96))
    # Neonroehren-Panel (leuchtet nachts staerker)
    lamp = shade(hx("#fdfbf0"), min(1.0, L * cfg["lamp"]))
    rect(161, 4, 280, 18, lamp)
    for x in range(161, 280, 6):
        for y in range(4, 18):
            put(x, y, shade(lamp, 0.93))
    if phase == "night":  # Lichtkegel an Wand/Decke
        for y in range(18, 120):
            spread = (y - 18) * 0.9
            for x in range(int(220 - 60 - spread), int(220 + 60 + spread)):
                if 0 <= x < W and 40 <= y < 200:
                    t = 1 - (y - 18) / 102
                    if t * 6 > BAYER[y % 4][x % 4]:
                        px[x, y] = shade(px[x, y], 1.25)

    # Fenster mit Jalousie
    fx0, fy0, fx1, fy1 = 300, 52, 452, 158
    rect(fx0 - 3, fy0 - 3, fx1 + 3, fy1 + 3, shade(hx("#f0ece2"), L))  # Rahmen
    for y in range(fy0, fy1):
        for x in range(fx0, fx1):
            px[x, y] = ramp(x, y, (y - fy0) / (fy1 - fy0), sky)
    if cfg["city"]:  # Buerohaus gegenueber mit einzelnen Lichtern
        rect(fx0 + 10, fy0 + 40, fx0 + 70, fy1, hx("#141a2c"))
        rect(fx0 + 85, fy0 + 25, fx0 + 140, fy1, hx("#10162a"))
        for _ in range(26):
            x = rng.choice([rng.randrange(fx0 + 12, fx0 + 68), rng.randrange(fx0 + 87, fx0 + 138)])
            y = rng.randrange(fy0 + 30, fy1 - 4)
            rect(x, y, x + 2, y + 2, hx("#e8d38a") if rng.random() < 0.8 else hx("#a9c7e0"))
    slat = shade(hx("#ece6d6"), max(L, 0.7))
    slat_dk = shade(slat, 0.85)
    for y in range(fy0, fy1):
        k = (y - fy0) % 7
        if k < 4:
            for x in range(fx0, fx1):
                px[x, y] = slat if k < 3 else slat_dk
    for x in (fx0 + 40, fx1 - 40):  # Schnuere
        for y in range(fy0, fy1):
            put(x, y, shade(slat, 0.7))
    # Lichtstreifen durch die Jalousie auf die Wand (Tag/Abend)
    if phase != "night":
        stripe = (1.12, 1.12, 1.05) if phase == "day" else (1.25, 1.05, 0.85)
        for y in range(60, 196):
            if (y - 60) % 14 < 6:
                x0 = 60 + (y - 60) // 2
                for x in range(x0, x0 + 160):
                    c = px[x, y]
                    px[x, y] = tuple(min(255, int(v * f)) for v, f in zip(c, stripe))

    def text(x, y, msg, col, scale=1):
        cx = 0
        for ch in msg:
            glyph = FONT.get(ch, FONT[" "])
            for r, row in enumerate(glyph):
                for c, p in enumerate(row):
                    if p == "#":
                        rect(x + (cx + c) * scale, y + r * scale, x + (cx + c + 1) * scale, y + (r + 1) * scale, col)
            cx += len(glyph[0]) + 1

    # Firmenschild an der Wand (nur Text, kein Logo)
    sx, sy, sw, sh = 66, 60, 150, 34
    rect(sx + 2, sy + 2, sx + sw + 2, sy + sh + 2, shade(hx("#9c927a"), L))  # Schatten
    rect(sx, sy, sx + sw, sy + sh, shade(hx("#f0ece2"), L))
    rect(sx, sy, sx + sw, sy + 3, shade(hx("#2f5b9a"), L))
    t1, t2 = "DUNDER MIFFLIN", "SCRANTON"
    text(sx + (sw - text_width(t1, 2)) // 2, sy + 8, t1, shade(hx("#2b2b2b"), L), 2)
    text(sx + (sw - text_width(t2)) // 2, sy + 23, t2, shade(hx("#2f5b9a"), L))

    # Trennwand (Stoff) mit Post-its
    fab, fab_dk = shade(hx("#7d8a9a"), L), shade(hx("#6c7888"), L)
    for y in range(110, 212):
        for x in range(16, 286):
            px[x, y] = dither(x, y, 0.45, fab, fab_dk)
    rect(14, 106, 288, 111, shade(hx("#b0b6bd"), L))  # Abdeckleiste
    rect(14, 106, 17, 212, shade(hx("#b0b6bd"), L))
    rect(285, 106, 288, 212, shade(hx("#b0b6bd"), L))
    notes = [("#f2d64b", 40, 125), ("#f2d64b", 62, 131), ("#f2a7b8", 98, 122), ("#a8d0e6", 140, 128),
             ("#f2d64b", 175, 120), ("#b8e0a0", 205, 134), ("#f2d64b", 236, 124), ("#f2a7b8", 60, 160),
             ("#f2d64b", 120, 165), ("#a8d0e6", 214, 168)]
    for col, x, y in notes:
        c = shade(hx(col), L)
        rect(x + 1, y + 1, x + 17, y + 17, shade(fab_dk, 0.7))  # Schatten
        rect(x, y, x + 16, y + 16, c)
        rect(x, y, x + 16, y + 3, shade(c, 0.9))
        for ly in (y + 6, y + 9, y + 12):  # Gekritzel
            lx = x + 2
            while lx < x + rng.randint(9, 14):
                put(lx, ly, shade(hx("#3a3a3a"), L))
                lx += rng.choice((1, 1, 2))
    # Reisszwecke
    for col, x, y in notes:
        put(x + 8, y + 1, shade(hx("#c0392b"), L))

    # Schreibtisch
    top, edge = shade(hx("#c9b48a"), L), shade(hx("#a8946a"), L)
    for y in range(206, H):
        for x in range(W):
            px[x, y] = dither(x, y, 0.2, top, shade(top, 0.95)) if y < 262 else edge
    # Papierstapel
    for i in range(6):
        rect(390 - i, 214 - i * 2, 446 - i, 238 - i * 2, shade(hx("#fbf9f2") if i % 2 else hx("#f0ece2"), L))
    rect(395, 205, 437, 207, shade(hx("#c9c2b0"), L))
    # Tasse "WORLD'S BEST BOSS" (weiss, schwarze Schrift), Dampf am Tag
    mug, ink = shade(hx("#f6f3ea"), L), shade(hx("#1f1f1f"), L)
    rect(322, 204, 356, 246, mug)
    rect(356, 212, 363, 236, mug)
    rect(358, 216, 361, 232, top)
    rect(324, 204, 354, 207, shade(hx("#5a3a24"), L))  # Kaffee
    for i, word in enumerate(("WORLD'S", "BEST", "BOSS")):
        text(323 + (33 - text_width(word)) // 2, 212 + i * 8, word, ink)
    if phase != "night":
        for y in range(186, 202):
            put(332 + (2 if (y // 3) % 2 else 0), y, shade(hx("#e6e1d6"), L))
            put(344 + (0 if (y // 3) % 2 else 2), y + 2, shade(hx("#e6e1d6"), L))

    # Dundie: kleiner goldener Pokal auf schwarzem Sockel
    gold, gold_dk = shade(hx("#d9b04a"), L), shade(hx("#a8842e"), L)
    rect(296, 238, 314, 246, shade(hx("#1f1f1f"), L))
    rect(298, 236, 312, 238, shade(hx("#2e2e2e"), L))
    rect(303, 224, 307, 236, gold)  # Saeule/Koerper
    rect(304, 218, 306, 222, gold)  # Kopf
    rect(299, 222, 303, 224, gold_dk)  # Arme hoch
    rect(307, 222, 311, 224, gold_dk)
    rect(299, 218, 301, 222, gold_dk)
    rect(309, 218, 311, 222, gold_dk)

    # Tacker im Wackelpudding
    jello, jello_hi = shade(hx("#e8b84a"), L), shade(hx("#f4d27a"), L)
    rect(40, 222, 104, 246, jello)
    for y in range(222, 246):
        for x in range(40, 104):
            if (x + y) % 9 == 0 or y < 225:
                px[x, y] = jello_hi
    rect(52, 232, 92, 238, shade(hx("#3a3a3a"), L))  # Tacker
    rect(52, 228, 86, 232, shade(hx("#555555"), L))
    rect(40, 246, 104, 248, shade(hx("#c9a23e"), L))
    # Tastatur
    rect(150, 236, 290, 252, shade(hx("#e2dccb"), L))
    for x in range(154, 286, 7):
        for y in (239, 244, 248):
            rect(x, y, x + 5, y + 3, shade(hx("#f6f3ea"), L))
    if phase == "night":  # Bildschirmschein auf der Tastatur
        for y in range(230, 256):
            for x in range(140, 300):
                if BAYER[y % 4][x % 4] < 5:
                    px[x, y] = shade(px[x, y], 1.2)

    return img.resize((W * SCALE, H * SCALE), Image.NEAREST)


if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    if len(sys.argv) == 3:
        render(sys.argv[1]).save(sys.argv[2], optimize=True)
    else:
        os.makedirs(os.path.join(here, "wallpapers"), exist_ok=True)
        for ph in PHASES:
            render(ph).save(os.path.join(here, "wallpapers", ph + ".png"), optimize=True)
        render("day").save(os.path.join(here, "wallpaper.png"), optimize=True)
    print("ok")
