"""Pixel wallpaper "win31-desktop": teal desktop with an own, subtle diamond pattern.
Renders 480x270 (16px tile), scaled 4x (nearest) to 1920x1080.
  python3 wallpaper.py          -> wallpaper.png
  python3 wallpaper.py <out>"""
import os
import sys

from PIL import Image

W, H, SCALE = 480, 270, 4
TEAL = (0x00, 0x80, 0x80)
DARK = (0x00, 0x6a, 0x6a)
LIGHT = (0x1a, 0x94, 0x94)

# 16x16 tile: a diamond of (dark) dots with a light center, teal otherwise
TILE = 16
img = Image.new("RGB", (W, H), TEAL)
px = img.load()
for y in range(H):
    for x in range(W):
        tx, ty = x % TILE, y % TILE
        d = abs(tx - 8) + abs(ty - 8)
        if d == 6 and (tx + ty) % 2 == 0:
            px[x, y] = DARK
        elif d == 0:
            px[x, y] = LIGHT
        elif d == 3 and tx in (8, 5, 11) and ty in (8, 5, 11):
            px[x, y] = LIGHT

out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "wallpaper.png")
img.resize((W * SCALE, H * SCALE), Image.NEAREST).save(out, optimize=True)
print("ok")
