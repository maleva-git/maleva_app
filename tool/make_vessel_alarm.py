#!/usr/bin/env python3
"""NOT USED by the app now (owner, 2026-10-13: vessel alerts vibrate only, no sound). Kept to make the tone again
if a sound is wanted later; it would also need a new channel id and the app/backend sound settings back.

Makes Maleva's vessel alert tone (owner, 2026-10-13: a Tamil-feeling tone that staff are happy to hear, not an
irritating beep; the fun style is the default, like a friend calling "டேய், டைம மாத்திட்டாங்க!").

Styles:
  fun   (default) - a lively Mohanam phrase with a thavil-like "ta-ka-dhi-mi" beat, then room for the voice line
  calm            - a temple bell and a slow Mohanam phrase over a tanpura drone

An original composition made here, so there is no copyright question: a soft temple-bell strike, then a short
phrase in raga Mohanam (Sa Ri Ga Pa Dha, a bright and auspicious pentatonic raga) on a veena-like plucked string
over a quiet tanpura drone - up the scale to the upper Sa, and back home to Sa. About 9 seconds, peak 80%.

Optional: a recorded Tamil voice line (for example a colleague saying "கப்பல் நேரம் மாறியுள்ளது", recorded as
a wav) is added after the tune with  --voice path/to/voice.wav . Do not use the computer's built-in voices
(their licence does not allow use in a company app).

One file serves both phones:
  android/app/src/main/res/raw/vessel_alarm.wav  (the vessel alarm channel's sound)
  ios/Runner/vessel_alarm.wav                     (the APNs sound; iOS plays at most 30 seconds)
Run from the app folder:  python3 tool/make_vessel_alarm.py [--voice voice.wav]
"""
import argparse
import math
import random
import struct
import wave

RATE = 22050
PEAK = 0.8
SA = 293.66  # D4: a comfortable pitch for Sa

# Mohanam: Sa Ri2 Ga3 Pa Dha2 (semitones above Sa)
SWARA = {"S": 0, "R": 2, "G": 4, "P": 7, "D": 9, "S'": 12, "R'": 14, "D,": -3, "P,": -5}

# fun: a quick, bouncy phrase that ends with a flourish on the upper Sa
FUN_PHRASE = [
    ("S", 0.18), ("G", 0.18), ("P", 0.18), ("D", 0.18), ("S'", 0.36), ("D", 0.18), ("S'", 0.54),
    ("P", 0.18), ("D", 0.18), ("S'", 0.18), ("R'", 0.18), ("S'", 0.36), ("D", 0.18), ("P", 0.18),
    ("G", 0.18), ("R", 0.18), ("S", 0.72),
]

# calm: (swara, seconds) up to the upper Sa with a little turn, then down home to Sa
PHRASE = [
    ("S", 0.36), ("R", 0.36), ("G", 0.36), ("P", 0.5), ("D", 0.36), ("S'", 0.95),
    ("R'", 0.3), ("S'", 0.3), ("D", 0.36), ("P", 0.5), ("G", 0.36), ("R", 0.36), ("S", 1.6),
]


def freq(swara):
    return SA * 2 ** (SWARA[swara] / 12)


def pluck(f, seconds, rng):
    """Karplus-Strong plucked string with a soft low-pass: warm, veena-like."""
    n = int(RATE * seconds)
    period = max(2, int(RATE / f))
    buf = [rng.uniform(-1, 1) for _ in range(period)]
    # soften the attack: average the noise once so it is not harsh
    buf = [(buf[i] + buf[i - 1]) / 2 for i in range(period)]
    out = []
    idx = 0
    for i in range(n):
        v = buf[idx]
        nxt = buf[(idx + 1) % period]
        buf[idx] = 0.996 * 0.5 * (v + nxt)  # decay + low-pass
        out.append(v)
        idx = (idx + 1) % period
    # a gentle gamaka-like vibrato is hard in KS; add a quiet sine layer with vibrato for sustain
    for i in range(n):
        t = i / RATE
        env = math.exp(-2.2 * t)
        vib = 1 + 0.004 * math.sin(2 * math.pi * 5.5 * t) * min(1.0, t * 3)
        out[i] = 0.75 * out[i] + 0.25 * env * math.sin(2 * math.pi * f * vib * t)
    return out


def bell(seconds):
    """A small temple bell: inharmonic partials, long soft decay."""
    n = int(RATE * seconds)
    base = SA * 2  # an octave above Sa
    partials = [(1.0, 1.0, 1.6), (2.76, 0.5, 2.4), (5.40, 0.25, 3.5), (8.93, 0.12, 5.0)]
    out = []
    for i in range(n):
        t = i / RATE
        v = sum(a * math.exp(-d * t) * math.sin(2 * math.pi * base * r * t) for r, a, d in partials)
        out.append(v * min(1.0, t * 400))  # no click
    return out


def drum(kind):
    """Thavil-like strokes: 'thom' a deep open stroke, 'ta' a sharp stick stroke."""
    rng = random.Random(3 if kind == "ta" else 5)
    seconds = 0.35 if kind == "thom" else 0.12
    n = int(RATE * seconds)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        if kind == "thom":
            f = 70 + 90 * math.exp(-t * 18)  # pitch drops: a deep "thom"
            phase += 2 * math.pi * f / RATE
            v = math.sin(phase) * math.exp(-t * 9)
        else:
            v = (rng.uniform(-1, 1) * 0.6 + math.sin(2 * math.pi * 900 * t) * 0.4) * math.exp(-t * 45)
        out.append(v)
    return out


# ta-ka-dhi-mi / ta-ka-ju-nu at 8th notes: thom on the strong beats, ta on the rest
BEAT = ["thom", "ta", "ta", "thom", "ta", "thom", "ta", "ta"]


def drone(seconds):
    """A very quiet tanpura-like drone on low Sa and Pa."""
    n = int(RATE * seconds)
    out = []
    for i in range(n):
        t = i / RATE
        swell = 0.5 + 0.5 * math.sin(2 * math.pi * 0.35 * t)
        v = (math.sin(2 * math.pi * SA / 2 * t) + 0.6 * math.sin(2 * math.pi * SA * 0.75 * t)
             + 0.3 * math.sin(2 * math.pi * SA * t))
        fade = min(1.0, t / 0.8, (n - 1 - i) / (RATE * 1.2))
        out.append(0.12 * v * (0.7 + 0.3 * swell) * fade)
    return out


def mix_into(target, source, at_seconds, gain=1.0):
    start = int(RATE * at_seconds)
    if len(target) < start + len(source):
        target.extend([0.0] * (start + len(source) - len(target)))
    for i, s in enumerate(source):
        target[start + i] += gain * s


def read_voice(path):
    with wave.open(path, "rb") as w:
        if w.getsampwidth() != 2:
            raise SystemExit("voice wav must be 16-bit PCM")
        channels, rate, n = w.getnchannels(), w.getframerate(), w.getnframes()
        data = struct.unpack("<%dh" % (n * channels), w.readframes(n))
    mono = [sum(data[i:i + channels]) / channels / 32768 for i in range(0, len(data), channels)]
    if rate != RATE:  # simple linear resample
        ratio = rate / RATE
        mono = [mono[min(len(mono) - 1, int(i * ratio))] for i in range(int(len(mono) / ratio))]
    return mono


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--voice", help="a recorded Tamil voice line (16-bit wav) added after the tune")
    parser.add_argument("--style", choices=["fun", "calm"], default="fun")
    args = parser.parse_args()
    rng = random.Random(7)  # the same tone every run

    song = []
    if args.style == "calm":
        mix_into(song, bell(3.0), 0.0, gain=0.55)
        at = 0.55
        for swara, seconds in PHRASE:
            mix_into(song, pluck(freq(swara), seconds + 1.2, rng), at, gain=0.9)  # each note rings under the next
            at += seconds
        mix_into(song, drone(at + 1.4), 0.0)
    else:
        mix_into(song, bell(2.0), 0.0, gain=0.45)
        start = 0.35
        at = start
        for swara, seconds in FUN_PHRASE:
            mix_into(song, pluck(freq(swara), seconds + 0.8, rng), at, gain=0.9)
            at += seconds
        eighth = 0.18
        k = 0
        while start + k * eighth < at - eighth:
            stroke = BEAT[k % len(BEAT)]
            mix_into(song, drum(stroke), start + k * eighth, gain=0.55 if stroke == "thom" else 0.25)
            k += 1
        mix_into(song, drum("thom"), at - eighth, gain=0.7)  # a final "thom" with the last Sa
        mix_into(song, drone(at + 0.9), 0.0, gain=0.6)
    if args.voice:
        mix_into(song, read_voice(args.voice), at + 0.6, gain=1.0)
    if len(song) / RATE > 29.5:
        raise SystemExit("too long for iPhone (30 s at most)")

    top = max(abs(s) for s in song) or 1.0
    fade = int(RATE * 0.4)
    samples = [s / top for s in song]
    for i in range(fade):
        samples[-1 - i] *= i / fade
    frames = b"".join(struct.pack("<h", int(max(-1.0, min(1.0, s)) * PEAK * 32767)) for s in samples)
    for path in ("android/app/src/main/res/raw/vessel_alarm.wav", "ios/Runner/vessel_alarm.wav"):
        with wave.open(path, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(frames)
        print("wrote", path, "%.1f s" % (len(samples) / RATE))


if __name__ == "__main__":
    main()
