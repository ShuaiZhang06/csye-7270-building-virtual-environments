"""Prints each of Rudy's game frames' transparent margins (texture px) and the smallest.

Run with the frames folder as its argument:
python3 -I frame_margins.py game/content/rudy/frames
"""
import glob
import sys

from PIL import Image

worst = None
for path in sorted(glob.glob(f"{sys.argv[1]}/*.png")):
    image = Image.open(path)
    left, top, right, bottom = image.getchannel("A").getbbox()
    width, height = image.size
    margins = (left, top, width - right, height - bottom)
    worst = min(margins) if worst is None else min(worst, *margins)
    print(f"{path.split('/')[-1]:24s} {width}x{height} margins L{margins[0]} T{margins[1]} R{margins[2]} B{margins[3]}")
print("smallest margin", worst)
