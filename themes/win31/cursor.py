"""Windows 3.1: classic arrow, black with a white outline, own pixel drawing
-> cursor/Theme-win31. python3 cursor.py (then `theme win31`)."""
import os
import sys

sys.dont_write_bytecode = True  # no __pycache__ in themes/
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from xcursor import build  # noqa: E402

ART = [
    "w...........",
    "ww..........",
    "wkw.........",
    "wkkw........",
    "wkkkw.......",
    "wkkkkw......",
    "wkkkkkw.....",
    "wkkkkkkw....",
    "wkkkkkkkw...",
    "wkkkkkkkkw..",
    "wkkkkkkkkkw.",
    "wkkkkkkwwwww",
    "wkkkwkkw....",
    "wkkwwkkw....",
    "wkw..wkkw...",
    "ww...wkkw...",
    "w.....wkkw..",
    "......wkkw..",
    ".......ww...",
]
PALETTE = {"k": (0, 0, 0), "w": (0xFF, 0xFF, 0xFF)}

here = os.path.dirname(os.path.abspath(__file__))
print(build("Theme-win31", ART, PALETTE, (0, 0), os.path.join(here, "cursor"), "Wii-Pointer-P1"))
