"""Pixel-Wallpaper "win31-desktop": Teal-Desktop mit eigenem, dezentem Rautenmuster.
Rendert 480x270 (16px-Kachel), skaliert 4x (nearest) auf 1920x1080."""
import sys

from PIL import Image

W, H, SCALE = 480, 270, 4
TEAL = (0x00, 0x80, 0x80)
DARK = (0x00, 0x6a, 0x6a)
LIGHT = (0x1a, 0x94, 0x94)

# 16x16-Kachel: Raute aus Punkten (dunkel) mit hellem Mittelpunkt, Rest Teal
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

img.resize((W * SCALE, H * SCALE), Image.NEAREST).save(sys.argv[1], optimize=True)
print("ok")
