#!/usr/bin/env python3
"""Cut Rudy's slash frame into the three cutout-rig parts.

Run from the assignment folder:

    python3 tools/cut_slash_rig.py              # cut, check, write parts and previews
    python3 tools/cut_slash_rig.py --self-test  # show that the checks can fail

Source: game/content/rudy/frames/CHAR-SWORD-SLASH.png (CHANGE-BRIEF.md, section
2.2). It is read, never written; its SHA-256 is asserted before and after.

Parts, each RGBA on the frame's 410 x 386 canvas with the same origin, written
to game/content/rudy/rig/:
- slash_blade.png: the blade and the crossguard, from the fist outwards.
  Source pixels, unchanged.
- slash_arc.png:   the translucent arc alone. Over the background, source
  pixels unchanged; over the robe and the shield, the arc separated from the
  opaque pixels it is baked into (alpha solved per pixel, colour kept within
  the arc's own colours as measured over the background).
- slash_body.png:  the frame without the blade, the crossguard and the arc; the
  pommel and grip below the fist stay in it, unrepaired. Where the arc
  covered him, the robe and the shield are repaired from the frame's own
  pixels; those repaired pixels are "the band".

No image is drawn or generated: every part pixel is a source pixel, or a
repair computed from source pixels by the rules printed under "REGION DATA".

Checks (any failure exits 1):
- the source's SHA-256, before and after;
- the parts composited at rest in the rig's draw order (Blade, Body, Arc)
  equal the source pixel for pixel outside the band; inside the band the
  script prints the pixel count, bounding box, and mean and largest channel
  difference;
- no pixel is opaque in both Blade and Body (and, stronger, no pixel has
  any alpha in both).

--self-test runs the same checks on damaged copies written to a temporary
directory outside the repository (Blade shifted one pixel right; one sword
pixel left in Body), plus an undamaged control. It never writes the real
parts or previews.

The previews in evidence/rig-cut/ are drawn here with Python, without the
game's outline shader.

Written by Claude Code (Claude Opus 5.5) for Assignment 7, step 3.
"""

import argparse
import hashlib
import math
import shutil
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage as ndi
from scipy.spatial import cKDTree
from skimage.measure import CircleModel, points_in_poly

HERE = Path(__file__).resolve().parent.parent
SRC = HERE / "game" / "content" / "rudy" / "frames" / "CHAR-SWORD-SLASH.png"
RIG = HERE / "game" / "content" / "rudy" / "rig"
EVIDENCE = HERE / "evidence" / "rig-cut"
PART_NAMES = ("slash_blade.png", "slash_body.png", "slash_arc.png")

SRC_SHA256 = "65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc"  # step 1's log
CANVAS = (410, 386)
ORIGIN = (205.0, 370.0)        # his soles, texture px (frames.json)
TEX_PER_GAME = 2.0             # density 2 (frames.json)

# Section 2.2's key table at its five key times: (tick, Grip deg, Lean deg, Lean x game px).
KEYS = [(0, -70.0, -2.0, 0.0), (2, -60.0, -2.0, 0.0), (5, 0.0, 3.0, 6.0),
        (11, 45.0, 3.0, 6.0), (17, 15.0, 0.0, 0.0)]

# ----------------------------------------------------------------------------
# REGION DATA. Every region and rule the cut uses; all of it is printed.
# Pixel (x, y) means column x, row y; a pixel is "in" a polygon when its centre is.
# ----------------------------------------------------------------------------
LUM = np.array([0.299, 0.587, 0.114])     # luminance weights (Rec. 601)

# The sword.
# 1. Crossguard and the blade's root, x <= GUARD_X_MAX: per row, the first sword
#    column. Left of it is the fist (and its outline); the table is the cut
#    along the fist's knuckles, read from the frame at 14x zoom.
GUARD_ROWS = {**{y: 256 for y in range(136, 153)}, 153: 263, 154: 267, 155: 268,
              156: 269, 157: 269, 158: 270, 159: 270,
              **{y: 272 for y in range(160, 166)}, **{y: 273 for y in range(166, 170)},
              **{y: 274 for y in range(170, 177)}}
GUARD_X_MAX = {**{y: 284 for y in range(136, 170)}, **{y: 281 for y in range(170, 177)}}
# 2. The blade, columns BLADE_X0..BLADE_X1: in each column, from 2 px above its
#    first outline pixel to 1 px below its last outline pixel within
#    BLADE_MAX_THICK px of the first. Outline pixel: luminance < OUTLINE_LUM and
#    alpha >= OUTLINE_ALPHA.
BLADE_X0, BLADE_X1 = 285, 349
BLADE_Y0, BLADE_Y1 = 95, 186
BLADE_MAX_THICK = 26
OUTLINE_LUM, OUTLINE_ALPHA = 80, 128
# 3. The fringe: in the blade's columns, pixels 8-adjacent to regions 1 and 2
#    that are not arc-coloured and darker than SWORD_FRINGE_LUM join the sword
#    (the blade's tip outline, which region 2 misses).
SWORD_FRINGE_LUM = 110
# The pommel and the grip below and left of the fist are NOT sword here: they
# stay in Body, unrepaired, as section 2.2 words it ("the blade and crossguard,
# from the fist outwards"; the user's decision of 2026-11-12). They do not turn.
# Every sword region takes only pixels with alpha > 0 that are not arc-coloured
# translucent pixels (rule ARC_COLOUR below).

# The arc.
# Arc-coloured: RGB within ARC_DIST of ARC_COLOUR, the arc's colour over the
# background (median of its translucent pixels, measured in development).
ARC_COLOUR = np.array([234.0, 241.0, 251.0])
ARC_DIST = 60.0
# ARC_ZONE: where the arc can be. In it, outside the sword and outside him,
# every arc-coloured pixel (translucent or opaque) belongs to the arc.
ARC_ZONE = [(8, 215), (126, 236), (196, 222), (236, 196), (276, 178), (282, 170),
            (300, 145), (330, 112), (346, 104), (358, 106), (358, 150), (330, 205),
            (290, 245), (250, 270), (215, 290), (126, 296), (8, 262)]
# ARC_ONLY: right of the fist and the shield, where no part of him is drawn.
# Every pixel with alpha > 0 in it that is not sword belongs to the arc,
# whatever its colour (the arc's faint edges are not always arc-coloured).
ARC_ONLY = [(276, 100), (362, 100), (362, 205), (300, 242), (252, 264), (240, 238),
            (241, 200), (277, 181)]
# BAND_POLY: where the arc crosses him (the robe and the shield). His opaque
# pixels in it are candidates for repair; a candidate is repaired (joins the
# band) when its estimated arc alpha is at least ALPHA_MIN.
BAND_POLY = [(124, 238), (160, 233), (190, 229), (198, 224), (215, 224), (232, 208),
             (250, 206), (254, 240), (246, 272), (215, 284), (180, 286), (150, 288),
             (124, 286)]
# His outline in BAND_POLY: the shield's outer circle (measured below) and,
# under the shield, the robe's right edge, a line through these two points.
ROBE_RIGHT_EDGE = ((216.0, 248.0), (228.0, 284.0))
# The shield counts as him out to SHIELD_MARGIN px beyond the fitted circle (its
# rim under the arc lies up to about 1.3 px beyond r + 0.5). In BAND_POLY outside
# his edge, pixels that are not arc-coloured and darker than HIS_EDGE_LUM are
# his outline and stay in Body.
SHIELD_MARGIN = 2.5
HIS_EDGE_LUM = 110
# The shield circle is measured from its right edge: rows SHIELD_ROWS, the
# rightmost opaque, not arc-coloured pixel in columns SHIELD_COLS.
SHIELD_ROWS, SHIELD_COLS = (186, 248), (212, 244)
WOOD_ROWS = (196, 214)          # rows that measure the wood's radius
SHIELD_LEFT_ROWS = (186, 200)   # rows that measure the shield's left edge
WOOD_RULE = "R - B >= 25 and luminance >= 60"   # used only for these measurements

# The repair, per band candidate:
# a. material class by geometry: 1 wood (r < wood radius), 2 rim, 3 the shield's
#    outer outline (r - 1.5 to r + 0.5), 0 robe (outside the shield); in the
#    SHIELD_MARGIN ring beyond the outline: 0 robe on the robe's side of its
#    right edge, 2 rim elsewhere;
# b. under-colour U: among the K nearest known pixels of the same class that
#    pass the class's colour rule, the most common colour (RGB quantised to
#    QUANT levels; U is the mean of that bin). Known: opaque, outside
#    BAND_POLY, not arc-coloured, not sword;
# c. the arc's colour over him, ARC_BODY_COLOUR: measured as the median of
#    U + (O - U) / a over candidates with luminance alpha a > 0.35;
# d. arc alpha: projection of (O - U) on (ARC_BODY_COLOUR - U), clipped to
#    [0, ALPHA_CAP], then a MEDIAN x MEDIAN median filter over the candidates;
# e. repaired colour: the exact un-blend (O - a C) / (1 - a), moved towards U's
#    hue with U's luminance scaled by the un-blended luminance as a rises to
#    CHROMA_RAMP, and towards U itself as a rises from FLAT_RAMP[0] to [1];
# f. the arc pixel there: its colour is kept within the arc's own colours, the
#    arc-coloured set (within ARC_DIST of ARC_COLOUR, measured over the
#    background). For each alpha k/255, k = 1..255, the colour that would give
#    the source pixel is projected into that set (radius ARC_DIST - 1, then
#    clipped to 0..255) and rounded; the alpha whose composite comes closest to
#    the source wins (ties: the alpha nearest the estimate). Where no alpha
#    gives the source exactly, the pixel differs inside the band.
CLASS_RULES = {0: "robe: B >= R and luminance >= 70",
               1: "wood: R - B >= 15 and 45 <= luminance <= 150",
               2: "rim: |R - B| < 20 and luminance >= 95",
               3: "outline: luminance < 80"}
K_NEAREST, QUANT, MEDIAN = 60, 8, 5
ALPHA_CAP, ALPHA_MIN = 0.9, 0.03
CHROMA_RAMP, FLAT_RAMP = 0.15, (0.55, 0.80)
# Translucent outline pixels of his in the band that the arc lightened
# (luminance >= OUTLINE_LUM): their colour becomes that of the nearest known
# outline pixel. The arc keeps its share there: the split of the pixel's alpha
# between Body and Arc is searched, with the Arc colour kept within the arc's
# colours; the closest composite wins, ties keeping the most Body.


class CheckError(Exception):
    pass


def fail(message):
    print(f"FAIL {message}", file=sys.stderr)
    sys.exit(1)


def sha256_file(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def assert_source(when):
    got = sha256_file(SRC)
    if got != SRC_SHA256:
        fail(f"source SHA-256 {when}: {got}, expected {SRC_SHA256}")
    print(f"source {SRC.relative_to(HERE)} SHA-256 {when}: {got} (matches step 1)")


def load_rgba(path):
    img = Image.open(path)
    img.load()
    if img.mode != "RGBA" or img.size != CANVAS:
        raise CheckError(f"{Path(path).name} is {img.mode} {img.size}, expected RGBA {CANVAS}")
    return np.asarray(img).copy()


def poly_mask(poly, shape):
    h, w = shape
    yy, xx = np.mgrid[0:h, 0:w]
    pts = np.c_[xx.ravel(), yy.ravel()].astype(float)
    return points_in_poly(pts, np.array(poly, float)).reshape(h, w)


def into_arc_colours(c):
    """Move colours (N x 3) into the arc's own colours: the ball of radius
    ARC_DIST - 1 about ARC_COLOUR, clipped to 0..255 and rounded."""
    d = c - ARC_COLOUR
    n = np.sqrt((d * d).sum(axis=1, keepdims=True))
    r = ARC_DIST - 1.0
    d = np.where(n > r, d * (r / np.maximum(n, 1e-9)), d)
    return np.clip(np.rint(ARC_COLOUR + d), 0, 255)


def arc_colour_distance(rgb):
    return np.sqrt(((rgb.astype(float) - ARC_COLOUR) ** 2).sum(-1))


# ----------------------------------------------------------------------------
# The cut
# ----------------------------------------------------------------------------
def cut(src):
    """Return (blade, body, arc, band, info). All arrays uint8 RGBA except band (bool)."""
    H, W = src.shape[:2]
    f = src.astype(float)
    A = f[..., 3]
    RGB = f[..., :3]
    lum = RGB @ LUM
    R, B = RGB[..., 0], RGB[..., 2]
    semi = (A > 0) & (A < 255)
    opaque = A == 255
    arcish = np.sqrt(((RGB - ARC_COLOUR) ** 2).sum(-1)) < ARC_DIST
    yy, xx = np.mgrid[0:H, 0:W]
    info = {}

    # --- the sword ---
    guard = np.zeros((H, W), bool)
    for y, x0 in GUARD_ROWS.items():
        guard[y, x0:GUARD_X_MAX[y] + 1] = True
    outline = (lum < OUTLINE_LUM) & (A >= OUTLINE_ALPHA)
    blade = np.zeros((H, W), bool)
    spans = {}
    for x in range(BLADE_X0, BLADE_X1 + 1):
        ys = np.nonzero(outline[BLADE_Y0:BLADE_Y1, x])[0] + BLADE_Y0
        if len(ys) == 0:
            continue
        top = ys.min()
        bottom = ys[ys <= top + BLADE_MAX_THICK].max()
        blade[max(top - 2, 0):bottom + 2, x] = True
        spans[x] = (int(top), int(bottom))
    sword = (guard | blade) & (A > 0) & ~(semi & arcish)
    fringe = ndi.binary_dilation(sword, structure=np.ones((3, 3))) & ~sword
    sword |= fringe & (xx >= BLADE_X0) & (A > 0) & ~arcish & (lum < SWORD_FRINGE_LUM)
    info["blade_spans"] = spans
    info["sword_parts"] = {"crossguard": guard & sword, "blade": blade & sword}

    # --- the shield circle and the band's materials ---
    pts = []
    for y in range(SHIELD_ROWS[0], SHIELD_ROWS[1] + 1):
        xs = [x for x in range(SHIELD_COLS[0], SHIELD_COLS[1] + 1) if opaque[y, x] and not arcish[y, x]]
        if xs:
            pts.append((max(xs), y))
    cm = CircleModel()
    if not cm.estimate(np.array(pts, float)):
        fail("could not fit the shield circle")
    scx, scy, r_out = (float(v) for v in cm.params)
    info["shield"] = (scx, scy, r_out, float(cm.residuals(np.array(pts, float)).max()), len(pts))
    wood_px = (R - B >= 25) & (lum >= 60)
    rw = []
    for y in range(WOOD_ROWS[0], WOOD_ROWS[1] + 1):
        x = max(px for px, py in pts if py == y)
        while x > 200 and not wood_px[y, x]:
            x -= 1
        rw.append(math.hypot(x - scx, y - scy))
    r_wood = float(np.median(rw))
    lx = []
    for y in range(SHIELD_LEFT_ROWS[0], SHIELD_LEFT_ROWS[1] + 1):
        xs = [x for x in range(188, 215) if wood_px[y, x]]
        if xs:
            lx.append(min(xs))
    x_left = float(np.median(lx))
    info["wood"] = (r_wood, x_left)
    rr = np.hypot(xx - scx, yy - scy)
    in_shield = (rr <= r_out + SHIELD_MARGIN) & (xx >= x_left - 2)
    (ex0, ey0), (ex1, ey1) = ROBE_RIGHT_EDGE
    robe_side = xx <= ex0 + (yy - ey0) * (ex1 - ex0) / (ey1 - ey0)
    him = in_shield | robe_side                       # his silhouette, used inside BAND_POLY
    cls = np.zeros((H, W), int)
    cls[in_shield & (rr < r_wood)] = 1
    cls[in_shield & (rr >= r_wood) & (rr < r_out - 1.5)] = 2
    cls[in_shield & (rr >= r_out - 1.5) & (rr <= r_out + 0.5)] = 3
    ring = in_shield & (rr > r_out + 0.5)             # the margin beyond the shield's outline
    cls[ring & ~robe_side] = 2
    cls[ring & robe_side] = 0
    rules = {0: (B - R >= 0) & (lum >= 70), 1: (R - B >= 15) & (lum >= 45) & (lum <= 150),
             2: (np.abs(R - B) < 20) & (lum >= 95), 3: lum < 80}

    band_poly = poly_mask(BAND_POLY, (H, W))
    zone = poly_mask(ARC_ZONE, (H, W))
    cand = band_poly & him & opaque & ~sword
    known = opaque & ~band_poly & ~arcish & ~sword
    near = ndi.binary_dilation(band_poly, iterations=40)

    # b. under-colour U by class
    U = RGB.copy()
    tys, txs = np.nonzero(cand)
    for k in range(4):
        sel = cls[tys, txs] == k
        if not sel.any():
            continue
        kys, kxs = np.nonzero(known & near & (cls == k) & rules[k])
        if len(kys) == 0:
            fail(f"no known pixels for class {k}")
        kcol = RGB[kys, kxs]
        kq = (kcol // QUANT).astype(int) @ np.array([1 << 16, 1 << 8, 1])
        n = min(K_NEAREST, len(kys))
        _, nn = cKDTree(np.c_[kys, kxs]).query(np.c_[tys[sel], txs[sel]], k=n)
        nn = nn.reshape(len(nn), -1)
        for t, (y, x) in enumerate(zip(tys[sel], txs[sel])):
            q = kq[nn[t]]
            vals, cnt = np.unique(q, return_counts=True)
            U[y, x] = kcol[nn[t]][q == vals[cnt.argmax()]].mean(0)
    info["class_counts"] = {k: int((cls[tys, txs] == k).sum()) for k in range(4)}

    # c. the arc's colour over him
    O = RGB
    lu, lo, lc = U @ LUM, O @ LUM, ARC_COLOUR @ LUM
    a_lum = np.where(cand, np.clip((lo - lu) / np.maximum(lc - lu, 1.0), 0, ALPHA_CAP), 0)
    s = cand & (a_lum > 0.35)
    c_est = U[s] + (O[s] - U[s]) / a_lum[s][:, None]
    CB = np.median(c_est, axis=0)
    info["arc_body_colour"] = (CB, int(s.sum()))

    # d. arc alpha
    d = CB - U
    a_raw = ((O - U) * d).sum(-1) / np.maximum((d * d).sum(-1), 1.0)
    a_raw = np.where(cand, np.clip(a_raw, 0, ALPHA_CAP), 0)
    a_med = np.where(cand, ndi.median_filter(a_raw, size=MEDIAN), 0)
    band_op = cand & (a_med >= ALPHA_MIN)

    # e. repaired colour
    a3 = a_med[..., None]
    U_rgb = (O - a3 * CB) / (1 - a3)
    L0 = (lo - a_med * (CB @ LUM)) / (1 - a_med)
    U_lum = U * (L0 / np.maximum(lu, 1.0))[..., None]
    c = np.clip(a_med / CHROMA_RAMP, 0, 1)[..., None]
    w = np.clip((a_med - FLAT_RAMP[0]) / (FLAT_RAMP[1] - FLAT_RAMP[0]), 0, 1)[..., None]
    U_fin = (1 - w) * ((1 - c) * U_rgb + c * U_lum) + w * U
    U_fin = np.clip(np.rint(U_fin), 0, 255)

    # translucent outline pixels of his that the arc lightened
    band_semi = band_poly & him & semi & ~arcish & ~sword & (lum >= OUTLINE_LUM)
    oys, oxs = np.nonzero(known & near & (lum < OUTLINE_LUM))
    _, oi = cKDTree(np.c_[oys, oxs]).query(np.c_[np.nonzero(band_semi)])
    outline_col = RGB[oys[oi], oxs[oi]]

    # --- the arc over the background ---
    arc_bg = zone & ~sword & (A > 0) & arcish & ~(band_poly & him & opaque)
    his_outline = (lum < HIS_EDGE_LUM) & ~arcish          # dark: his outline, never arc
    arc_bg |= band_poly & ~him & (A > 0) & ~sword & ~his_outline   # outside his edge in the band
    arc_bg |= poly_mask(ARC_ONLY, (H, W)) & (A > 0) & ~sword
    arc_bg |= guard & semi & arcish          # the arc's thin line outside the crossguard's outline
    arc_bg &= ~band_semi

    # --- assemble ---
    blade_img = np.zeros_like(src)
    blade_img[sword] = src[sword]
    arc_img = np.zeros_like(src)
    arc_img[arc_bg] = src[arc_bg]
    body_img = src.copy()
    body_img[sword | arc_bg] = 0
    # Arc pixels over the background whose source colour lies outside the arc's
    # colours (the arc's faint, off-colour edge pixels): moved into them; they
    # join the band, since the composite there no longer equals the source.
    recol = arc_bg & (arc_colour_distance(src[..., :3]) >= ARC_DIST)
    arc_img[recol, :3] = into_arc_colours(RGB[recol]).astype(np.uint8)
    band = band_op | band_semi | recol
    info["recoloured"] = (int(recol.sum()), A[recol])
    body_img[band_op, :3] = U_fin[band_op].astype(np.uint8)
    body_img[band_semi, :3] = outline_col.astype(np.uint8)

    # f. the arc pixel over each repaired opaque pixel
    by, bx = np.nonzero(band_op)
    Ob = O[by, bx]
    Ub = U_fin[by, bx]
    k_est = a_med[by, bx] * 255
    best_err = np.full(len(by), np.inf)
    best_gap = np.full(len(by), np.inf)
    k_sel = np.full(len(by), 255)
    col = np.tile(ARC_COLOUR, (len(by), 1))
    for k in range(1, 256):
        al = k / 255.0
        ca = into_arc_colours((Ob - (1 - al) * Ub) / al)
        out = np.floor(ca * al + Ub * (1 - al) + 0.5)
        err = np.abs(out - Ob).sum(axis=1)
        gap = np.abs(k - k_est)
        better = (err < best_err) | ((err == best_err) & (gap < best_gap))
        best_err[better], best_gap[better], k_sel[better] = err[better], gap[better], k
        col[better] = ca[better]
    arc_img[by, bx, :3] = col.astype(np.uint8)
    arc_img[by, bx, 3] = k_sel.astype(np.uint8)

    # the arc's share over the recoloured translucent outline pixels
    # For each Body alpha b/255 (b = 0..A), the arc alpha follows from
    # A = a + b (1 - a); its colour is the fitting one moved into the arc's
    # colours. The split whose composite (premultiplied) comes closest wins;
    # ties keep the most Body.
    sy, sx = np.nonzero(band_semi)
    Os = O[sy, sx]
    As = A[sy, sx] / 255.0
    Ub_s = outline_col
    best = np.full(len(sy), np.inf)
    b_sel = np.zeros(len(sy))
    a_sel = As.copy()
    c_sel = np.tile(ARC_COLOUR, (len(sy), 1))
    for b in range(255, -1, -1):
        ab = b / 255.0
        ok = ab <= As + 1e-9
        aa = np.where(ab < 1, (As - ab) / max(1 - ab, 1e-9), 0.0)
        aa_q = np.clip(np.rint(aa * 255), 0, 255) / 255.0
        with np.errstate(invalid="ignore", divide="ignore"):
            ca = np.where(aa_q[:, None] > 0,
                          (As[:, None] * Os - (1 - aa_q[:, None]) * ab * Ub_s) / aa_q[:, None], ARC_COLOUR)
        ca = into_arc_colours(ca)
        got = aa_q[:, None] * ca + (1 - aa_q[:, None]) * ab * Ub_s
        err = np.abs(got - As[:, None] * Os).sum(axis=1) + 255 * np.abs(aa_q + ab * (1 - aa_q) - As)
        better = ok & (err < best - 1e-9)
        best[better], b_sel[better], a_sel[better] = err[better], ab, aa_q[better]
        c_sel[better] = ca[better]
    body_img[sy, sx, 3] = np.rint(b_sel * 255).astype(np.uint8)
    arc_img[sy, sx, :3] = c_sel.astype(np.uint8)
    arc_img[sy, sx, 3] = np.rint(a_sel * 255).astype(np.uint8)
    info["band_alpha"] = (a_med[band_op], k_sel / 255.0)
    info["band_parts"] = (int(band_op.sum()), int(band_semi.sum()))
    info["arc_bg"] = int(arc_bg.sum())
    return blade_img, body_img, arc_img, band, info


# ----------------------------------------------------------------------------
# Measurements: grip point, drawn angle, reach
# ----------------------------------------------------------------------------
def measure(src, blade_img, info):
    f = src.astype(float)
    RGB, A = f[..., :3], f[..., 3]
    skin = (RGB[..., 0] > 200) & (RGB[..., 0] - RGB[..., 2] > 40) & (A == 255)
    lab, _ = ndi.label(skin, structure=np.ones((3, 3)))
    sy, sx = np.nonzero(skin)
    i = np.argmin((sx - 258) ** 2 + (sy - 165) ** 2)
    fist = lab == lab[sy[i], sx[i]]
    fist = ndi.binary_fill_holes(ndi.binary_closing(fist, iterations=2))
    fy, fx = np.nonzero(fist)
    centroid = np.array([fx.mean(), fy.mean()])
    bl = info["sword_parts"]["blade"] & (A == 255)
    by, bx = np.nonzero(bl)
    pts = np.c_[bx, by].astype(float)
    mean = pts.mean(0)
    _, _, vt = np.linalg.svd(pts - mean, full_matrices=False)
    axis = vt[0] if vt[0][0] > 0 else -vt[0]
    grip = mean + axis * ((centroid - mean) @ axis)
    def cross(u, v):
        return float(u[0] * v[1] - u[1] * v[0])
    off = cross(axis, centroid - mean)
    angle = math.degrees(math.atan2(axis[1], axis[0]))
    ay, ax = np.nonzero(blade_img[..., 3] >= 128)
    proj = (np.c_[ax, ay] - grip) @ axis
    j = proj.argmax()
    tip = (int(ax[j]), int(ay[j]))
    return {"fist_px": len(fx), "centroid": centroid, "axis_point": mean, "axis": axis,
            "grip": grip, "centroid_off": off, "angle": angle, "tip": tip,
            "reach": float(proj[j]), "blade_px": len(bx)}


# ----------------------------------------------------------------------------
# The checks (shared by the real run and the self-test)
# ----------------------------------------------------------------------------
def over(top, bottom):
    """Porter-Duff 'over' on float RGBA (straight alpha, 0..255)."""
    ta, ba = top[..., 3:] / 255.0, bottom[..., 3:] / 255.0
    oa = ta + ba * (1 - ta)
    with np.errstate(invalid="ignore", divide="ignore"):
        oc = np.where(oa > 0, (top[..., :3] * ta + bottom[..., :3] * ba * (1 - ta)) / oa, 0)
    return np.concatenate([oc, oa * 255.0], axis=-1)


def composite(blade, body, arc):
    out = over(body.astype(float), blade.astype(float))
    out = over(arc.astype(float), out)
    return np.clip(np.floor(out + 0.5), 0, 255).astype(np.uint8)


def premult_stats(comp, src, band):
    if not band.any():
        return (0.0, 0, 0, 0.0, 0)
    a = comp[..., :3].astype(float) * comp[..., 3:] / 255.0
    b = src[..., :3].astype(float) * src[..., 3:] / 255.0
    pm = np.abs(a - b).max(-1)
    pmb = np.where(band, pm, -1)
    y, x = np.unravel_index(pmb.argmax(), pmb.shape)
    return (float(pm[band].max()), int(x), int(y), float(pm[band].mean()), int((pm[band] > 8).sum()))


def worst_pixel(comp, src, band):
    if not band.any():
        return None
    d = np.abs(comp.astype(int) - src.astype(int)).max(-1)
    d = np.where(band, d, -1)
    y, x = np.unravel_index(d.argmax(), d.shape)
    return (int(x), int(y), tuple(int(v) for v in comp[y, x]), tuple(int(v) for v in src[y, x]))


def check(parts_dir, src, band):
    """Return (errors, stats). errors: list of str, empty when every check passes."""
    errors = []
    try:
        blade, body, arc = (load_rgba(Path(parts_dir) / n) for n in PART_NAMES)
    except (CheckError, FileNotFoundError) as e:
        return [str(e)], {}
    comp = composite(blade, body, arc)
    same = np.all(comp == src, axis=-1) | ((comp[..., 3] == 0) & (src[..., 3] == 0))
    bad = ~same & ~band
    if bad.any():
        y, x = np.nonzero(bad)
        errors.append(f"composite differs from the source outside the band at {bad.sum()} px, "
                      f"bbox x {x.min()}..{x.max()}, y {y.min()}..{y.max()}; first at ({x[0]}, {y[0]}): "
                      f"composite {tuple(int(v) for v in comp[y[0], x[0]])}, "
                      f"source {tuple(int(v) for v in src[y[0], x[0]])}")
    both_opaque = (blade[..., 3] == 255) & (body[..., 3] == 255)
    if both_opaque.any():
        y, x = np.nonzero(both_opaque)
        errors.append(f"{both_opaque.sum()} px opaque in both Blade and Body; first at ({x[0]}, {y[0]})")
    solved = arc[..., 3] > 0
    off_colour = solved & (arc_colour_distance(arc[..., :3]) >= ARC_DIST)
    if off_colour.any():
        y, x = np.nonzero(off_colour)
        errors.append(f"{off_colour.sum()} Arc px lie outside the arc's colours; "
                      f"first at ({x[0]}, {y[0]}): {tuple(int(v) for v in arc[y[0], x[0], :3])}")
    both_any = (blade[..., 3] > 0) & (body[..., 3] > 0)
    if both_any.any():
        y, x = np.nonzero(both_any)
        errors.append(f"{both_any.sum()} px with alpha > 0 in both Blade and Body; first at ({x[0]}, {y[0]})")
    diff = np.abs(comp.astype(int) - src.astype(int))[band]
    y, x = np.nonzero(band)
    stats = {"outside_px": int((~band).sum()), "outside_bad": int(bad.sum()),
             "band_px": int(band.sum()),
             "band_bbox": (int(x.min()), int(y.min()), int(x.max()), int(y.max())) if len(x) else None,
             "band_mean": diff.mean(0) if len(x) else None,
             "band_max": diff.max(0) if len(x) else None,
             "band_exact": int(np.all(diff == 0, axis=1).sum()),
             "both_opaque": int(both_opaque.sum()), "both_any": int(both_any.sum()), "comp": comp,
             "worst": worst_pixel(comp, src, band),
             "premult": premult_stats(comp, src, band),
             "solved_px": int(solved.sum()),
             "solved_maxdist": float(arc_colour_distance(arc[..., :3])[solved].max()) if solved.any() else 0.0}
    return errors, stats


# ----------------------------------------------------------------------------
# Previews (Python only; no outline shader)
# ----------------------------------------------------------------------------
GREY = np.array([128.0, 128.0, 128.0])
BAND_MARK = (255, 214, 0)


def rot(deg):
    t = math.radians(deg)   # positive = clockwise on screen (y points down)
    return np.array([[math.cos(t), -math.sin(t)], [math.sin(t), math.cos(t)]])


def warp(part, M, b, pad):
    """Place part (uint8 RGBA) on a padded canvas by q = M p + b (x, y order), bilinear, premultiplied."""
    H, W = part.shape[:2]
    f = part.astype(float) / 255.0
    pm = np.concatenate([f[..., :3] * f[..., 3:], f[..., 3:]], axis=-1)
    Mi = np.linalg.inv(M)
    # input (x, y) = Mi (q - b), with q = output (x, y) - pad; in (row, col) order:
    P = np.array([[0, 1], [1, 0]])
    m_rc = P @ Mi @ P
    off_rc = P @ (Mi @ (-b - np.array([pad, pad])))
    out = np.zeros((H + 2 * pad, W + 2 * pad, 4))
    for c in range(4):
        out[..., c] = ndi.affine_transform(pm[..., c], m_rc, offset=off_rc,
                                           output_shape=out.shape[:2], order=1, cval=0.0)
    return out


def pm_over(top, bottom):
    return top + bottom * (1 - top[..., 3:])


def to_rgb(pm, bg=GREY):
    rgb = pm[..., :3] * 255.0 + bg * (1 - pm[..., 3:])
    return Image.fromarray(np.clip(np.rint(rgb), 0, 255).astype(np.uint8), "RGB")


def flat(part, bg=GREY):
    return to_rgb(warp(part, np.eye(2), np.zeros(2), 0), bg)


def rig_pose(blade, body, grip, grip_deg, lean_deg, lean_x, pad):
    o = np.array(ORIGIN)
    t = np.array([lean_x * TEX_PER_GAME, 0.0])
    Rl, Rg = rot(lean_deg), rot(grip_deg)
    Mb = Rl @ Rg
    bb = o + t + Rl @ (grip - o) - Mb @ grip
    Mo = Rl
    bo = o + t - Rl @ o
    pm = pm_over(warp(body, Mo, bo, pad), warp(blade, Mb, bb, pad))
    grip_out = Rl @ (grip - o) + o + t + pad
    return pm, grip_out


def label(img, text, h=18):
    out = Image.new("RGB", (img.width, img.height + h), (255, 255, 255))
    out.paste(img, (0, h))
    ImageDraw.Draw(out).text((4, 3), text, fill=(0, 0, 0), font=ImageFont.load_default())
    return out


def row(images, gap=6):
    w = sum(i.width for i in images) + gap * (len(images) - 1)
    h = max(i.height for i in images)
    out = Image.new("RGB", (w, h), (255, 255, 255))
    x = 0
    for i in images:
        out.paste(i, (x, 0))
        x += i.width + gap
    return out


def column(images, gap=10):
    w = max(i.width for i in images)
    h = sum(i.height for i in images) + gap * (len(images) - 1)
    out = Image.new("RGB", (w, h), (255, 255, 255))
    y = 0
    for i in images:
        out.paste(i, (0, y))
        y += i.height + gap
    return out


def zoom(img, box, k):
    c = img.crop(box)
    return c.resize((c.width * k, c.height * k), Image.NEAREST)


def mark_band(img, band):
    edge = ndi.binary_dilation(band) & ~band
    a = np.asarray(img).copy()
    a[edge] = BAND_MARK
    return Image.fromarray(a, "RGB")


def write_previews(src, blade, body, arc, band, comp, grip):
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    written = []
    # 1. the parts side by side on grey, with the band marked
    pb, pbody, parc = flat(blade), flat(body), flat(arc)
    marked = mark_band(pbody, band)
    top = row([label(pb, "Blade (slash_blade.png)"), label(pbody, "Body (slash_body.png)"),
               label(parc, "Arc (slash_arc.png)"), label(marked, "Body, band outlined in yellow")])
    bandbox, fistbox = (110, 195, 262, 295), (222, 138, 286, 192)
    psrc = flat(src)
    bottom = row([label(zoom(pbody, bandbox, 3), "Body x3: the band area"),
                  label(zoom(marked, bandbox, 3), "Body x3, band outlined"),
                  label(zoom(psrc, bandbox, 3), "Source x3, same area"),
                  label(zoom(pbody, fistbox, 5), "Body x5: fist, sword removed")])
    p = EVIDENCE / "parts_on_grey.png"
    column([top, bottom]).save(p)
    written.append(p)
    # 2. composited at rest, beside the source
    pc = flat(comp)
    dmask = np.any(comp != src, axis=-1) & ~((comp[..., 3] == 0) & (src[..., 3] == 0))
    dmap = np.zeros((*src.shape[:2], 3), np.uint8)
    dmap[band] = (60, 60, 60)
    dmap[dmask] = (255, 64, 64)
    p = EVIDENCE / "rest_composite_vs_source.png"
    column([row([label(pc, "Blade, Body, Arc composited at rest"), label(psrc, "Source CHAR-SWORD-SLASH.png"),
                 label(Image.fromarray(dmap, "RGB"), "Red: any channel differs; grey: band")]),
            row([label(zoom(pc, bandbox, 3), "Composite x3"), label(zoom(psrc, bandbox, 3), "Source x3")])]).save(p)
    written.append(p)
    # 3. the rig at the five key times, arc hidden
    pad = 30
    full, fists, bands = [], [], []
    for tick, gdeg, ldeg, lx in KEYS:
        pm, g_out = rig_pose(blade, body, grip, gdeg, ldeg, lx, pad)
        img = to_rgb(pm)
        d = ImageDraw.Draw(img)
        gx, gy = g_out
        d.line([(gx - 4, gy), (gx + 4, gy)], fill=(255, 0, 255))
        d.line([(gx, gy - 4), (gx, gy + 4)], fill=(255, 0, 255))
        ox, oy = np.array(ORIGIN) + pad + np.array([lx * TEX_PER_GAME, 0])
        d.line([(ox - 4, oy), (ox + 4, oy)], fill=(0, 200, 255))
        d.line([(ox, oy - 4), (ox, oy + 4)], fill=(0, 200, 255))
        clean = to_rgb(pm)
        t = f"t {tick}/60 s: Grip {gdeg:+.0f}, Lean {ldeg:+.0f} deg, x {lx:+.0f} game px"
        full.append(label(img, t))
        fb = (int(gx) - 45, int(gy) - 45, int(gx) + 45, int(gy) + 45)
        fists.append(label(zoom(clean, fb, 3), f"t {tick}/60: fist and pommel x3"))
        cx, cy = 190 + pad, 255 + pad
        bb = (cx - 70, cy - 45, cx + 70, cy + 45)
        bands.append(label(zoom(clean, bb, 2), f"t {tick}/60: robe and shield x2"))
    p = EVIDENCE / "rig_key_times.png"
    column([row(full), row(fists), row(bands)]).save(p)
    written.append(p)
    return written


# ----------------------------------------------------------------------------
# Printing
# ----------------------------------------------------------------------------
def print_data():
    print("REGION DATA (pixel (x, y) = column x, row y; a polygon holds a pixel when it holds its centre)")
    print("  sword, 1. crossguard: per row y, the sword columns (x from, x to); the 'from' column is the cut along the fist:")
    runs, prev = [], None
    for y in sorted(GUARD_ROWS):
        span = (GUARD_ROWS[y], GUARD_X_MAX[y])
        if prev and prev[2] == span and prev[1] == y - 1:
            prev[1] = y
        else:
            prev = [y, y, span]
            runs.append(prev)
    for y0, y1, (a, b) in runs:
        print(f"      rows {y0}-{y1}: x {a}..{b}")
    print(f"  sword, 2. blade: columns {BLADE_X0}..{BLADE_X1}, rows {BLADE_Y0}..{BLADE_Y1 - 1}; in each column from 2 px above "
          f"the first outline pixel to 1 px below the last one within {BLADE_MAX_THICK} px of it; "
          f"outline pixel = luminance < {OUTLINE_LUM} and alpha >= {OUTLINE_ALPHA}")
    print(f"  sword, 3. fringe: in columns >= {BLADE_X0}, pixels 8-adjacent to 1 and 2, not arc-coloured, "
          f"luminance < {SWORD_FRINGE_LUM}")
    print(f"  sword: both regions take pixels with alpha > 0, except translucent arc-coloured ones; "
          f"the pommel and grip below the fist are not sword: they stay in Body, unrepaired")
    print(f"  arc-coloured: RGB within {ARC_DIST:.0f} of {tuple(int(v) for v in ARC_COLOUR)} (Euclidean)")
    print(f"  ARC_ZONE polygon: {ARC_ZONE}")
    print(f"  ARC_ONLY polygon (no part of him; every non-sword pixel with alpha > 0 is arc): {ARC_ONLY}")
    print(f"  BAND_POLY polygon (where the arc crosses him): {BAND_POLY}")
    print(f"  his edge in BAND_POLY: the shield circle (measured below), and the robe's right edge, "
          f"the line through {ROBE_RIGHT_EDGE[0]} and {ROBE_RIGHT_EDGE[1]}; the shield counts out to "
          f"{SHIELD_MARGIN} px beyond its circle")
    print(f"  arc over the background: in ARC_ZONE, not sword, alpha > 0, arc-coloured, not his opaque pixel "
          f"in BAND_POLY; every pixel with alpha > 0 in BAND_POLY outside his edge; every non-sword pixel "
          f"in ARC_ONLY; and the translucent arc-coloured pixels in the crossguard rows. "
          f"In BAND_POLY outside his edge, pixels not arc-coloured with luminance < {HIS_EDGE_LUM} are his "
          f"outline and stay in Body")
    print(f"  every Arc pixel's colour lies within the arc's colours (the arc-coloured set): arc-over-background "
          f"pixels outside it are moved into it (radius {ARC_DIST - 1:.0f}, clipped, rounded) and join the band; "
          f"over him, for each alpha k/255 the fitting colour is moved into it and the alpha with the closest "
          f"composite wins (ties: nearest the estimate)")
    print(f"  shield circle: fitted to the rightmost opaque, not arc-coloured pixel of rows {SHIELD_ROWS[0]}..{SHIELD_ROWS[1]} "
          f"in columns {SHIELD_COLS[0]}..{SHIELD_COLS[1]}")
    print(f"  wood radius: rows {WOOD_ROWS[0]}..{WOOD_ROWS[1]}, inwards from that edge to the first wood pixel "
          f"({WOOD_RULE}), median distance from the centre; shield's left edge: rows "
          f"{SHIELD_LEFT_ROWS[0]}..{SHIELD_LEFT_ROWS[1]}, leftmost wood pixel in x 188..214, median")
    print(f"  repair classes and colour rules: " + "; ".join(f"{k} {v}" for k, v in CLASS_RULES.items()))
    print(f"  repair: K {K_NEAREST} nearest known pixels of the class, colour bins of {QUANT}, mode; arc alpha clipped to "
          f"[0, {ALPHA_CAP}], {MEDIAN} x {MEDIAN} median; repaired when alpha >= {ALPHA_MIN}; hue ramp to alpha "
          f"{CHROMA_RAMP}; flat-colour ramp {FLAT_RAMP[0]}..{FLAT_RAMP[1]}")
    print(f"  translucent outline pixels in the band with luminance >= {OUTLINE_LUM}: colour of the nearest known "
          f"outline pixel; the split of the pixel's alpha between Body (b/255) and Arc is searched, the Arc "
          f"colour moved into the arc's colours, and the closest composite wins (ties: the most Body)")


def print_cut(info, meas):
    scx, scy, r_out, res, n = info["shield"]
    r_wood, x_left = info["wood"]
    print("MEASURED REGIONS")
    print(f"  shield circle: centre ({scx:.2f}, {scy:.2f}), radius {r_out:.2f} px, from {n} edge pixels, "
          f"largest residual {res:.2f} px")
    print(f"  wood radius {r_wood:.2f} px; shield's left edge x {x_left:.0f}")
    sp = info["blade_spans"]
    print(f"  blade: {len(sp)} columns, x {min(sp)}..{max(sp)}; outline rows at x {min(sp)}: {sp[min(sp)]}, "
          f"at x 315: {sp.get(315)}, at x {max(sp)}: {sp[max(sp)]}")
    print("  sword pixels: " + ", ".join(f"{k} {int(v.sum())}" for k, v in info["sword_parts"].items())
          + " (regions overlap; total below)")
    CB, n_cb = info["arc_body_colour"]
    print(f"  the arc's colour over him: ({CB[0]:.1f}, {CB[1]:.1f}, {CB[2]:.1f}), median of {n_cb} pixels")
    print("  band candidates by class: " + ", ".join(f"{k} {v}" for k, v in info["class_counts"].items()))
    n_op, n_semi = info["band_parts"]
    a_est, a_arc = info["band_alpha"]
    print(f"  band: {n_op} opaque px repaired (arc alpha estimate median {np.median(a_est):.2f}, max {a_est.max():.2f}; "
          f"stored arc alpha median {np.median(a_arc):.2f}), {n_semi} translucent outline px recoloured")
    n_rc, a_rc = info["recoloured"]
    print(f"  arc over the background: {info['arc_bg']} px; {n_rc} of them were off the arc's colours and were "
          f"moved into them (alpha median {np.median(a_rc):.0f}, max {a_rc.max():.0f}); they join the band")
    print(f"  so the band is {n_op} repaired opaque Body px + {n_semi} recoloured outline px + {n_rc} recoloured Arc px")
    m = meas
    print("GRIP POINT")
    print(f"  method: the fist is the connected skin-coloured region (R > 200, R - B > 40, opaque) nearest (258, 165), "
          f"closed twice and hole-filled ({m['fist_px']} px); its centroid is ({m['centroid'][0]:.2f}, {m['centroid'][1]:.2f})")
    print(f"  the sword's axis: principal axis of the {m['blade_px']} opaque blade pixels, through "
          f"({m['axis_point'][0]:.2f}, {m['axis_point'][1]:.2f}), direction ({m['axis'][0]:.4f}, {m['axis'][1]:.4f})")
    print(f"  grip point = the centroid projected onto the axis: ({m['grip'][0]:.2f}, {m['grip'][1]:.2f}) texture px; "
          f"the centroid lies {m['centroid_off']:+.2f} px off the axis")
    g = (m["grip"] - np.array(ORIGIN)) / TEX_PER_GAME
    print(f"  grip relative to the origin {ORIGIN}: ({g[0]:.2f}, {g[1]:.2f}) game px")
    print(f"  drawn angle: {m['angle']:.2f} deg on screen (positive = clockwise), i.e. {-m['angle']:.2f} deg above "
          f"horizontal, pointing right")
    print(f"  reach, grip to tip: {m['reach']:.2f} texture px = {m['reach'] / TEX_PER_GAME:.2f} game px "
          f"(tip pixel {m['tip']}, the blade pixel with alpha >= 128 farthest along the axis)")


def print_check(errors, stats):
    print("COMPOSITE CHECK (Blade, then Body, then Arc, at rest)")
    print(f"  outside the band: {stats['outside_px']} px, {stats['outside_bad']} differ from the source")
    if stats.get("band_px"):
        mn, mx = stats["band_mean"], stats["band_max"]
        print(f"  inside the band: {stats['band_px']} px, bbox x {stats['band_bbox'][0]}..{stats['band_bbox'][2]}, "
              f"y {stats['band_bbox'][1]}..{stats['band_bbox'][3]}; {stats['band_exact']} px exact; "
              f"mean |difference| R {mn[0]:.3f} G {mn[1]:.3f} B {mn[2]:.3f} A {mn[3]:.3f}; "
              f"largest R {mx[0]} G {mx[1]} B {mx[2]} A {mx[3]}")
        print(f"  inside the band, not exact: {stats['band_px'] - stats['band_exact']} px, largest channel "
              f"difference {int(mx.max())}")
        wx, wy, wc, ws = stats["worst"]
        print(f"  the largest is at ({wx}, {wy}): composite RGBA {wc}, source RGBA {ws}")
        pmax, px, py, pmean, pover = stats["premult"]
        print(f"  weighted by alpha (premultiplied RGB, 0..255): largest {pmax:.1f} at ({px}, {py}), "
              f"mean {pmean:.2f}; {pover} band px above 8")
    print(f"  Arc colours: {stats['solved_px']} Arc px with alpha > 0; largest distance from "
          f"{tuple(int(v) for v in ARC_COLOUR)}: {stats['solved_maxdist']:.1f} (limit: below {ARC_DIST:.0f})")
    print(f"  opaque in both Blade and Body: {stats['both_opaque']} px; alpha > 0 in both: {stats['both_any']} px")
    for e in errors:
        print(f"FAIL {e}")


def run():
    assert_source("before")
    src = load_rgba(SRC)
    blank_rgb = int(((src[..., 3] == 0) & np.any(src[..., :3] != 0, axis=-1)).sum())
    print(f"source: {CANVAS[0]} x {CANVAS[1]} RGBA; {blank_rgb} transparent px carry non-zero RGB "
          f"(the check compares transparent pixels by alpha only)")
    print_data()
    blade, body, arc, band, info = cut(src)
    meas = measure(src, blade, info)
    print_cut(info, meas)
    RIG.mkdir(parents=True, exist_ok=True)
    for name, img in zip(PART_NAMES, (blade, body, arc)):
        Image.fromarray(img, "RGBA").save(RIG / name, format="PNG")
    errors, stats = check(RIG, src, band)
    print_check(errors, stats)
    written = write_previews(src, blade, body, arc, band, stats["comp"], meas["grip"])
    print("previews (Python, no outline shader): " + ", ".join(str(p.relative_to(HERE)) for p in written))
    print("PARTS SHA-256")
    for name in PART_NAMES:
        print(f"  {sha256_file(RIG / name)}  {(RIG / name).relative_to(HERE)}")
    assert_source("after")
    if errors:
        sys.exit(1)
    print("cut: PASS")


def self_test():
    assert_source("before")
    src = load_rgba(SRC)
    real_before = {n: (sha256_file(RIG / n) if (RIG / n).exists() else None) for n in PART_NAMES}
    blade, body, arc, band, _info = cut(src)

    def shifted(b):
        out = np.zeros_like(b)
        out[:, 1:] = b[:, :-1]          # one pixel right
        return out

    ys, xs = np.nonzero(blade[..., 3] == 255)
    sx, sy = int(xs[0]), int(ys[0])

    def leak(b):
        out = b.copy()
        out[sy, sx] = blade[sy, sx]
        return out

    cases = [("undamaged copy (control)", blade, body, arc, False),
             ("Blade shifted one pixel right", shifted(blade), body, arc, True),
             (f"one sword pixel, ({sx}, {sy}), left in Body", blade, leak(body), arc, True)]
    tmp = Path(tempfile.mkdtemp(prefix="rudy_rig_selftest_"))
    if HERE in tmp.resolve().parents or tmp.resolve() == HERE:
        fail(f"self-test directory {tmp} lies inside the repository")
    print(f"self-test directory (outside the repository): {tmp}")
    ok = True
    try:
        for i, (name, b, bo, a, must_fail) in enumerate(cases):
            d = tmp / f"case{i}"
            d.mkdir()
            for n, img in zip(PART_NAMES, (b, bo, a)):
                Image.fromarray(img, "RGBA").save(d / n, format="PNG")
            errors, _ = check(d, src, band)
            failed = bool(errors)
            verdict = "PASS" if failed == must_fail else "FAIL"
            ok &= verdict == "PASS"
            print(f"{verdict}  {name}: the check must {'fail' if must_fail else 'pass'}; it "
                  f"{'failed' if failed else 'passed'}")
            for e in errors:
                print(f"        check said: FAIL {e}")
    finally:
        shutil.rmtree(tmp)
    real_after = {n: (sha256_file(RIG / n) if (RIG / n).exists() else None) for n in PART_NAMES}
    for n in PART_NAMES:
        if real_before[n] != real_after[n]:
            ok = False
            print(f"FAIL  the real {n} changed during the self-test")
        else:
            print(f"PASS  the real {n} was not touched (sha256 {real_after[n]})")
    assert_source("after")
    print("self-test: " + ("PASS" if ok else "FAIL"))
    sys.exit(0 if ok else 1)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--self-test", action="store_true", help="show that the checks fail on damaged parts")
    args = parser.parse_args()
    if args.self_test:
        self_test()
    else:
        run()


if __name__ == "__main__":
    main()
