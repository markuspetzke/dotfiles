"""Wired: synthetisierte Sounds -> sounds/{notify,lock,unlock}.wav (python3 sounds.py).
notify: kurzer Doppelpiep. lock: fallender Blip. unlock: Modem-Handshake (Waehlton,
Pfeiftoene, Rauschen, Zirpen), ca. 1,5 s. Alles leise abgemischt."""
import math
import os
import random
import struct
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sounds")


def save(name, samples, gain=0.35):
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name + ".wav"), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * gain)) * 32767)) for s in samples))


def tone(freq, dur, wave_fn=math.sin, attack=0.005, release=0.02):
    n = int(dur * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        env = min(1, t / attack) * min(1, (dur - t) / release)
        f = freq(t) if callable(freq) else freq
        out.append(wave_fn(2 * math.pi * f * t) * env)
    return out


def square(x):
    return 1.0 if math.sin(x) >= 0 else -1.0


def silence(dur):
    return [0.0] * int(dur * RATE)


def mix(*parts):
    n = max(len(p) for p in parts)
    return [sum(p[i] for p in parts if i < len(p)) / len(parts) for i in range(n)]


rng = random.Random(1)

# notify: zwei kurze Rechteck-Pieps, leicht gefiltert durch geringe Lautstaerke
save("notify", tone(1320, 0.045, square) + silence(0.035) + tone(1760, 0.06, square), gain=0.12)

# lock: fallender Sinus-Blip
save("lock", tone(lambda t: 880 - 2600 * t, 0.18), gain=0.3)

# unlock: Modem-Handshake
handshake = []
handshake += mix(tone(350, 0.25), tone(440, 0.25))  # Waehlton
handshake += silence(0.05)
handshake += tone(2100, 0.25, release=0.01)  # Antwortton
handshake += [s * 0.7 for s in tone(lambda t: 1200 + 600 * math.sin(2 * math.pi * 9 * t), 0.2)]  # Wobbeln
noise = [(rng.random() * 2 - 1) for _ in range(int(0.3 * RATE))]
handshake += [n * min(1, i / 2000) * 0.6 for i, n in enumerate(noise)]  # Rauschen
for f in (1650, 1850, 1650, 2400, 1200):  # Zirpen
    handshake += tone(f, 0.05, square, release=0.005)
handshake += tone(lambda t: 2200 - 900 * t, 0.12)  # verbunden
save("unlock", handshake, gain=0.22)
print("ok", OUT)
