#!/usr/bin/env python3
"""Pack Rudy's 16 game frames into one 4 x 4 sprite sheet.

Run from the assignment folder:

    python3 tools/pack_rudy_sheet.py              # build and check the sheet
    python3 tools/pack_rudy_sheet.py --self-test  # show the pixel check can fail

Reads the pose order, canvas and origin from
game/content/rudy/frames/frames.json and the 16 PNGs beside it, and writes
game/content/rudy/sheet/rudy_sheet.png (CHANGE-BRIEF.md, section 2.1):
- cell = the manifest's canvas (410 x 386), no padding, no scaling, no edits;
- 4 columns x 4 rows, filled row by row in manifest order.

Asserts before packing: 16 poses; every PNG is RGBA at the canvas size; every
PNG keeps at least 16 fully transparent pixels on each side (brief, section 1).
After saving, it reopens the saved file and asserts every cell equals its
source PNG pixel for pixel. Any failed assertion exits 1 and names the cell.

--self-test never writes the real sheet. It builds the sheet in memory, saves
an undamaged copy and two damaged copies (cells 1 and 2 swapped; cell 12
shifted one pixel right) to a temporary directory outside the repository, and
runs the same check on each: the undamaged copy must pass, and each damaged
copy must fail, naming exactly the damaged cells.

Written by Claude Code (Claude Opus 5.5) for Assignment 7, step 1.
"""

import argparse
import hashlib
import json
import shutil
import sys
import tempfile
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent.parent
FRAMES_DIR = HERE / "game" / "content" / "rudy" / "frames"
MANIFEST = FRAMES_DIR / "frames.json"
SHEET = HERE / "game" / "content" / "rudy" / "sheet" / "rudy_sheet.png"

POSES = 16
COLUMNS = 4
ROWS = 4
MIN_MARGIN = 16


class CellError(Exception):
    """A failed assertion about one cell."""

    def __init__(self, cell, pose, message):
        super().__init__(f"cell {cell} ({pose}): {message}")
        self.cell = cell
        self.pose = pose


def fail(message):
    print(f"FAIL {message}", file=sys.stderr)
    sys.exit(1)


def sha256_file(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read_manifest():
    data = json.loads(MANIFEST.read_text())
    poses = list(data["frames"].keys())  # JSON object order is the cell order
    canvas = tuple(data["canvas"])
    origin = tuple(data["origin"])
    if len(poses) != POSES:
        fail(f"manifest: {len(poses)} poses, expected {POSES}")
    if len(canvas) != 2 or len(origin) != 2:
        fail(f"manifest: canvas {canvas} or origin {origin} is not a pair")
    if not (0 <= origin[0] < canvas[0] and 0 <= origin[1] < canvas[1]):
        fail(f"manifest: origin {origin} lies outside canvas {canvas}")
    return poses, canvas, origin


def cell_rect(cell, canvas):
    """(x, y, w, h) of a cell: row by row, no padding."""
    w, h = canvas
    return ((cell % COLUMNS) * w, (cell // COLUMNS) * h, w, h)


def load_frame(cell, pose, canvas):
    path = FRAMES_DIR / f"{pose}.png"
    if not path.is_file():
        raise CellError(cell, pose, f"{path.relative_to(HERE)} does not exist")
    img = Image.open(path)
    img.load()
    if img.format != "PNG":
        raise CellError(cell, pose, f"{path.name} is {img.format}, not PNG")
    if img.mode != "RGBA":
        raise CellError(cell, pose, f"{path.name} is {img.mode}, not RGBA")
    if img.size != canvas:
        raise CellError(cell, pose, f"{path.name} is {img.size[0]} x {img.size[1]}, "
                                    f"not the canvas {canvas[0]} x {canvas[1]}")
    # Bounding box of every pixel with alpha > 0; outside it, alpha is 0.
    bbox = img.getchannel("A").getbbox()
    if bbox is None:
        raise CellError(cell, pose, f"{path.name} is fully transparent")
    left, top = bbox[0], bbox[1]
    right, bottom = canvas[0] - bbox[2], canvas[1] - bbox[3]
    margins = {"left": left, "top": top, "right": right, "bottom": bottom}
    thin = {side: m for side, m in margins.items() if m < MIN_MARGIN}
    if thin:
        raise CellError(cell, pose, f"{path.name} keeps only {thin} transparent px; "
                                    f"at least {MIN_MARGIN} on each side are required")
    return path, img, margins


def load_frames(poses, canvas):
    frames = []
    for cell, pose in enumerate(poses):
        try:
            frames.append(load_frame(cell, pose, canvas))
        except CellError as e:
            fail(str(e))
    return frames


def build_sheet(frames, canvas):
    sheet = Image.new("RGBA", (canvas[0] * COLUMNS, canvas[1] * ROWS), (0, 0, 0, 0))
    for cell, (_path, img, _margins) in enumerate(frames):
        x, y, _w, _h = cell_rect(cell, canvas)
        sheet.paste(img, (x, y))  # no mask: copies RGBA as stored, no blending
    return sheet


def check_sheet(sheet_path, poses, canvas):
    """Reopen the sheet from disk and compare each cell to its source PNG,
    also reopened from disk. Returns a list of CellError, empty when all pass."""
    errors = []
    sheet = Image.open(sheet_path)
    sheet.load()
    want = (canvas[0] * COLUMNS, canvas[1] * ROWS)
    if sheet.mode != "RGBA" or sheet.size != want:
        errors.append(CellError("-", "sheet", f"{sheet.mode} {sheet.size[0]} x {sheet.size[1]}, "
                                             f"expected RGBA {want[0]} x {want[1]}"))
        return errors
    for cell, pose in enumerate(poses):
        x, y, w, h = cell_rect(cell, canvas)
        got = sheet.crop((x, y, x + w, y + h)).tobytes()
        src = Image.open(FRAMES_DIR / f"{pose}.png")
        src.load()
        if src.mode != "RGBA" or src.size != canvas:
            errors.append(CellError(cell, pose, "source PNG is not RGBA at the canvas size"))
            continue
        exp = src.tobytes()
        if got != exp:
            diff = sum(1 for i in range(0, len(exp), 4) if got[i:i + 4] != exp[i:i + 4])
            errors.append(CellError(cell, pose, f"{diff} of {w * h} pixels differ from "
                                                f"{pose}.png at rect ({x}, {y}, {w}, {h})"))
    return errors


def save_png(img, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, format="PNG")


def pack():
    poses, canvas, origin = read_manifest()
    frames = load_frames(poses, canvas)
    sheet = build_sheet(frames, canvas)
    save_png(sheet, SHEET)
    errors = check_sheet(SHEET, poses, canvas)
    if errors:
        for e in errors:
            print(f"FAIL {e}", file=sys.stderr)
        sys.exit(1)
    print(f"manifest {MANIFEST.relative_to(HERE)}: {len(poses)} poses, "
          f"canvas {canvas[0]} x {canvas[1]}, origin {origin}")
    print("cell  pose               rect (x, y, w, h)       margins l/t/r/b   source PNG sha256")
    for cell, (path, _img, m) in enumerate(frames):
        rect = cell_rect(cell, canvas)
        print(f"{cell:>4}  {poses[cell]:<18} {str(rect):<23} "
              f"{m['left']:>3}/{m['top']:>3}/{m['right']:>3}/{m['bottom']:>3}   {sha256_file(path)}")
    print(f"pixel check: all {len(poses)} cells equal their source PNGs (read back from disk)")
    print(f"sheet {SHEET.relative_to(HERE)}: {sheet.size[0]} x {sheet.size[1]} RGBA, "
          f"sha256 {sha256_file(SHEET)}")


def self_test():
    poses, canvas, _origin = read_manifest()
    frames = load_frames(poses, canvas)
    sheet = build_sheet(frames, canvas)

    real_before = sha256_file(SHEET) if SHEET.exists() else None

    def damage_swap(img):
        out = img.copy()
        r1, r2 = cell_rect(1, canvas), cell_rect(2, canvas)
        c1 = img.crop((r1[0], r1[1], r1[0] + r1[2], r1[1] + r1[3]))
        c2 = img.crop((r2[0], r2[1], r2[0] + r2[2], r2[1] + r2[3]))
        out.paste(c2, (r1[0], r1[1]))
        out.paste(c1, (r2[0], r2[1]))
        return out

    def damage_shift(img):
        out = img.copy()
        x, y, w, h = cell_rect(12, canvas)
        cell = img.crop((x, y, x + w, y + h))
        shifted = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        shifted.paste(cell.crop((0, 0, w - 1, h)), (1, 0))  # one pixel right
        out.paste(shifted, (x, y))
        return out

    cases = [
        ("undamaged copy (control)", lambda img: img, set()),
        ("cells 1 and 2 swapped", damage_swap, {1, 2}),
        ("cell 12 shifted one pixel right", damage_shift, {12}),
    ]

    tmp = Path(tempfile.mkdtemp(prefix="rudy_sheet_selftest_"))
    if HERE in tmp.resolve().parents:
        fail(f"self-test: temporary directory {tmp} lies inside the repository")
    print(f"self-test directory (outside the repository): {tmp}")
    ok = True
    try:
        for i, (name, damage, expected) in enumerate(cases):
            path = tmp / f"case{i}.png"
            save_png(damage(sheet), path)
            errors = check_sheet(path, poses, canvas)
            named = {e.cell for e in errors}
            verdict = "PASS" if named == expected else "FAIL"
            if verdict == "FAIL":
                ok = False
            want = "no cell" if not expected else "cells " + ", ".join(map(str, sorted(expected)))
            print(f"{verdict}  {name}: the check must name {want}; it named "
                  f"{'no cell' if not named else ', '.join(map(str, sorted(named, key=str)))}")
            for e in errors:
                print(f"        check said: FAIL {e}")
    finally:
        shutil.rmtree(tmp)

    real_after = sha256_file(SHEET) if SHEET.exists() else None
    if real_before != real_after:
        ok = False
        print(f"FAIL  the real sheet changed during the self-test: {real_before} -> {real_after}")
    else:
        print(f"PASS  the real sheet was not touched (sha256 {real_after})")
    print("self-test: " + ("PASS" if ok else "FAIL"))
    sys.exit(0 if ok else 1)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--self-test", action="store_true",
                        help="show that the pixel check fails on damaged sheets")
    args = parser.parse_args()
    if args.self_test:
        self_test()
    else:
        pack()


if __name__ == "__main__":
    main()
