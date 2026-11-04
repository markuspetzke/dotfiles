"""Windows XP: white arrow with a black outline and a soft gray shadow (own
pixel drawing) -> cursor/Theme-winxp. python3 cursor.py (then `theme winxp`)."""
import os
import sys

sys.dont_write_bytecode = True  # no __pycache__ in themes/
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from xcursor import build  # noqa: E402

ART = [
    "k.............",
    "kk............",
    "kwk...........",
    "kwwk..........",
    "kwwwk.........",
    "kwwwwk........",
    "kwwwwwk.......",
    "kwwwwwwk......",
    "kwwwwwwwk.....",
    "kwwwwwwwwk....",
    "kwwwwwwwwwks..",
    "kwwwwwwkkkkks.",
    "kwwwkwwks.sss.",
    "kwwkskwwks....",
    "kwks.skwwks...",
    "kks...kwwks...",
    "ks.....kwwks..",
    "s......kwwks..",
    "........kkss..",
    ".........ss...",
]
PALETTE = {"k": (0, 0, 0), "w": (0xFF, 0xFF, 0xFF), "s": (0x80, 0x80, 0x80)}

here = os.path.dirname(os.path.abspath(__file__))
print(build("Theme-winxp", ART, PALETTE, (0, 0), os.path.join(here, "cursor"), "Wii-Pointer-P1"))
