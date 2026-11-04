"""Office: classic white arrow with a black outline (office PC look), own
pixel drawing -> cursor/Theme-office. python3 cursor.py (then `theme office`)."""
import os
import sys

sys.dont_write_bytecode = True  # no __pycache__ in themes/
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from xcursor import build  # noqa: E402

ART = [
    "k...........",
    "kk..........",
    "kwk.........",
    "kwwk........",
    "kwwwk.......",
    "kwwwwk......",
    "kwwwwwk.....",
    "kwwwwwwk....",
    "kwwwwwwwk...",
    "kwwwwwwwwk..",
    "kwwwwwwwwwk.",
    "kwwwwwwkkkkk",
    "kwwwkwwk....",
    "kwwkkwwk....",
    "kwk..kwwk...",
    "kk...kwwk...",
    "k.....kwwk..",
    "......kwwk..",
    ".......kk...",
]
PALETTE = {"k": (0, 0, 0), "w": (0xFF, 0xFF, 0xFF)}

here = os.path.dirname(os.path.abspath(__file__))
print(build("Theme-office", ART, PALETTE, (0, 0), os.path.join(here, "cursor"), "Wii-Pointer-P1"))
