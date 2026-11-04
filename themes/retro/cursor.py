"""Amber CRT: pixel arrow in amber with a dark outline -> cursor/Theme-retro.
python3 cursor.py (then `theme retro`)."""
import os
import sys

sys.dont_write_bytecode = True  # no __pycache__ in themes/
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from xcursor import build  # noqa: E402

ART = [
    "k...........",
    "kk..........",
    "kak.........",
    "kaak........",
    "kaaak.......",
    "kaaaak......",
    "kaaaaak.....",
    "kaaaaaak....",
    "kaaaaaaak...",
    "kaaaaaaaak..",
    "kaaaaakkkkk.",
    "kaakaak.....",
    "kak.kaak....",
    "kk..kaak....",
    "k....kaak...",
    ".....kaak...",
    "......kk....",
]
PALETTE = {"k": (0x14, 0x13, 0x10), "a": (0xE8, 0xA3, 0x3D)}

here = os.path.dirname(os.path.abspath(__file__))
print(build("Theme-retro", ART, PALETTE, (0, 0), os.path.join(here, "cursor"), "Wii-Pointer-P1"))
