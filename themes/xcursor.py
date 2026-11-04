"""Minimal Xcursor writer for the themes' pixel art pointers (without xcursorgen).

build(name, art, palette, hotspot, out_dir, inherits)
    art:     list of equally long strings, one char = one pixel ('.' = transparent)
    palette: char -> (r, g, b)
    hotspot: (x, y) in pixels of the 1x image
Creates <out_dir>/<name>/index.theme and cursors/left_ptr (+ aliases) at 24/48 px.
The theme inherits all other pointers from `inherits`."""
import os
import struct

ALIASES = ["default", "arrow", "top_left_arrow"]
SIZES = [(24, 1), (48, 2)]  # nominal size, scaling of the 1x image


def _image(art, palette, scale, nominal):
    h, w = len(art), len(art[0])
    W = H = nominal
    px = [0] * (W * H)
    for y in range(h):
        for x in range(w):
            ch = art[y][x]
            if ch == ".":
                continue
            r, g, b = palette[ch]
            argb = (0xFF << 24) | (r << 16) | (g << 8) | b
            for dy in range(scale):
                for dx in range(scale):
                    X, Y = x * scale + dx, y * scale + dy
                    if X < W and Y < H:
                        px[Y * W + X] = argb
    return W, H, px


def build(name, art, palette, hotspot, out_dir, inherits):
    images = []
    for nominal, scale in SIZES:
        W, H, px = _image(art, palette, scale, nominal)
        chunk = struct.pack("<9I", 36, 0xFFFD0002, nominal, 1, W, H,
                            hotspot[0] * scale, hotspot[1] * scale, 0)
        chunk += struct.pack(f"<{len(px)}I", *px)
        images.append((nominal, chunk))

    ntoc = len(images)
    header = struct.pack("<4sIII", b"Xcur", 16, 0x10000, ntoc)
    pos = 16 + ntoc * 12
    toc, body = b"", b""
    for nominal, chunk in images:
        toc += struct.pack("<III", 0xFFFD0002, nominal, pos)
        pos += len(chunk)
        body += chunk

    root = os.path.join(out_dir, name)
    cur = os.path.join(root, "cursors")
    os.makedirs(cur, exist_ok=True)
    with open(os.path.join(cur, "left_ptr"), "wb") as f:
        f.write(header + toc + body)
    for alias in ALIASES:
        link = os.path.join(cur, alias)
        if os.path.lexists(link):
            os.remove(link)
        os.symlink("left_ptr", link)
    with open(os.path.join(root, "index.theme"), "w") as f:
        f.write(f"[Icon Theme]\nName={name}\nComment=Pixel pointer from ~/.config/themes\nInherits={inherits}\n")
    return root
