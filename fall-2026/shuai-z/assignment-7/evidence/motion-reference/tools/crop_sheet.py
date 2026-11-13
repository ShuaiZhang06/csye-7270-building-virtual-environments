"""crop_sheet.py <frames dir> <out.png> <first> <last> <cols> <x0> <y0> <x1> <y1> <scale>: numbered, cropped sheet."""
import sys
from PIL import Image, ImageDraw
d, out = sys.argv[1], sys.argv[2]
first, last, cols, x0, y0, x1, y1 = map(int, sys.argv[3:10]); scale = float(sys.argv[10])
idx = list(range(first, last + 1))
w, h = int((x1 - x0) * scale), int((y1 - y0) * scale)
rows = (len(idx) + cols - 1) // cols
sheet = Image.new("RGB", (cols * w, rows * h)); draw = ImageDraw.Draw(sheet)
for i, n in enumerate(idx):
    im = Image.open(f"{d}/{n:04d}.png").convert("RGB").crop((x0, y0, x1, y1)).resize((w, h))
    x, y = (i % cols) * w, (i // cols) * h
    sheet.paste(im, (x, y)); draw.rectangle([x, y, x + 30, y + 13], fill=(0, 0, 0)); draw.text((x + 2, y + 1), str(n), fill=(255, 255, 0))
sheet.save(out); print(out, sheet.size)
