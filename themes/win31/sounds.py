"""Windows 3.1: synthesized system sounds -> sounds/{notify,lock,unlock}.wav (python3 sounds.py).
Own sounds, no samples: notify = a bell-like "ding" (sine with overtones,
decaying), unlock = a rising major chord, lock = two low tones."""
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


def bell(freq, dur, decay=4.0):
    """Bell: fundamental + inharmonic overtones, decaying exponentially."""
    partials = [(1.0, 1.0), (2.76, 0.4), (5.4, 0.2), (8.9, 0.08)]
    out = []
    for i in range(int(dur * RATE)):
        t = i / RATE
        env = math.exp(-decay * t) * min(1, t / 0.002)
        out.append(env * sum(a * math.sin(2 * math.pi * freq * r * t) for r, a in partials))
    return out


def soft(freq, dur):
    """Soft organ tone (fundamental + octave), short fade in/out."""
    out = []
    for i in range(int(dur * RATE)):
        t = i / RATE
        env = min(1, t / 0.01) * min(1, (dur - t) / 0.08)
        out.append(env * (math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(4 * math.pi * freq * t)))
    return out


def overlay(parts):
    """parts: [(start_time, samples)]"""
    n = max(int(s * RATE) + len(p) for s, p in parts)
    out = [0.0] * n
    for start, p in parts:
        o = int(start * RATE)
        for i, v in enumerate(p):
            out[o + i] += v
    return out


save("notify", bell(1046.5, 0.9), gain=0.25)  # C6
# Rising C major chord, the tones ring on
save("unlock", overlay([(0.0, soft(523.3, 1.0)), (0.12, soft(659.3, 0.88)), (0.24, soft(784.0, 0.76)), (0.36, soft(1046.5, 0.64))]), gain=0.25)
save("lock", soft(392.0, 0.18) + soft(261.6, 0.3), gain=0.25)
print("ok", OUT)
