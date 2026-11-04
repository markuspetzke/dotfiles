"""Wired: kleines Fadenkreuz in Phosphorgruen mit dunklem Rand -> cursor/Theme-wired.
python3 cursor.py (danach `theme wired`)."""
import os
import sys

sys.dont_write_bytecode = True  # kein __pycache__ in themes/
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from xcursor import build  # noqa: E402

ART = [
    "......kgk......",
    "......kgk......",
    "......kgk......",
    "......kgk......",
    "......kgk......",
    ".......k.......",
    "kkkkk.....kkkkk",
    "ggggg..G..ggggg",
    "kkkkk.....kkkkk",
    ".......k.......",
    "......kgk......",
    "......kgk......",
    "......kgk......",
    "......kgk......",
    "......kgk......",
]
PALETTE = {"k": (0x07, 0x08, 0x07), "g": (0x7F, 0xD8, 0x8F), "G": (0xA3, 0xF0, 0xB0)}

here = os.path.dirname(os.path.abspath(__file__))
print(build("Theme-wired", ART, PALETTE, (7, 7), os.path.join(here, "cursor"), "Wii-Pointer-P1"))
