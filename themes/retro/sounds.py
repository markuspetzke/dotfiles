"""Bernstein-CRT: synthetisierte Klaenge eines alten Roehrenterminals
-> sounds/{notify,lock,unlock}.wav (python3 sounds.py). Eigene Klaenge, keine Samples:
notify = Relais-Klick + kurzes Gloeckchen, lock = Roehre aus ("Thunk", fallender Ton),
unlock = Roehre an (Brummen schwillt an, Pfeifen steigt)."""
import math
import os
import random
import struct
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sounds")
rng = random.Random(5)


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


def click(dur=0.012):
    """Kurzer, gedaempfter Rausch-Impuls (Relais)."""
    out, prev = [], 0.0
    for i in range(n(dur)):
        v = rng.uniform(-1, 1)
        prev = prev * 0.6 + v * 0.4  # einfacher Tiefpass
        out.append(prev * math.exp(-i / (RATE * 0.003)))
    return out


def chime(freq, dur):
    return [math.sin(2 * math.pi * freq * i / RATE) * math.exp(-i / (RATE * 0.08)) * min(1, i / 60) for i in range(n(dur))]


def sweep(f0, f1, dur, amp=1.0, fade_in=0.01, fade_out=0.05):
    out, phase = [], 0.0
    for i in range(n(dur)):
        t = i / RATE
        f = f0 + (f1 - f0) * (t / dur)
        phase += 2 * math.pi * f / RATE
        env = min(1, t / fade_in) * min(1, (dur - t) / fade_out)
        out.append(math.sin(phase) * env * amp)
    return out


def hum(dur, swell):
    """50-Hz-Brummen mit Obertoenen, schwillt an (swell=True) oder ab."""
    out = []
    for i in range(n(dur)):
        t = i / RATE
        env = (t / dur) if swell else (1 - t / dur)
        v = math.sin(2 * math.pi * 50 * t) + 0.5 * math.sin(2 * math.pi * 100 * t) + 0.25 * math.sin(2 * math.pi * 150 * t)
        out.append(v * env)
    return out


def add(a, b, offset=0.0):
    o = n(offset)
    out = a + [0.0] * max(0, o + len(b) - len(a))
    for i, v in enumerate(b):
        out[o + i] += v
    return out


save("notify", add(click() + [0.0] * n(0.03) + click(), chime(1568, 0.35), 0.08), gain=0.22)
save("lock", add(add(click(0.02), hum(0.25, False), 0.0), sweep(700, 90, 0.35, 0.8), 0.02), gain=0.28)
save("unlock", add(hum(0.7, True), sweep(300, 1400, 0.6, 0.35, fade_in=0.2, fade_out=0.15), 0.15) + click(), gain=0.25)
print("ok", OUT)
