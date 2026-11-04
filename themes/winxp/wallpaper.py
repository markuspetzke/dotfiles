"""Wallpaper "winxp": eigene Zeichnung einer sanften gruenen Huegellandschaft unter blauem
Himmel mit Schoenwetterwolken (im Stil der XP-Zeit, kein Foto).
  python3 wallpaper.py              -> wallpapers/{day,dusk,night}.png + wallpaper.png (= day)
  python3 wallpaper.py <phase> <out>
Das Original-Foto kann man selbst nach private/wallpaper.jpg legen, es hat dann Vorrang."""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

W, H = 1920, 1080
PHASES = {
    #        Himmel oben,   Himmel Horizont, Huegel hell,   Huegel dunkel, Wolken,         Licht
    "day":   ((24, 86, 200), (160, 205, 244), (132, 200, 66), (46, 122, 26), (255, 255, 255), 1.00),
    "dusk":  ((40, 52, 120), (236, 150, 110), (96, 140, 52), (40, 82, 26), (255, 214, 190), 0.85),
    "night": ((6, 12, 34), (34, 54, 100), (34, 62, 34), (14, 30, 16), (120, 130, 160), 0.55),
}


def lerp(a, b, t):
    return a + (b - a) * t


def render(phase, seed=4):
    top, horizon, hill_hi, hill_lo, cloud_col, light = PHASES[phase]
    rng = np.random.default_rng(seed)
    y = np.linspace(0, 1, H)[:, None]
    x = np.linspace(0, 1, W)[None, :]

    # Himmel: Verlauf von tiefblau oben zu hell am Horizont
    t = np.clip(y / 0.75, 0, 1) ** 1.3
    sky = np.stack([lerp(top[i], horizon[i], t) * np.ones_like(x) for i in range(3)], -1)

    # Wolken: weiche, weiss aufgehellte Flecken (Ellipsen + Weichzeichner)
    clouds = Image.new("L", (W, H), 0)
    px = clouds.load()
    for _ in range(16):
        cx, cy = rng.uniform(0, W), rng.uniform(H * 0.04, H * 0.38)
        rx, ry = rng.uniform(50, 170), rng.uniform(14, 36)
        for _ in range(7):  # mehrere Kugeln je Wolke -> Haufenwolke
            ox, oy = rng.normal(0, rx * 0.5), rng.normal(0, ry * 0.4)
            r = rng.uniform(0.4, 0.9)
            x0, x1 = int(cx + ox - rx * r), int(cx + ox + rx * r)
            y0, y1 = int(cy + oy - ry * r), int(cy + oy + ry * r)
            for yy in range(max(0, y0), min(H, y1)):
                for xx in range(max(0, x0), min(W, x1), 2):
                    dx = (xx - cx - ox) / (rx * r)
                    dy = (yy - cy - oy) / (ry * r)
                    if dx * dx + dy * dy <= 1:
                        px[xx, yy] = min(255, px[xx, yy] + 70)
                        if xx + 1 < W:
                            px[xx + 1, yy] = px[xx, yy]
    clouds = np.asarray(clouds.filter(ImageFilter.GaussianBlur(11)), dtype=np.float32)[..., None] / 255.0
    sky = sky * (1 - clouds * 0.9) + np.array(cloud_col) * clouds * 0.9

    # Huegel: weiche Kurven, vorne heller Hang, hinten ein zweiter, etwas dunklerer
    def ridge(base, amp, freq, phase_):
        return base - amp * np.sin(x * np.pi * freq + phase_) - amp * 0.35 * np.sin(x * np.pi * freq * 2.3 + 1.7)

    img = sky.copy()
    hills = (
        # hinterer, flacher Huegel rechts
        lambda: 0.70 - 0.07 * np.exp(-((x - 0.82) / 0.30) ** 2),
        # vorderer Huegel: runde Kuppe links der Mitte, sanft nach rechts abfallend
        lambda: 0.74 - 0.22 * np.exp(-((x - 0.36) / 0.36) ** 2) - 0.02 * np.sin(x * np.pi * 3.1),
    )
    for edge_fn, shade in zip(hills, (0.8, 1.0)):
        edge = edge_fn()
        mask = (y >= edge).astype(np.float32)
        depth = np.clip((y - edge) / 0.35, 0, 1)
        lit = 1 - np.clip((x - 0.2) * 0.6, 0, 0.45)  # Licht von links oben
        col = np.stack([lerp(hill_hi[i], hill_lo[i], depth) * lit * shade for i in range(3)], -1)
        noise = rng.normal(0, 4, (H, W, 1))  # leichte Grasstruktur
        col = col + noise
        img = img * (1 - mask[..., None]) + col * mask[..., None]

    # Nacht: ein paar Sterne
    if phase == "night":
        for _ in range(180):
            sx, sy = rng.integers(0, W), rng.integers(0, int(H * 0.45))
            img[sy, sx] = (220, 225, 240)

    img = np.clip(img * light, 0, 255).astype(np.uint8)
    return Image.fromarray(img).filter(ImageFilter.GaussianBlur(0.6))


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
