"""Windows XP (Luna): synthetisierte, freundliche Systemklaenge -> sounds/{notify,lock,unlock}.wav.
Eigene Klaenge, keine Microsoft-Samples: notify = weiches "Pling" (zwei Toene), lock = zwei
fallende Toene, unlock = aufsteigender, flaechiger Akkord. python3 sounds.py"""
import math
import os
import struct
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sounds")


def save(name, samples, gain=0.3):
    os.makedirs(OUT, exist_ok=True)
    peak = max(abs(s) for s in samples) or 1
    with wave.open(os.path.join(OUT, name + ".wav"), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s / peak * gain * 32767)) for s in samples))


def n(d):
    return int(d * RATE)


def pling(freq, dur, decay=0.25):
    """Weicher Glockenton: Grundton + leise Oktave, schneller Einsatz, langsames Abklingen."""
    return [(math.sin(2 * math.pi * freq * i / RATE) + 0.25 * math.sin(4 * math.pi * freq * i / RATE))
            * math.exp(-i / (RATE * decay)) * min(1, i / 120) for i in range(n(dur))]


def pad(freq, dur, attack=0.15, release=0.6):
    """Flaechiger Ton: zwei leicht verstimmte Sinus, langsames Ein-/Ausblenden."""
    out = []
    for i in range(n(dur)):
        t = i / RATE
        env = min(1, t / attack) * min(1, (dur - t) / release)
        out.append(env * (math.sin(2 * math.pi * freq * t) + math.sin(2 * math.pi * freq * 1.004 * t) + 0.3 * math.sin(4 * math.pi * freq * t)))
    return out


def overlay(parts):
    total = max(n(s) + len(p) for s, p in parts)
    out = [0.0] * total
    for s, p in parts:
        o = n(s)
        for i, v in enumerate(p):
            out[o + i] += v
    return out


save("notify", overlay([(0.0, pling(1318.5, 0.6)), (0.09, pling(1760.0, 0.7))]), gain=0.22)      # E6, A6
save("lock", overlay([(0.0, pling(880.0, 0.4, 0.15)), (0.14, pling(659.3, 0.5, 0.2))]), gain=0.22)  # A5, E5
save("unlock", overlay([(0.0, pad(349.2, 1.8)), (0.12, pad(440.0, 1.68)), (0.24, pad(523.3, 1.56)),
                        (0.36, pad(698.5, 1.44)), (0.5, pling(1046.5, 1.0, 0.4))]), gain=0.25)   # F-Dur
print("ok", OUT)
