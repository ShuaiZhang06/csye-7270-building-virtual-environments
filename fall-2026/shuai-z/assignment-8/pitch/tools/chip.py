"""chip.py — the label chip burned into each play clip, shared by label_clips.py (which draws it) and make_sheet.py
(which declares where it is, so Gate V can measure the chip's contrast instead of the game's mixed colours).

Drafted by Claude Code (Claude Opus 5.5), 2026-11-23.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

FONT = Path.home() / "Library/Fonts/EBGaramond-Medium.ttf"
INK, CARD = (61, 57, 41), (250, 249, 245)
W, H = 3840, 2160
SIZE, PAD_X, PAD_Y, MARGIN = 96, 56, 30, 96


def geometry(text):
    """(left, top, width, height) of the chip, and the text's offset, in 3840 x 2160 pixels."""
    font = ImageFont.truetype(str(FONT), SIZE)
    x0, y0, x1, y1 = ImageDraw.Draw(Image.new("RGB", (8, 8))).textbbox((0, 0), text, font=font)
    w, h = x1 - x0 + 2 * PAD_X, y1 - y0 + 2 * PAD_Y
    return (MARGIN, H - MARGIN - h, w, h), (x0, y0), font


def text_region(text):
    """The chip's inside, as a normalized [x0, y0, x1, y1] box: cream ground with the ink type on it."""
    (left, top, w, h), _, _ = geometry(text)
    return [round((left + PAD_X * 0.5) / W, 4), round((top + PAD_Y * 0.5) / H, 4),
            round((left + w - PAD_X * 0.5) / W, 4), round((top + h - PAD_Y * 0.5) / H, 4)]


def draw(text, out):
    (left, top, w, h), (x0, y0), font = geometry(text)
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([left, top, left + w, top + h], radius=h // 2, fill=CARD + (240,), outline=INK + (255,), width=6)
    d.text((left + PAD_X - x0, top + PAD_Y - y0), text, font=font, fill=INK + (255,))
    img.save(out)
