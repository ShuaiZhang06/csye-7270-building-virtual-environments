"""sheet.py <frames dir> <out.png> <first> <last> <step> <cols> <scale>: numbered contact sheet."""
import sys
from PIL import Image, ImageDraw
d, out, first, last, step, cols, scale = sys.argv[1], sys.argv[2], *map(int, sys.argv[3:7]), float(sys.argv[7])
idx = list(range(first, last + 1, step))
im0 = Image.open(f"{d}/{idx[0]:04d}.png")
w, h = int(im0.width * scale), int(im0.height * scale)
rows = (len(idx) + cols - 1) // cols
sheet = Image.new("RGB", (cols * w, rows * h), (0, 0, 0))
draw = ImageDraw.Draw(sheet)
for i, n in enumerate(idx):
    im = Image.open(f"{d}/{n:04d}.png").convert("RGB").resize((w, h))
    x, y = (i % cols) * w, (i // cols) * h
    sheet.paste(im, (x, y))
    draw.rectangle([x, y, x + 34, y + 14], fill=(0, 0, 0))
    draw.text((x + 2, y + 2), str(n), fill=(255, 255, 0))
sheet.save(out)
print(out, sheet.size)
