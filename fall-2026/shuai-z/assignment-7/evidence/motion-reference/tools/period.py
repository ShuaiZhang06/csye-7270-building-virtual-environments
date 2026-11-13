"""period.py <frames dir> <first> <last> <x0> <y0> <x1> <y1>

For lags 1..40, the mean absolute difference between frame t and frame t+lag in a
crop (grayscale, 1/4 size), averaged over every t in [first, last-lag]. A periodic
motion shows minima at its period and multiples; printed with the local minima marked.
"""
import sys
import numpy as np
from PIL import Image
d = sys.argv[1]; first, last, x0, y0, x1, y1 = map(int, sys.argv[2:8])
frames = []
for n in range(first, last + 1):
    im = Image.open(f"{d}/{n:04d}.png").convert("L").crop((x0, y0, x1, y1))
    im = im.resize((im.width // 4, im.height // 4))
    frames.append(np.asarray(im, dtype=np.float32))
frames = np.stack(frames)
vals = []
for lag in range(1, 41):
    vals.append(float(np.mean(np.abs(frames[lag:] - frames[:-lag]))))
for lag, v in enumerate(vals, start=1):
    mark = ""
    if 1 < lag < 40 and v < vals[lag - 2] and v < vals[lag]:
        mark = "  <- local minimum"
    print(f"lag {lag:2d}  {v:7.3f}{mark}")
