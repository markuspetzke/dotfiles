"""Office: synthetisierte Buero-Klaenge -> sounds/{notify,lock,unlock}.wav (python3 sounds.py).
Eigene Klaenge, keine Samples: notify = kurzes Telefon-Trillern, lock = Stempel ("Thunk"),
unlock = Tastaturklappern + "Ding"."""
import math
import os
import random
import struct
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sounds")
rng = random.Random(9)


def save(name, samples, gain=0.3):
    os.makedirs(OUT, exist_ok=True)
    peak = max(abs(s) for s in samples) or 1
    with wave.open(os.path.join(OUT, name + ".wav"), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s / peak * gain * 32767)) for s in samples))


def n(dur):
    return int(dur * RATE)


def add(a, b, offset=0.0):
    o = n(offset)
    out = a + [0.0] * max(0, o + len(b) - len(a))
    for i, v in enumerate(b):
        out[o + i] += v
    return out


def trill(dur):
    """Telefon: zwei Toene im 20-Hz-Wechsel, weich ein-/ausgeblendet."""
    out = []
    for i in range(n(dur)):
        t = i / RATE
        f = 1180 if int(t * 40) % 2 == 0 else 1420
        env = min(1, t / 0.01) * min(1, (dur - t) / 0.03)
        out.append(math.sin(2 * math.pi * f * t) * env)
    return out


def thunk():
    """Stempel: tiefer Schlag + kurzes Rauschen."""
    out, prev = [], 0.0
    for i in range(n(0.18)):
        t = i / RATE
        prev = prev * 0.85 + rng.uniform(-1, 1) * 0.15
        out.append(math.sin(2 * math.pi * (110 - 200 * t) * t) * math.exp(-t / 0.05) + prev * math.exp(-t / 0.01) * 2)
    return out


def key():
    out, prev = [], 0.0
    for i in range(n(0.018)):
        prev = prev * 0.5 + rng.uniform(-1, 1) * 0.5
        out.append(prev * math.exp(-i / (RATE * 0.004)))
    return out


def ding(freq=1760, dur=0.6):
    return [math.sin(2 * math.pi * freq * i / RATE) * math.exp(-i / (RATE * 0.15)) * min(1, i / 80)
            + 0.3 * math.sin(2 * math.pi * freq * 2.01 * i / RATE) * math.exp(-i / (RATE * 0.08)) for i in range(n(dur))]


save("notify", trill(0.22) + [0.0] * n(0.08) + trill(0.22), gain=0.18)
save("lock", thunk(), gain=0.3)
typing = []
for _ in range(9):
    typing += key() + [0.0] * n(rng.uniform(0.04, 0.09))
save("unlock", add(typing, ding(), len(typing) / RATE), gain=0.25)
print("ok", OUT)
