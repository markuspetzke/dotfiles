"""XP style icons for the start menu (own drawings) -> icons/<name>.png at 64 px.
Drawn at 4x size and scaled down (smooth edges). python3 icons.py"""
import math
import os

from PIL import Image, ImageDraw

S = 256  # drawing size, output 64 px
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "icons")


def grad(draw, box, top, bottom, radius=0):
    x0, y0, x1, y1 = box
    h = max(1, y1 - y0)
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle(box, radius, fill=255)
    layer = Image.new("RGBA", (S, S))
    ld = ImageDraw.Draw(layer)
    for y in range(y0, y1 + 1):
        t = (y - y0) / h
        ld.line([(x0, y), (x1, y)], fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)) + (255,))
    draw._image.paste(layer, (0, 0), mask)


def new():
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def save(im, name):
    os.makedirs(OUT, exist_ok=True)
    im.resize((64, 64), Image.LANCZOS).save(os.path.join(OUT, name + ".png"))


def folder(extra=None):
    im, d = new()
    d.rounded_rectangle((28, 56, 120, 96), 14, fill=(214, 160, 40, 255))           # tab
    grad(d, (24, 76, 232, 216), (250, 214, 110), (222, 162, 40), 18)                  # back
    if extra:
        extra(im, d)
    grad(d, (24, 112, 232, 222), (255, 230, 140), (236, 180, 56), 18)                  # front
    d.rounded_rectangle((24, 112, 232, 222), 18, outline=(170, 118, 20, 255), width=6)
    d.line([(40, 122), (216, 122)], fill=(255, 246, 200, 255), width=6)               # shine
    return im


def doc_sheet(im, d):
    d.rectangle((70, 40, 190, 150), fill=(255, 255, 255, 255), outline=(150, 150, 150, 255), width=4)
    for y in range(62, 140, 18):
        d.line([(86, y), (174, y)], fill=(120, 150, 210, 255), width=6)


def pic_sheet(im, d):
    d.rectangle((70, 40, 190, 150), fill=(255, 255, 255, 255), outline=(150, 150, 150, 255), width=4)
    grad(d, (82, 52, 178, 138), (90, 160, 240), (180, 220, 255))
    d.polygon([(82, 138), (120, 96), (150, 120), (178, 100), (178, 138)], fill=(70, 160, 60, 255))
    d.ellipse((150, 62, 168, 80), fill=(255, 220, 60, 255))


def music_sheet(im, d):
    d.rectangle((70, 40, 190, 150), fill=(255, 255, 255, 255), outline=(150, 150, 150, 255), width=4)
    d.line([(150, 60), (150, 122)], fill=(40, 60, 140, 255), width=10)
    d.line([(150, 60), (176, 72)], fill=(40, 60, 140, 255), width=10)
    d.ellipse((116, 112, 154, 140), fill=(40, 60, 140, 255))


def computer():
    im, d = new()
    grad(d, (30, 30, 226, 176), (235, 235, 230), (190, 190, 182), 14)                 # case
    d.rounded_rectangle((30, 30, 226, 176), 14, outline=(120, 120, 112, 255), width=6)
    grad(d, (50, 48, 206, 156), (60, 130, 240), (20, 70, 190), 6)                      # screen
    d.polygon([(50, 130), (110, 96), (160, 120), (206, 104), (206, 156), (50, 156)], fill=(80, 170, 70, 255))
    grad(d, (96, 178, 160, 206), (200, 200, 192), (160, 160, 152))                     # stand
    grad(d, (60, 204, 196, 224), (220, 220, 212), (170, 170, 162), 8)
    return im


def control_panel():
    im, d = new()
    grad(d, (34, 40, 222, 216), (250, 250, 245), (210, 214, 224), 14)
    d.rounded_rectangle((34, 40, 222, 216), 14, outline=(110, 120, 150, 255), width=6)
    for i, (x, y, c) in enumerate(((70, 90, (220, 60, 50)), (128, 140, (50, 150, 60)), (186, 110, (40, 100, 210)))):
        d.line([(x, 66), (x, 192)], fill=(140, 140, 150, 255), width=8)
        d.rounded_rectangle((x - 22, y - 14, x + 22, y + 14), 6, fill=c + (255,), outline=(60, 60, 60, 255), width=4)
    return im


def magnifier():
    im, d = new()
    d.line([(150, 150), (220, 220)], fill=(120, 80, 40, 255), width=34)
    d.ellipse((30, 30, 170, 170), fill=(200, 230, 255, 255), outline=(60, 80, 120, 255), width=16)
    d.arc((56, 56, 144, 144), 200, 280, fill=(255, 255, 255, 255), width=10)
    return im


def run():
    im, d = new()
    grad(d, (30, 50, 226, 210), (255, 255, 255), (220, 228, 240), 10)
    d.rounded_rectangle((30, 50, 226, 210), 10, outline=(60, 90, 160, 255), width=6)
    grad(d, (30, 50, 226, 84), (60, 130, 240), (20, 80, 200), 10)
    d.polygon([(80, 120), (150, 120), (150, 104), (190, 140), (150, 176), (150, 160), (80, 160)], fill=(50, 160, 60, 255))
    return im


def volume():
    im, d = new()
    d.polygon([(40, 100), (90, 100), (140, 50), (140, 206), (90, 156), (40, 156)], fill=(90, 110, 140, 255), outline=(50, 60, 80, 255))
    for r in (40, 70):
        d.arc((140 - r, 128 - r, 140 + r, 128 + r), -50, 50, fill=(40, 100, 210, 255), width=12)
    return im


def square_button(top, bottom, symbol):
    im, d = new()
    grad(d, (20, 20, 236, 236), top, bottom, 40)
    d.rounded_rectangle((20, 20, 236, 236), 40, outline=(255, 255, 255, 255), width=10)
    d.ellipse((50, 30, 206, 110), fill=(255, 255, 255, 60))  # shine
    symbol(d)
    return im


def key_symbol(d):
    d.ellipse((60, 70, 130, 140), outline=(255, 255, 255, 255), width=18)
    d.line([(124, 124), (200, 190)], fill=(255, 255, 255, 255), width=18)
    d.line([(168, 162), (186, 144)], fill=(255, 255, 255, 255), width=16)


def power_symbol(d):
    d.arc((64, 70, 192, 198), -60, 240, fill=(255, 255, 255, 255), width=20)
    d.line([(128, 50), (128, 130)], fill=(255, 255, 255, 255), width=20)


def standby_symbol(d):
    d.ellipse((70, 70, 186, 186), fill=(255, 255, 255, 255))
    d.ellipse((100, 54, 206, 160), fill=(240, 180, 40, 255))


def restart_symbol(d):
    d.arc((64, 64, 192, 192), 40, 330, fill=(255, 255, 255, 255), width=20)
    d.polygon([(180, 58), (206, 110), (152, 104)], fill=(255, 255, 255, 255))


if __name__ == "__main__":
    save(folder(doc_sheet), "documents")
    save(folder(pic_sheet), "pictures")
    save(folder(music_sheet), "music")
    save(folder(), "folder")
    save(computer(), "computer")
    save(control_panel(), "control")
    save(magnifier(), "search")
    save(run(), "run")
    save(volume(), "volume")
    save(square_button((250, 170, 70), (220, 110, 20), key_symbol), "logoff")
    save(square_button((240, 90, 70), (190, 30, 20), power_symbol), "shutdown")
    save(square_button((250, 200, 80), (210, 140, 20), standby_symbol), "standby")
    save(square_button((110, 200, 90), (40, 140, 40), restart_symbol), "restart")
    print("ok", OUT)
