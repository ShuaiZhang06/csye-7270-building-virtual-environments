"""
iso_kit.py — the show-tell drawing kit. PASTE this block at the top of a reel's scenes.py;
do not import it (Gate A copies only scenes.py into its sandbox).

Drawn isometric objects in the Claude palette: cardboard boxes (closed, open, taped), dark
MCP blocks with ports, flat skill pages, server stacks with lights, checks, a cursor, pills,
and a WRITING KIT (quill, inkwell, paper, scribble lines, branching outline + the write_lines /
grow_tree animations that make the quill write). A PERSON IS NEVER AN ICON: `professor_bear(ratio, …)`
places a random Professor Bear portrait of the right aspect ratio (PROFESSOR BEAR LAW).
Pacing helpers read the reel's beat_sheet.json so scenes wait for their spoken phrase.

Every rule in ../SKILL.md "DRAWING LAWS" is already obeyed by these primitives; keep it that
way when you add one (label beside, never inside; terracotta never under text; dim greys
with gaps for chart blocks; type floor 32).
"""
from manim import *
import numpy as np
import json as _json, os as _os

# ═════════════════════════════ ISO KIT (show-tell) ═════════════════════════════
STAGE = "#F2F0E9"; INK = "#3D3929"; TERRA = "#D97757"; DIM = "#8B8F96"; GHOST = "#D9D4C7"; CARD = "#FAF9F5"
BOX_TOP, BOX_L, BOX_R = "#F3E9D8", "#DCC9AA", "#C7AE86"          # kraft cardboard: top, left face, right face (deep enough for Gate V contrast)
BOX_IN1, BOX_IN2, BOX_FLOOR = "#CDB894", "#BFA67E", "#B39A72"     # inside walls + floor
DARK_TOP, DARK_L, DARK_R = "#3A3530", "#26221F", "#1E1B18"        # MCP / server blocks
PAGE_TOP, PAGE_L, PAGE_R = "#FFFFFF", "#ECE7DF", "#E2DCD2"         # skill pages
BAR1, BAR2, BAR3 = "#8B8F96", "#B4AFA6", "#D9D4C7"                # chart segments, dim to ghost
SERIF = "EB Garamond"
C30 = 0.8660254
config.background_color = STAGE


def T(s, size=36, color=INK, bold=False):
    return Text(s, font=SERIF, color=color, font_size=size, weight="BOLD" if bold else "NORMAL")


class Iso:
    """Isometric projection: x runs right-up, y runs left-up, z runs up. (ox, oy) is where (0,0,0) lands."""
    def __init__(self, ox=0.0, oy=0.0, s=1.0):
        self.ox, self.oy, self.s = ox, oy, s

    def p(self, x, y, z=0.0):
        return np.array([self.ox + (x - y) * C30 * self.s, self.oy + (x + y) * 0.5 * self.s + z * self.s, 0.0])

    def v(self, dx, dy, dz=0.0):
        return self.p(dx, dy, dz) - self.p(0, 0, 0)

    def quad(self, pts, fill, stroke=INK, sw=4):
        return Polygon(*[self.p(*q) for q in pts], fill_color=fill, fill_opacity=1, stroke_color=stroke, stroke_width=sw)

    def box(self, x0, y0, z0, w, d, h, top=BOX_TOP, left=BOX_L, right=BOX_R, sw=4):
        """Closed box: the two front faces (x = x0 and y = y0) plus the top."""
        x1, y1, z1 = x0 + w, y0 + d, z0 + h
        return VGroup(
            self.quad([(x0, y0, z0), (x0, y1, z0), (x0, y1, z1), (x0, y0, z1)], left, sw=sw),
            self.quad([(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)], right, sw=sw),
            self.quad([(x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)], top, sw=sw))

    def open_box(self, x0, y0, z0, w, d, h):
        """(back, front): floor + inner back walls, then the front walls. Put contents between them."""
        x1, y1, z1 = x0 + w, y0 + d, z0 + h
        back = VGroup(
            self.quad([(x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0)], BOX_FLOOR),
            self.quad([(x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1)], BOX_IN1),
            self.quad([(x0, y1, z0), (x1, y1, z0), (x1, y1, z1), (x0, y1, z1)], BOX_IN2))
        front = VGroup(
            self.quad([(x0, y0, z0), (x0, y1, z0), (x0, y1, z1), (x0, y0, z1)], BOX_L),
            self.quad([(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)], BOX_R))
        back.set_z_index(0); front.set_z_index(2)
        return back, front

    def tape(self, x0, y0, z1, w, d, drop=0.35, t=0.22):
        """Terracotta tape across the top (along x) and down the left front face."""
        ym = y0 + d / 2
        return VGroup(
            self.quad([(x0, ym - t, z1), (x0 + w, ym - t, z1), (x0 + w, ym + t, z1), (x0, ym + t, z1)], TERRA, sw=0),
            self.quad([(x0, ym - t, z1), (x0, ym + t, z1), (x0, ym + t, z1 - drop), (x0, ym - t, z1 - drop)], TERRA, sw=0))

    def mcp(self, x0, y0, z0, w=1.3, d=1.3, h=0.7):
        """Dark MCP block with two light ports on its right front face."""
        body = self.box(x0, y0, z0, w, d, h, DARK_TOP, DARK_L, DARK_R)
        ports = VGroup(*[self.box(x0 + w * f, y0 - 0.18, z0 + h * 0.3, w * 0.16, 0.18, h * 0.3, GHOST, BOX_IN1, BOX_IN2, sw=1)
                         for f in (0.22, 0.58)])
        return VGroup(body, ports)

    def page(self, x0, y0, z0, w=1.1, d=1.4):
        """A skill page lying flat: white slab, three ghost text lines, one terracotta dot."""
        slab = self.box(x0, y0, z0, w, d, 0.06, PAGE_TOP, PAGE_L, PAGE_R, sw=1.5)
        zt = z0 + 0.06
        lines = VGroup(*[Line(self.p(x0 + 0.2, y0 + d * f, zt), self.p(x0 + w - 0.2, y0 + d * f, zt), color=GHOST, stroke_width=4)
                         for f in (0.3, 0.5, 0.7)])
        dot = Dot(self.p(x0 + 0.2, y0 + d * 0.86, zt), radius=0.06, color=TERRA)
        return VGroup(slab, lines, dot)

    def server(self, x0, y0, z0, w=1.4, d=1.4, slab=0.42, n=3):
        """A stack of dark server slabs; returns (stack, lights) — lights start ghost, turn terracotta."""
        stack = VGroup(*[self.box(x0, y0, z0 + i * (slab + 0.04), w, d, slab, DARK_TOP, DARK_L, DARK_R) for i in range(n)])
        lights = VGroup(*[Dot(self.p(x0 + 0.25, y0, z0 + i * (slab + 0.04) + slab / 2), radius=0.06, color=GHOST) for i in range(n)])
        return stack, lights


def ease_in(t):
    """Quadratic ease-in (things dropping into a box). Local: Gate A's stub has no ease_in_quad."""
    return t * t


def check(x, y, s=0.2, color=INK, w=7):
    return VGroup(Line([x - s, y, 0], [x - s * 0.3, y - s * 0.75, 0], color=color, stroke_width=w),
                  Line([x - s * 0.3, y - s * 0.75, 0], [x + s * 1.1, y + s * 0.85, 0], color=color, stroke_width=w))


def cursor(x, y, s=0.45):
    return Polygon([x, y, 0], [x, y - s, 0], [x + s * 0.28, y - s * 0.72, 0], [x + s * 0.62, y - s * 0.66, 0],
                   fill_color=INK, fill_opacity=1, stroke_color=CARD, stroke_width=2)


def pill(x, y, w, h=0.62, fill="#FFFFFF"):
    return RoundedRectangle(width=w, height=h, corner_radius=h / 2, fill_color=fill, fill_opacity=1, stroke_width=0).move_to([x, y, 0])


# ═════════════════════════════ WRITING KIT (quill, ink, paper, scribble) ═════════════════════════════
# Added 2026-10-07 from Bear's two reference drawings: a quill drawing a branching outline on a
# scroll, and three scattered pages of scribbled handwriting with a quill. Use when a beat is
# about writing, drafting, authorship, notes, a manuscript, a log, a letter, a signature.
# Terracotta here is only the ink drop and the outline's nodes (dots) — never the lines.


def quill(x, y, s=1.0, angle=0.0, color=INK, fill=BOX_TOP):
    """A drawn quill with its NIB at (x, y); the feather points up-right. `g.nib` is the nib point.
    Kraft-filled feather, ink outline, a shaft line and one barb. Rotate with `angle` (radians)."""
    o = np.array([x, y, 0.0])
    def P(u, v):  # icon units (0..1) → scene, nib at origin, tip at (1, 1.1)·s
        return o + np.array([u * s, v * s, 0.0])
    body = VMobject(fill_color=fill, fill_opacity=1, stroke_color=color, stroke_width=4)
    body.set_points_smoothly([P(0.00, 0.00), P(0.12, 0.62), P(0.55, 1.02), P(1.00, 1.10),
                              P(0.95, 0.68), P(0.62, 0.22), P(0.00, 0.00)])
    shaft = Line(P(0.02, 0.02), P(0.98, 1.06), color=color, stroke_width=3)
    barb = Line(P(0.46, 0.50), P(0.40, 0.72), color=color, stroke_width=2.5)
    g = VGroup(body, shaft, barb)
    if angle:
        g.rotate(angle, about_point=o)
    g.nib = o.copy()
    return g


def inkwell(iso, x0=0.0, y0=0.0, z0=0.0, s=0.7):
    """A dark ink bottle (iso box + narrow neck) with one terracotta ink dot on the lid."""
    body = iso.box(x0, y0, z0, s, s, s * 0.9, DARK_TOP, DARK_L, DARK_R)
    neck = iso.box(x0 + s * 0.3, y0 + s * 0.3, z0 + s * 0.9, s * 0.4, s * 0.4, s * 0.25, DARK_TOP, DARK_L, DARK_R)
    drop = Dot(iso.p(x0 + s * 0.5, y0 + s * 0.5, z0 + s * 1.15), radius=0.07, color=TERRA)
    return VGroup(body, neck, drop)


def paper(x, y, w=2.4, h=3.0, tilt=0.0, fill=PAGE_TOP):
    """A flat 2-D sheet (the scattered-pages drawing): white page, ink outline, kraft drop shadow.
    `tilt` in radians. Returns a VGroup; `.sheet` is the page rectangle for placing lines on it."""
    shadow = Rectangle(width=w, height=h, fill_color=BOX_L, fill_opacity=1, stroke_width=0).move_to([x + 0.12, y - 0.12, 0])
    sheet = Rectangle(width=w, height=h, fill_color=fill, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to([x, y, 0])
    g = VGroup(shadow, sheet)
    if tilt:
        g.rotate(tilt, about_point=[x, y, 0])
    g.sheet = sheet
    g.cx, g.cy, g.w, g.h, g.tilt = float(x), float(y), float(w), float(h), float(tilt)   # read these; never ask the stub for vertices
    return g


def scribble(x, y, w, amp=0.07, waves=None, color=INK, sw=4):
    """One wavy handwriting line from (x, y) rightwards for `w` units. Reads as script, never as type."""
    n = waves or max(3, int(round(w * 3)))
    pts = []
    for i in range(n * 4 + 1):
        t = i / (n * 4)
        pts.append([x + w * t, y + amp * np.sin(t * n * 2 * np.pi) * (0.6 + 0.4 * np.cos(t * 5.3)), 0])
    m = VMobject(stroke_color=color, stroke_width=sw)
    m.set_points_smoothly(pts)
    return m


def scribble_block(x, y, w, n=3, gap=0.34, last=0.62, color=INK, sw=4):
    """`n` scribble lines stacked downward from (x, y); the last one is `last`× as long (a paragraph end)."""
    return VGroup(*[scribble(x, y - i * gap, w * (last if i == n - 1 else 1.0), color=color, sw=sw) for i in range(n)])


def scribbles_on(page, n=3, inset=0.3, gap=0.34, color=INK, sw=4):
    """Scribble lines laid on a `paper()` group, following its tilt (uses the page's stored geometry)."""
    w = page.w - 2 * inset
    g = scribble_block(page.cx - w / 2, page.cy + page.h / 2 - inset - 0.1, w, n=n, gap=gap, color=color, sw=sw)
    if abs(page.tilt) > 1e-3:
        g.rotate(page.tilt, about_point=[page.cx, page.cy, 0])
    return g


def outline_tree(x, y, h=1.6, levels=2, spread=0.55, color=INK, node=TERRA):
    """A branching outline (the scroll drawing): a trunk rising from (x, y), forking `levels` times,
    a terracotta dot at every tip. Returns VGroup(lines, dots) — draw lines first, dots last."""
    lines, dots = VGroup(), VGroup()
    def grow(px, py, length, lvl, dx):
        qx, qy = px + dx, py + length
        lines.add(Line([px, py, 0], [qx, qy, 0], color=color, stroke_width=4))
        if lvl == 0:
            dots.add(Dot([qx, qy, 0], radius=0.075, color=node))
            return
        for d in (-spread, spread):
            grow(qx, qy, length * 0.62, lvl - 1, d * (0.75 ** (levels - lvl)))
    grow(x, y, h * 0.42, levels, 0.0)
    g = VGroup(lines, dots)
    g.lines, g.dots = lines, dots
    return g


def write_lines(self, q, lines, speed=1.6, hop=0.22, dip=0.06):
    """Animate the quill `q` WRITING each line in `lines`: the nib hops to the line's start, then the
    line draws while the nib rides its tip (the writing motion). `speed` is scene units per second.
    Call between `until()` phrases so each line lands on its words. Works with the midpoint guard."""
    for ln in lines:
        start = np.array(ln.get_start(), dtype=float)
        self.play(q.animate.shift(start - q.nib), run_time=hop, rate_func=smooth)
        q.nib = start.copy()
        off = np.array(q.get_center(), dtype=float) - q.nib
        def ride(m, a, ln=ln, off=off):
            m.move_to(np.array(ln.point_from_proportion(min(1.0, a)), dtype=float) + off)
        try:
            length = float(ln.get_arc_length())
        except Exception:          # Gate A's stub has no arc length; any positive number keeps the check moving
            length = 2.0
        rt = max(0.35, length / speed)
        self.play(Create(ln), UpdateFromAlphaFunc(q, ride), run_time=rt, rate_func=linear)
        q.nib = np.array(ln.get_end(), dtype=float)
        # the small lift between lines keeps the quill from fusing with the ink at GATE T's midpoint
        q.shift([0, dip, 0]); q.nib = q.nib + np.array([0, dip, 0])


def grow_tree(self, q, tree, per=0.45):
    """Animate the quill drawing an `outline_tree`: each segment draws as the nib rides it; dots land last."""
    for ln in tree.lines:
        start = np.array(ln.get_start(), dtype=float)
        self.play(q.animate.shift(start - q.nib), run_time=0.18, rate_func=smooth)
        q.nib = start.copy()
        off = np.array(q.get_center(), dtype=float) - q.nib
        def ride(m, a, ln=ln, off=off):
            m.move_to(np.array(ln.point_from_proportion(min(1.0, a)), dtype=float) + off)
        self.play(Create(ln), UpdateFromAlphaFunc(q, ride), run_time=per, rate_func=linear)
        q.nib = np.array(ln.get_end(), dtype=float)
    self.play(LaggedStart(*[GrowFromCenter(d) for d in tree.dots], lag_ratio=0.15), run_time=0.6)


# ═════════════════════════════ PROFESSOR BEAR (a person is never an icon) ═════════════════════════════
# PROFESSOR BEAR LAW (Bear, 2026-10-07): when a beat needs an icon of a person, or Professor Bear himself,
# do not draw a person token and do not pull a person icon. Show one of the Professor Bear portraits in
# brutalist.art/professor-bear/, chosen at random among those of the right aspect ratio (1x1 · 2x3 · 16x9).
# `./art bear <ratio> --seed <beat>` picks the same way from the shell.
def _pb_dir():
    env = _os.environ.get("ART_HOME")
    cands = [env and _os.path.join(env, "professor-bear")]
    here = _os.path.dirname(_os.path.abspath(__file__))
    for _ in range(8):
        cands.append(_os.path.join(here, "brutalist.art", "professor-bear"))
        cands.append(_os.path.join(here, "professor-bear"))
        here = _os.path.dirname(here)
    cands.append("/Users/bear/Documents/CoWork/bear-textbooks/books/brutalist.art/professor-bear")
    for c in cands:
        if c and _os.path.isdir(c):
            return c
    return cands[-1]


_PB_RATIOS = {"1x1": (1.0, 287), "2x3": (2 / 3, 46), "16x9": (16 / 9, 13)}


def _pb_circle(path):
    """A circular cut (alpha outside the circle), cached beside the set in _crops/. Cropping is fine (Bear, 2026-10-07)."""
    from PIL import Image as _Im, ImageDraw as _Dr
    out_dir = _os.path.join(_os.path.dirname(path), "_crops"); _os.makedirs(out_dir, exist_ok=True)
    out = _os.path.join(out_dir, _os.path.splitext(_os.path.basename(path))[0] + "-circle.png")
    if not _os.path.exists(out):
        im = _Im.open(path).convert("RGBA"); w, h = im.size; s = min(w, h); top = max(0, (h - s) // 3)
        im = im.crop(((w - s) // 2, top, (w - s) // 2 + s, top + s))
        mask = _Im.new("L", (s, s), 0); _Dr.Draw(mask).ellipse((0, 0, s - 1, s - 1), fill=255)
        im.putalpha(mask); im.save(out)
    return out


def professor_bear(ratio="2x3", height=3.0, seed=None, x=0.0, y=0.0, frame=True, shape="rect"):
    """A Professor Bear portrait (random within `ratio`; `seed` = the beat id for a stable pick across re-renders).
    Returns a Group: kraft drop shadow, the photo, an ink frame. Place with `x, y`; size with `height`.
    `shape="circle"` gives a round cut (use a 1x1 portrait). Cropping is fine: circle, rounded square, tight head shot."""
    import random as _random
    ar, n = _PB_RATIOS[ratio]
    k = _random.Random(str(seed) if seed is not None else None).randint(1, n)
    path = _os.path.join(_pb_dir(), f"professor-bear-{ratio}-{k:02d}.png")
    circle = shape == "circle"
    if circle:
        ar = 1.0
    w = height * ar
    if circle:
        shadow = Circle(radius=height / 2, fill_color=BOX_L, fill_opacity=1, stroke_width=0).move_to([x + 0.12, y - 0.12, 0])
        border = Circle(radius=height / 2, stroke_color=INK, stroke_width=4, fill_opacity=0).move_to([x, y, 0])
    else:
        shadow = Rectangle(width=w, height=height, fill_color=BOX_L, fill_opacity=1, stroke_width=0).move_to([x + 0.12, y - 0.12, 0])
        border = Rectangle(width=w, height=height, stroke_color=INK, stroke_width=4, fill_opacity=0).move_to([x, y, 0])
    try:
        img = ImageMobject(_pb_circle(path) if circle else path)
        img.height = height
        img.move_to([x, y, 0])
    except Exception:
        img = Rectangle(width=w, height=height, fill_color=BAR2, fill_opacity=1, stroke_width=0).move_to([x, y, 0])
    g = Group(shadow, img, border) if frame else Group(img)
    g.path = path
    return g


# ═════════════════════════════ pacing (narration is the clock) ═════════════════════════════
try:
    _SHEET = _json.load(open(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "beat_sheet.json")))
    _TARGET = {b["beat_id"]: float(b.get("actual_duration_s") or b.get("estimated_duration_s") or 0) for b in _SHEET["beats"]}
    _NARR = {b["beat_id"]: b["narration_text"] for b in _SHEET["beats"]}
except Exception:
    _TARGET, _NARR = {}, {}


def _elapsed(self):
    rt = getattr(getattr(self, "renderer", None), "time", None)
    return float(rt) if isinstance(rt, (int, float)) else 0.0


def until(self, phrase, lead=0.25):
    """Wait until `phrase` is spoken (its character share of the narration × the measured audio)."""
    bid = type(self).__name__.split("_")[0]
    n, target = _NARR.get(bid, ""), _TARGET.get(bid, 0)
    if not n or not target or phrase not in n:
        return
    gap = target * n.index(phrase) / len(n) - lead - _elapsed(self)
    if gap > 0.05:
        self.wait(gap)


def finish(self):
    target = _TARGET.get(type(self).__name__.split("_")[0], 0)
    self.wait(max(0.3, target - _elapsed(self)) if target else 2.0)


# ═════════════════════════════ WALKER RUDY PITCH (Assignment 8) ═════════════════════════════
# Everything below this line was written by Claude Code (Claude Opus 5.5) on 2026-11-23 for
# Shuai Zhang's final-project pitch film. The kit above is the show-tell kit, pasted unchanged.
#
# The film's cast, kept the same from beat to beat (show-tell law 4): level TILES (kraft = built,
# ghost = designed), a BROWSER window (the web build), PAGES (test reports, the README), CRATES on a
# SHELF (the tagged assignments a5-a7), HEARTS, and a TELL LAMP. Figures from GDD.md and stills
# from the takes are framed on the stage with their status written beside them (built, designed,
# generated, constructed), because Assignment 8 asks for constructed and generated material to be
# labelled. No person is drawn as an icon; Rudy appears only as his own game frame.
#
# The midpoint guard: GATE T and Gate V sample each clip at its midpoint, so `gplay` never runs an
# animation across [T/2 - 0.25 s, T/2 + 0.25 s]; it waits until the window has passed instead.
HERE = _os.path.dirname(_os.path.abspath(__file__))
GUARD = 0.25
HEART = "#C9483B"          # not used for text; hearts only
GREY_TOP, GREY_L, GREY_R = "#C9C6BF", "#AFABA3", "#9C988F"     # greybox blocks
DESIGN_TOP, DESIGN_L, DESIGN_R = "#ECE8DE", "#E6E2D7", "#E2DDD1"  # designed (not built): pale faces, ink outlines
ART = "#7D8C46"            # a level's art layer (olive, a field painted over the greybox)
SHELF = DARK_L             # shelves are dark planks, so pale crates on them keep Gate V contrast


def _T_of(self):
    return _TARGET.get(type(self).__name__.split("_")[0], 0)


def gplay(self, *anims, run_time=0.8, **kw):
    """self.play, kept off the clip's midpoint window (see the guard note above)."""
    target = _T_of(self)
    if target:
        t0, lo, hi = _elapsed(self), target / 2 - GUARD, target / 2 + GUARD
        if t0 < hi and t0 + run_time > lo:
            self.wait(hi - t0)
    self.play(*anims, run_time=run_time, **kw)


def framed(rel, aspect, w=None, h=None, x=0.0, y=0.0):
    """A figure or still, framed like the kit's portraits: kraft shadow, the image, an ink border.
    `aspect` is width/height (so a missing file, as in Gate A's sandbox, keeps the same layout)."""
    W = w if w else h * aspect
    H = W / aspect
    try:
        im = ImageMobject(_os.path.join(HERE, rel))
        im.height = H
        im.move_to([x, y, 0])
    except Exception:
        im = Rectangle(width=W, height=H, fill_color=BAR2, fill_opacity=1, stroke_width=0).move_to([x, y, 0])
    shadow = Rectangle(width=W, height=H, fill_color=BOX_L, fill_opacity=1, stroke_width=0).move_to([x + 0.12, y - 0.12, 0])
    border = Rectangle(width=W, height=H, stroke_color=INK, stroke_width=4, fill_opacity=0).move_to([x, y, 0])
    g = Group(shadow, im, border)
    g.W, g.H, g.cx, g.cy = float(W), float(H), float(x), float(y)
    return g


def fpt(g, fx, fy):
    """A point on a framed image, as fractions from its top-left corner."""
    return np.array([g.cx - g.W / 2 + fx * g.W, g.cy + g.H / 2 - fy * g.H, 0.0])


def frect(g, fx0, fy0, fx1, fy1, sw=7, color=INK):
    """An outline around a region of a framed image (fractions from its top-left)."""
    a, b = fpt(g, fx0, fy0), fpt(g, fx1, fy1)
    return Rectangle(width=abs(b[0] - a[0]), height=abs(a[1] - b[1]), stroke_color=color, stroke_width=sw,
                     fill_opacity=0).move_to((a + b) / 2)


def heart(x, y, s=0.32, full=True):
    """A heart: two lobes and a point, ink outline; red when full, stage-coloured when empty."""
    m = VMobject(fill_color=HEART if full else STAGE, fill_opacity=1, stroke_color=INK, stroke_width=4)
    pts = []
    for i in range(41):
        t = 2 * np.pi * i / 40
        hx = 16 * np.sin(t) ** 3
        hy = 13 * np.cos(t) - 5 * np.cos(2 * t) - 2 * np.cos(3 * t) - np.cos(4 * t)
        pts.append([x + hx / 17 * s, y + hy / 17 * s, 0])
    m.set_points_smoothly(pts)
    return m


def tile(iso, x, y, built=True, h=0.32, w=1.25, d=1.25):
    """A level tile: kraft when built, pale with grey edges when only designed."""
    if built:
        return iso.box(x, y, 0, w, d, h)
    return iso.box(x, y, 0, w, d, h, DESIGN_TOP, DESIGN_L, DESIGN_R, sw=3)


def grey_block(iso, x, y, z, w, d, h):
    return iso.box(x, y, z, w, d, h, GREY_TOP, GREY_L, GREY_R)


def browser(x, y, w, h):
    """The web build: a pale window with a grey title bar and three dots."""
    body = RoundedRectangle(width=w, height=h, corner_radius=0.12, fill_color=CARD, fill_opacity=1,
                            stroke_color=INK, stroke_width=4).move_to([x, y, 0])
    bar = Rectangle(width=w - 0.08, height=0.36, fill_color=BAR1, fill_opacity=1, stroke_width=0).move_to(
        [x, y + h / 2 - 0.22, 0])
    dots = VGroup(*[Dot([x - w / 2 + 0.3 + i * 0.25, y + h / 2 - 0.22, 0], radius=0.065, color=CARD) for i in range(3)])
    g = VGroup(body, bar, dots)
    return g


def lamp(x, y, s=1.0):
    """A tell lamp on a post: (post, head). Light it with head.animate.set_fill(TERRA)."""
    post = Rectangle(width=0.14 * s, height=1.2 * s, fill_color=BAR1, fill_opacity=1, stroke_color=INK,
                     stroke_width=3).move_to([x, y + 0.6 * s, 0])
    head = Circle(radius=0.28 * s, fill_color=GHOST, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to(
        [x, y + 1.42 * s, 0])
    return post, head


def waystone(x, y, s=1.0):
    """A standing stone with a rune light (a dot that turns terracotta)."""
    stone = Polygon([x - 0.42 * s, y, 0], [x - 0.36 * s, y + 1.1 * s, 0], [x, y + 1.35 * s, 0],
                    [x + 0.38 * s, y + 1.12 * s, 0], [x + 0.44 * s, y, 0],
                    fill_color=BAR2, fill_opacity=1, stroke_color=INK, stroke_width=4)
    rune = Dot([x, y + 0.7 * s, 0], radius=0.11 * s, color=GHOST)
    return stone, rune


def shield(x, y, s=1.0):
    rim = Circle(radius=0.48 * s, fill_color=BOX_R, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to([x, y, 0])
    face = Circle(radius=0.3 * s, fill_color=BOX_TOP, fill_opacity=1, stroke_color=INK, stroke_width=3).move_to([x, y, 0])
    boss = Dot([x, y, 0], radius=0.07 * s, color=INK)
    return VGroup(rim, face, boss)


def crate(iso, x, y, z=0.0, s=0.9, built=True):
    if built:
        return iso.box(x, y, z, s, s, s)
    return iso.box(x, y, z, s, s, s, DESIGN_TOP, DESIGN_L, DESIGN_R, sw=3)


def plank(iso, x, y, z, w, d=1.0, h=0.18):
    return iso.box(x, y, z, w, d, h, BOX_TOP, BOX_L, BOX_R)


def report(x, y, w=1.3, h=1.6, ticked=False):
    """A test-report page: a flat sheet with scribble lines; `check` is added separately."""
    pg = paper(x, y, w, h)
    lines = scribble_block(x - w / 2 + 0.3, y + h / 2 - 0.4, w - 0.6, n=3, gap=0.36)
    for ln in lines:
        ln.stretch(1.35, 1)          # taller waves: GATE T reads a flat scribble as sub-floor type
    return VGroup(pg, lines)


def floor_line(x0, x1, y):
    return Line([x0, y, 0], [x1, y, 0], color=INK, stroke_width=5)


def checklist(x, y, w=1.3, h=1.6, n=2):
    """A test page: a sheet with `n` grey-edged boxes and a scribble line beside each.
    Returns (page, ticks): add the page, then Create the ticks, which land inside the boxes."""
    pg = paper(x, y, w, h)
    rows, ticks = VGroup(), VGroup()
    gap = h / (n + 1)
    for i in range(n):
        yy = y + h / 2 - gap * (i + 1)
        bx = Square(0.3, fill_color=CARD, fill_opacity=1, stroke_color=BAR1, stroke_width=3).move_to([x - w / 2 + 0.33, yy, 0])
        rows.add(bx, scribble(x - w / 2 + 0.62, yy, w - 0.85, amp=0.05))
        ticks.add(check(x - w / 2 + 0.33, yy + 0.02, s=0.16, w=6))
    return VGroup(pg, rows), ticks


# ───────────────────────────── title card ─────────────────────────────
class B00_Title(Scene):
    def construct(self):
        title = T("Walker Rudy: The Long Way Home", 48).move_to([0, 2.85, 0])
        still = framed("stills/title.png", 16 / 9, w=7.2, x=-2.55, y=-0.15)
        cap = T("the game's title screen, tag a7", 32).next_to(still, DOWN, buff=0.28).align_to(still, LEFT)
        self.add(title)
        gplay(self, FadeIn(still, shift=UP * 0.3), run_time=0.7)
        self.add(cap)
        until(self, "version two")
        gdd = T("GDD v2", 56, bold=True).move_to([3.85, 1.3, 0])
        rule = Line([2.75, 0.85, 0], [4.95, 0.85, 0], color=INK, stroke_width=5)
        date = T("2026-11-23", 40).move_to([3.85, 0.3, 0])
        gplay(self, FadeIn(gdd), Create(rule), FadeIn(date), run_time=0.7)
        name = T("Shuai Zhang", 40).move_to([3.85, -0.5, 0])
        gplay(self, FadeIn(name), run_time=0.5)
        until(self, "synthetic voice")
        voice = T("synthetic voice", 34).move_to([4.0, -1.45, 0])
        dot = Dot([2.45, -1.45, 0], radius=0.09, color=TERRA)
        gplay(self, FadeIn(voice), GrowFromCenter(dot), run_time=0.6)
        finish(self)


class BDEFS_Terms(Scene):
    def construct(self):
        title = T("Terms in this film", 44).move_to([-3.2, 2.7, 0])
        rule = Line([-5.9, 2.2, 0], [5.9, 2.2, 0], color=GHOST, stroke_width=4)
        self.add(title, rule)
        # Left-aligned columns at fixed centres (widths measured with Manim, 2026-11-23: Gate A's stub cannot measure text).
        rows = [("built", 1.257, "shown running: the game, tag a7", 7.329, "Built means"),
                ("designed", 2.225, "planned: the design document only", 8.009, "designed means"),
                ("greybox", 2.044, "plain shapes, playable before its art", 7.875, "A greybox")]
        y = 1.2
        for term, tw, meaning, mw, ph in rows:
            until(self, ph)
            dot = Dot([-5.7, y, 0], radius=0.1, color=TERRA)
            tt = T(term, 48, bold=True).move_to([-5.4 + tw / 2, y, 0])
            mm = T(meaning, 44).move_to([-2.4 + mw / 2, y, 0])
            sep = Line([-5.9, y - 0.75, 0], [5.9, y - 0.75, 0], color=GHOST, stroke_width=3)
            gplay(self, GrowFromCenter(dot), FadeIn(tt), FadeIn(mm, shift=RIGHT * 0.2), Create(sep), run_time=0.5)
            y -= 1.5
        finish(self)


# ───────────────────────────── the game in brief ─────────────────────────────
class B03_SixTiles(Scene):
    def construct(self):
        iso = Iso(-4.7, -0.9, 1.0)
        tiles = [tile(iso, i * 1.05, -i * 1.05, built=(i == 0)) for i in range(6)]
        label = T("6 levels", 40).move_to([0, -2.6, 0])
        gplay(self, LaggedStart(*[FadeIn(t, shift=DOWN * 0.4) for t in tiles], lag_ratio=0.2), run_time=1.2)
        self.add(label)
        until(self, "exported to the web")
        win = browser(0.2, -0.45, 11.6, 2.9)
        win.set_z_index(-1)
        web = T("web", 40).move_to([-5.3, 1.45, 0])
        gplay(self, Create(win[0]), FadeIn(win[1]), FadeIn(win[2]), FadeIn(web), run_time=0.8)
        until(self, "test report")
        page, ticks = checklist(4.75, 2.2, w=1.3, h=1.35, n=2)
        rlabel = T("test report", 36).move_to([2.55, 2.3, 0])
        gplay(self, FadeIn(page, shift=DOWN * 0.3), FadeIn(rlabel), run_time=0.6)
        gplay(self, LaggedStart(*[Create(t) for t in ticks], lag_ratio=0.5), run_time=0.5)
        finish(self)


# ───────────────────────────── GDD 1-6 ─────────────────────────────
class B04_FourPillars(Scene):
    def construct(self):
        plinth = Rectangle(width=11.4, height=0.34, fill_color=DARK_L, fill_opacity=1, stroke_color=INK,
                           stroke_width=4).move_to([0, -1.67, 0])
        self.add(plinth)
        names = ["gear", "tells", "retry", "journey"]
        phrases = ["your gear is your plan", "read every threat", "it stings", "a journey"]
        xs = [-4.2, -1.4, 1.4, 4.2]
        for n, ph, x in zip(names, phrases, xs):
            until(self, ph)
            col = Rectangle(width=1.0, height=2.9, fill_color=BOX_R, fill_opacity=1, stroke_color=INK,
                            stroke_width=4).move_to([x, -0.05, 0])
            cap = Rectangle(width=1.3, height=0.28, fill_color=BOX_TOP, fill_opacity=1, stroke_color=INK,
                            stroke_width=4).move_to([x, 1.54, 0])
            lab = T(n, 40).move_to([x, -2.35, 0])
            gplay(self, GrowFromEdge(col, DOWN), FadeIn(cap), FadeIn(lab), run_time=0.55)
        lintel = Rectangle(width=10.4, height=0.4, fill_color=BOX_TOP, fill_opacity=1, stroke_color=INK,
                           stroke_width=4).move_to([0, 1.9, 0])
        gplay(self, FadeIn(lintel, shift=DOWN * 0.4), run_time=0.5)
        finish(self)


class B05_ThreeLoops(Scene):
    def construct(self):
        rings = [(-4.4, 0.0, 0.9), (-0.9, 0.0, 1.4), (3.6, 0.0, 2.0)]
        names = ["seconds", "a level", "next region"]
        phrases = ["Second to second", "over a level", "next region"]
        for (x, y, r), n, ph in zip(rings, names, phrases):
            until(self, ph)
            ring = Ellipse(width=2 * r, height=1.1 * r, stroke_color=INK, stroke_width=5).move_to([x, y, 0])
            lab = T(n, 38).move_to([x, y - 0.55 * r - 0.6, 0])
            gplay(self, Create(ring), FadeIn(lab), run_time=0.45)
            if n == "seconds":
                dot = Dot(ring.point_from_proportion(0), radius=0.13, color=TERRA)
                gplay(self, MoveAlongPath(dot, ring), run_time=0.6, rate_func=linear)
            elif n == "a level":
                stand = shield(x, y + 0.55 * r, 0.55)
                side = Line([x + r, y, 0], [x + r + 0.5, y + 0.6, 0], color=INK, stroke_width=5)
                gplay(self, FadeIn(stand), Create(side), run_time=0.4)
            else:
                top = np.array([x, y + 0.55 * r, 0.0])
                bottom = np.array([x, y - 0.55 * r, 0.0])
                nxt = tile(Iso(x, y + 0.55 * r + 0.05, 0.55), -0.62, -0.62, built=False)
                dot = Dot(bottom, radius=0.13, color=TERRA)
                gplay(self, FadeIn(nxt, shift=DOWN * 0.3), GrowFromCenter(dot), run_time=0.35)
                gplay(self, MoveAlongPath(dot, ArcBetweenPoints(bottom, top, angle=PI * 0.9)), run_time=0.5)
        finish(self)


class B06_Feelings(Scene):
    def construct(self):
        post, head = lamp(-4.4, -1.6, 1.1)
        floor = floor_line(-6.0, 6.0, -1.6)
        self.add(floor, post, head)
        w1 = T("warned", 40).move_to([-4.4, -2.4, 0])
        until(self, "warned in time")
        gplay(self, head.animate.set_fill(TERRA), FadeIn(w1), run_time=0.45)
        shot = Arrow([-3.8, 0.0, 0], [-2.2, 0.0, 0], color=INK, stroke_width=6, buff=0)
        gplay(self, GrowArrow(shot), run_time=0.45)
        hearts = [heart(-0.6 + i * 0.85, 0.2) for i in range(3)]
        w2 = T("try again", 40).move_to([0.25, -2.4, 0])
        until(self, "stung but ready")
        gplay(self, LaggedStart(*[FadeIn(h) for h in hearts], lag_ratio=0.2), run_time=0.5)
        empty = heart(1.1, 0.2, full=False)
        gplay(self, FadeOut(hearts[2], shift=DOWN * 0.5), FadeIn(empty), FadeIn(w2), run_time=0.5)
        loop = CurvedArrow([1.4, -0.4, 0], [-0.9, -0.4, 0], angle=-1.6, color=INK, stroke_width=5)
        gplay(self, Create(loop), run_time=0.6)
        until(self, "playtests")
        page, ticks = checklist(4.3, 0.35, w=1.7, h=1.9, n=2)
        w3 = T("playtest", 40).move_to([4.3, -2.4, 0])
        gplay(self, FadeIn(page, shift=DOWN * 0.3), FadeIn(w3), run_time=0.5)
        gplay(self, LaggedStart(*[Create(t) for t in ticks], lag_ratio=0.5), run_time=0.6)
        finish(self)


class B08_Systems(Scene):
    def construct(self):
        floor = floor_line(-6.0, 6.0, -1.0)
        self.add(floor)
        hearts = VGroup(*[heart(-5.35 + i * 0.82, -0.5, s=0.36) for i in range(3)])
        sh = shield(-2.7, -0.35, 1.3)
        g1 = T("gear", 40).move_to([-3.9, -1.75, 0])
        gplay(self, FadeIn(hearts), FadeIn(sh), FadeIn(g1), run_time=0.6)
        hit = Arrow([-0.8, 0.0, 0], [-1.95, -0.2, 0], color=INK, stroke_width=6, buff=0)
        gplay(self, GrowArrow(hit), run_time=0.4)
        gplay(self, hit.animate.rotate(PI * 0.8).shift(UP * 0.9 + RIGHT * 0.4).set_opacity(0), run_time=0.4)
        until(self, "waystones")
        stone, rune = waystone(0.7, -1.0, 1.4)
        g2 = T("waystone", 40).move_to([0.7, -1.75, 0])
        gplay(self, FadeIn(stone), FadeIn(rune), FadeIn(g2), run_time=0.5)
        gplay(self, rune.animate.set_color(TERRA).scale(1.4), run_time=0.4)
        until(self, "shows a tell")
        post, head = lamp(3.4, -1.0, 1.2)
        g3 = T("tell", 40).move_to([3.4, -1.75, 0])
        gplay(self, FadeIn(post), FadeIn(head), FadeIn(g3), run_time=0.5)
        gplay(self, head.animate.set_fill(TERRA), run_time=0.35)
        shot = Arrow([4.05, 0.7, 0], [5.9, 0.7, 0], color=INK, stroke_width=6, buff=0)
        gplay(self, GrowArrow(shot), run_time=0.4)
        until(self, "One enemy")
        box = crate(Iso(5.0, 1.45, 0.8), 0, 0, 0, s=1.1, built=False)
        a9 = T("A9", 40).move_to([3.7, 2.35, 0])
        gplay(self, FadeIn(box, shift=DOWN * 0.6), FadeIn(a9), run_time=0.6)
        finish(self)


class B09_Staircase(Scene):
    def construct(self):
        iso = Iso(-5.2, -2.3, 0.9)
        steps = []
        for i in range(6):
            steps.append(iso.box(i * 1.25, -i * 1.25, 0, 1.25, 1.25, 0.45 + i * 0.42,
                                 *((BOX_TOP, BOX_L, BOX_R) if i == 0 else (DESIGN_TOP, DESIGN_L, DESIGN_R))))
        gplay(self, LaggedStart(*[GrowFromEdge(s, DOWN) for s in steps], lag_ratio=0.15), run_time=1.0)
        until(self, "the block in level three")
        top3 = iso.p(2 * 1.25 + 0.62, -2 * 1.25 + 0.62, 0.45 + 2 * 0.42)
        sh = shield(top3[0], top3[1] + 0.55, 0.75)
        b = T("block", 38).move_to([top3[0] - 1.1, top3[1] + 1.45, 0])
        gplay(self, FadeIn(sh, shift=DOWN * 0.5), FadeIn(b), run_time=0.5)
        until(self, "the staff and ropes")
        top4 = iso.p(3 * 1.25 + 0.62, -3 * 1.25 + 0.62, 0.45 + 3 * 0.42)
        staff = VGroup(Line([top4[0] - 0.25, top4[1] + 0.1, 0], [top4[0] - 0.25, top4[1] + 1.6, 0], color=INK,
                            stroke_width=8), Dot([top4[0] - 0.25, top4[1] + 1.65, 0], radius=0.12, color=TERRA))
        rope = Line([top4[0] + 0.35, top4[1] + 0.1, 0], [top4[0] + 0.35, top4[1] + 1.9, 0], color=BOX_R, stroke_width=9)
        s = T("staff", 38).move_to([top4[0] + 0.1, top4[1] + 2.35, 0])
        gplay(self, Create(staff), Create(rope), FadeIn(s), run_time=0.5)
        until(self, "hearts rising")
        hx, hy = 3.6, 2.6
        hrt = heart(hx, hy, s=0.42)
        n3 = T("3", 48, bold=True).move_to([hx + 0.85, hy, 0])
        hl = T("hearts", 38).move_to([hx + 2.1, hy, 0])
        gplay(self, FadeIn(hrt), FadeIn(n3), FadeIn(hl), run_time=0.4)
        n7 = T("7", 48, bold=True).move_to([hx + 0.85, hy, 0])
        gplay(self, FadeOut(n3, shift=UP * 0.3), FadeIn(n7, shift=UP * 0.3), run_time=0.5)
        finish(self)


# ───────────────────────────── GDD 7: world and levels ─────────────────────────────
class B10_World(Scene):
    def construct(self):
        fig = framed("figures/world-map.png", 16 / 9, w=9.6, x=0, y=0.35)
        status = T("designed · constructed: drawn by code, not game art", 32).move_to([0, -2.9, 0])
        gplay(self, FadeIn(fig, shift=UP * 0.3), run_time=0.7)
        self.add(status)
        until(self, "his road home")
        home = Circle(radius=0.42, stroke_color=TERRA, stroke_width=7).move_to(fpt(fig, 0.81, 0.615))
        gplay(self, Create(home), run_time=0.6)
        finish(self)


class B12_Levels(Scene):
    def construct(self):
        fig = framed("figures/levels.jpg", 1600 / 804, w=11.0, x=0, y=0.3)
        status = T("Level 1: screenshot · Levels 2–6: designed, constructed: drawn by code", 32).move_to([0, -2.95, 0])
        gplay(self, FadeIn(fig, shift=UP * 0.3), run_time=0.7)
        self.add(status)
        cols = [(16 + 528 * c) / 1600 for c in range(3)]
        rows = [(14 + 394 * r) / 804 for r in range(2)]
        panels = {2: (1, 0), 3: (2, 0), 4: (0, 1), 5: (1, 1)}

        def box(n):
            c, r = panels[n]
            return frect(fig, cols[c] - 0.004, rows[r] - 0.006, cols[c] + 512 / 1600 + 0.004, rows[r] + 380 / 804)

        until(self, "a beetle")
        hi = box(2)
        gplay(self, Create(hi), run_time=0.45)
        for n, ph in [(3, "mushrooms"), (4, "archers"), (5, "shield guards")]:
            until(self, ph)
            gplay(self, Transform(hi, box(n)), run_time=0.4)
        finish(self)


class B13_Boss(Scene):
    def construct(self):
        title = T("Level 6 · Ambervale, after", 44).move_to([0, 2.85, 0])
        fig = framed("figures/boss-phases.jpg", 1600 / 366, w=12.2, x=0, y=0.85)
        status = T("designed · constructed: drawn by code, not game art", 32).move_to([0, -1.75, 0])
        self.add(title)
        gplay(self, FadeIn(fig, shift=UP * 0.3), run_time=0.7)
        self.add(status)
        until(self, "three phases")
        hi = frect(fig, 0.01, 0.05, 0.33, 0.97)
        gplay(self, Create(hi), run_time=0.35)
        gplay(self, hi.animate.shift(RIGHT * fig.W * 0.33), run_time=0.3)
        gplay(self, hi.animate.shift(RIGHT * fig.W * 0.33), run_time=0.3)
        until(self, "glows")
        glows = VGroup(*[Dot(fpt(fig, f, 1.0) + np.array([0, -0.4, 0]), radius=0.13, color=TERRA) for f in (0.17, 0.5, 0.83)])
        glabel = T("every attack glows first", 36).move_to([0, -2.65, 0])
        gplay(self, LaggedStart(*[GrowFromCenter(d) for d in glows], lag_ratio=0.3), FadeIn(glabel), run_time=0.6)
        finish(self)


# ───────────────────────────── GDD 8-11 ─────────────────────────────
class B14_Cards(Scene):
    def construct(self):
        cards = [paper(-4.9 + i * 1.25, 1.55, 1.0, 1.35) for i in range(5)]
        lines = [scribbles_on(c, n=2, gap=0.3) for c in cards]
        lab = T("14 story cards", 38).move_to([-2.4, 2.95, 0])
        gplay(self, LaggedStart(*[FadeIn(VGroup(c, l), shift=DOWN * 0.3) for c, l in zip(cards, lines)],
                                lag_ratio=0.15), FadeIn(lab), run_time=0.9)
        iso = Iso(-2.6, -2.7, 0.9)
        back, front = iso.open_box(0, 0, 0, 1.6, 1.6, 1.0)
        out = T("out", 40).move_to([-4.7, -1.75, 0])
        until(self, "those are out")
        gplay(self, FadeIn(back), FadeIn(front), FadeIn(out), run_time=0.4)
        group = VGroup(*[VGroup(c, l) for c, l in zip(cards, lines)], lab)
        gplay(self, group.animate.scale(0.35).move_to([-2.55, -1.7, 0]).set_opacity(0), run_time=0.7)
        until(self, "the levels alone")
        strip = Rectangle(width=5.4, height=0.34, fill_color="#9C8462", fill_opacity=1, stroke_color=INK,
                          stroke_width=4).move_to([3.3, -0.9, 0])
        castle = VGroup(Rectangle(width=0.8, height=0.7, fill_color=BAR1, fill_opacity=1, stroke_color=INK, stroke_width=4),
                        *[Rectangle(width=0.18, height=0.18, fill_color=BAR1, fill_opacity=1, stroke_color=INK,
                                    stroke_width=3).shift([-0.31 + k * 0.31, 0.44, 0]) for k in range(3)]).move_to([1.4, -0.31, 0])
        ridge = VGroup(Polygon([2.5, -0.73, 0], [3.3, 0.35, 0], [4.1, -0.73, 0], fill_color=BAR1, fill_opacity=1,
                               stroke_color=INK, stroke_width=4), Dot([3.3, 0.6, 0], radius=0.11, color=TERRA))
        crater = Ellipse(width=1.2, height=0.36, fill_color=DARK_L, fill_opacity=1, stroke_color=INK,
                         stroke_width=4).move_to([5.0, -0.55, 0])
        inl = T("in the levels", 38).move_to([3.3, -1.75, 0])
        gplay(self, FadeIn(strip), FadeIn(inl), run_time=0.4)
        gplay(self, LaggedStart(FadeIn(castle, shift=UP * 0.2), FadeIn(ridge, shift=UP * 0.2),
                                FadeIn(crater, shift=UP * 0.2), lag_ratio=0.35), run_time=0.9)
        finish(self)


class B15_Rudy(Scene):
    def construct(self):
        fig = framed("figures/rudy.jpg", 1600 / 1417, h=5.9, x=-2.55, y=0.05)
        gplay(self, FadeIn(fig, shift=UP * 0.3), run_time=0.7)
        name = T("Rudy", 48, bold=True).move_to([3.7, 2.35, 0])
        who = T("the player, ten", 34).move_to([3.7, 1.7, 0])
        st1 = T("generated frames,", 32).move_to([3.7, 1.0, 0])
        st2 = T("in the game at a7", 32).move_to([3.7, 0.5, 0])
        gplay(self, FadeIn(name), FadeIn(who), FadeIn(st1), FadeIn(st2), run_time=0.5)
        hi = frect(fig, 0.025, 0.025, 0.975, 0.57)
        gplay(self, Create(hi), run_time=0.45)
        until(self, "his generated frames")
        gplay(self, Transform(hi, frect(fig, 0.025, 0.615, 0.975, 0.975)), run_time=0.45)
        until(self, "Against him stands Voss")
        voss = T("Voss · designed", 34).move_to([3.7, -0.6, 0])
        rule = Line([2.3, -0.1, 0], [5.1, -0.1, 0], color=INK, stroke_width=4)
        gplay(self, Create(rule), FadeIn(voss), run_time=0.45)
        until(self, "four lost villagers")
        vill = T("4 villagers · designed", 34).move_to([3.7, -1.3, 0])
        gplay(self, FadeIn(vill), run_time=0.45)
        finish(self)


class B16_Palette(Scene):
    def construct(self):
        fig = framed("figures/cast.jpg", 1600 / 335, w=12.0, x=0, y=1.6)
        status = T("generated (Gemini app, Assignment 2)", 32).move_to([0, -0.05, 0])
        source = T("source: GDD.md section 10, planned palettes against Rudy's outline", 32).move_to([0, -3.12, 0])
        gplay(self, FadeIn(fig, shift=UP * 0.3), run_time=0.7)
        self.add(status, source)
        until(self, "Two planned colours")
        sw = []
        for x, col, lab in [(-3.6, "#3A2A24", "Rudy's outline"), (0.0, "#3F5E3A", "canopy 1.87"), (3.6, "#5E5A55", "dead wood 2.00")]:
            sq = RoundedRectangle(width=1.3, height=0.8, corner_radius=0.1, fill_color=col, fill_opacity=1,
                                  stroke_color=GHOST, stroke_width=3).move_to([x, -1.3, 0])
            t = T(lab, 36).move_to([x, -2.2, 0])
            sw.append((sq, t))
        gplay(self, FadeIn(sw[0][0]), FadeIn(sw[0][1]), run_time=0.4)
        gplay(self, LaggedStart(*[FadeIn(VGroup(s, t)) for s, t in sw[1:]], lag_ratio=0.4), run_time=0.6)
        until(self, "stay away from where he plays")
        away = VGroup(*[VGroup(s, t) for s, t in sw[1:]])
        gplay(self, away.animate.shift(RIGHT * 0.9 + UP * 0.35), run_time=0.5)
        note = T("kept away from his path", 34).move_to([0, -2.66, 0])
        gplay(self, FadeIn(note), run_time=0.35)
        finish(self)


class B17_Twins(Scene):
    def construct(self):
        spk = VGroup(Rectangle(width=0.5, height=0.7, fill_color=DARK_L, fill_opacity=1, stroke_color=INK, stroke_width=4),
                     Polygon([0.25, 0.35, 0], [0.85, 0.75, 0], [0.85, -0.75, 0], [0.25, -0.35, 0], fill_color=BAR1,
                             fill_opacity=1, stroke_color=INK, stroke_width=4)).move_to([-4.3, 0.2, 0])
        sl = T("sound", 40).move_to([-4.2, -1.3, 0])
        self.add(spk, sl)
        waves = [Arc(radius=0.6 + 0.45 * k, start_angle=-0.6, angle=1.2, color=INK, stroke_width=6).move_arc_center_to([-3.5, 0.2, 0])
                 for k in range(3)]
        twins = [VGroup(*[Line([0, 0, 0], [0.42 * np.cos(a), 0.42 * np.sin(a), 0], color=INK, stroke_width=6)
                          for a in np.linspace(0, 2 * np.pi, 7)[:-1]]).move_to([2.2, 1.4, 0]),
                 Circle(radius=0.38, fill_color=GHOST, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to([2.2, 0.2, 0]),
                 Square(0.66, fill_color=BOX_TOP, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to([2.2, -1.0, 0])]
        until(self, "six sound effects")
        gplay(self, LaggedStart(*[Create(w) for w in waves], lag_ratio=0.3), run_time=0.7)
        until(self, "each with a visual twin")
        tl = T("visual twin", 40).move_to([4.3, 0.2, 0])
        gplay(self, LaggedStart(*[FadeIn(t, scale=0.6) for t in twins], lag_ratio=0.3), FadeIn(tl), run_time=0.6)
        until(self, "so the game reads")
        cross = VGroup(Line([-5.0, 1.0, 0], [-3.6, -0.6, 0], color=INK, stroke_width=8),
                       Line([-5.0, -0.6, 0], [-3.6, 1.0, 0], color=INK, stroke_width=8))
        gplay(self, FadeOut(VGroup(*waves)), Create(cross), run_time=0.35)
        lights = VGroup(*[Dot(t.get_center() + np.array([0.7, 0, 0]), radius=0.1, color=TERRA) for t in twins])
        gplay(self, LaggedStart(*[GrowFromCenter(d) for d in lights], lag_ratio=0.3), run_time=0.4)
        finish(self)


# ───────────────────────────── GDD 12-16 ─────────────────────────────
class B18_Shelves(Scene):
    def construct(self):
        ys = [1.55, -0.25, -2.05]
        names = ["must", "should", "could"]
        counts = [8, 6, 2]
        planks = [Rectangle(width=9.6, height=0.2, fill_color=SHELF, fill_opacity=1, stroke_color=INK,
                            stroke_width=4).move_to([0.9, y, 0]) for y in ys]
        labels = [T(n, 40).move_to([-5.0, y + 0.3, 0]) for n, y in zip(names, ys)]
        self.add(*planks)
        for i, (ph, n, y) in enumerate(zip(["The musts", "Should:", "could:"], counts, ys)):
            until(self, ph)
            boxes = [Iso(-3.3 + k * 1.15, y + 0.12, 0.62).box(0, 0, 0, 1.0, 1.0, 0.95,
                                                               *((BOX_TOP, BOX_L, BOX_R) if i == 0 else (DESIGN_TOP, DESIGN_L, DESIGN_R)))
                     for k in range(n)]
            gplay(self, FadeIn(labels[i]), LaggedStart(*[FadeIn(b, shift=DOWN * 0.5) for b in boxes], lag_ratio=0.12),
                  run_time=0.4 + 0.08 * n)
        finish(self)


class B19_Out(Scene):
    def construct(self):
        shelf = Rectangle(width=8.4, height=0.2, fill_color=SHELF, fill_opacity=1, stroke_color=INK,
                          stroke_width=4).move_to([-2.0, 0.1, 0])
        self.add(shelf)
        cards = VGroup(*[paper(-5.0 + k * 0.12, 0.95, 1.1, 1.4) for k in range(3)])
        globe = VGroup(Circle(radius=0.7, fill_color=GHOST, fill_opacity=1, stroke_color=INK, stroke_width=4),
                       Ellipse(width=0.6, height=1.4, stroke_color=INK, stroke_width=3),
                       Line([-0.7, 0, 0], [0.7, 0, 0], color=INK, stroke_width=3)).move_to([-2.0, 0.9, 0])
        music = VGroup(paper(0.9, 0.95, 1.1, 1.4), Ellipse(width=0.36, height=0.26, fill_color=INK, fill_opacity=1,
                                                          stroke_width=0).move_to([0.75, 0.65, 0]),
                       Line([0.92, 0.67, 0], [0.92, 1.3, 0], color=INK, stroke_width=5))
        gplay(self, LaggedStart(FadeIn(cards), FadeIn(globe), FadeIn(music), lag_ratio=0.25), run_time=0.8)
        back, front = Iso(3.4, -2.9, 1.0).open_box(0, 0, 0, 1.7, 1.7, 1.1)
        out = T("out", 44).move_to([5.6, -1.3, 0])
        gplay(self, FadeIn(back), FadeIn(front), FadeIn(out), run_time=0.4)
        for obj, ph in [(cards, "story cards"), (globe, "world map"), (music, "new music")]:
            until(self, ph)
            gplay(self, obj.animate.scale(0.4).move_to([3.45, -1.7, 0]).set_opacity(0), run_time=0.6)
        finish(self)


class B20_Greybox(Scene):
    def construct(self):
        win = browser(-1.0, -0.35, 9.0, 4.4)
        iso = Iso(-4.4, -1.75, 0.6)
        spec = [(0, 0, 2.2, 1.4, 0.5), (2.2, -2.2, 1.6, 1.4, 1.1), (3.9, -3.9, 1.4, 1.4, 0.7), (5.4, -5.4, 2.0, 1.4, 1.4)]
        blocks = [grey_block(iso, x, y, 0, w, d, h) for (x, y, w, d, h) in spec]
        godot = T("Godot 4.7.2", 40).move_to([-3.9, 2.45, 0])
        gplay(self, FadeIn(win), FadeIn(godot), run_time=0.5)
        gplay(self, LaggedStart(*[FadeIn(b, shift=DOWN * 0.3) for b in blocks], lag_ratio=0.2), run_time=0.8)
        until(self, "sixty frames a second")
        fps = T("60 fps", 56, bold=True).move_to([5.0, 0.9, 0])
        gplay(self, FadeIn(fps, scale=0.8), run_time=0.45)
        until(self, "greybox before its art")
        gl = T("greybox", 40).move_to([5.0, -0.5, 0])
        art = [Polygon(*[iso.p(*q) for q in [(x, y, h), (x + w, y, h), (x + w, y + d, h), (x, y + d, h)]],
                       fill_color=ART, fill_opacity=1, stroke_color=INK, stroke_width=4) for (x, y, w, d, h) in spec]
        gplay(self, FadeIn(gl), run_time=0.3)
        gplay(self, LaggedStart(*[FadeIn(a) for a in art], lag_ratio=0.3), run_time=0.9)
        finish(self)


class B21_ArtRisk(Scene):
    def construct(self):
        KR = "#9C8462"   # deep kraft edges (the show-tell skill: connectors edged in ink fuse into one "text" blob)
        post = Rectangle(width=0.3, height=2.6, fill_color=DARK_L, fill_opacity=1, stroke_color=KR, stroke_width=4).move_to([0, -1.4, 0])
        base = Rectangle(width=2.2, height=0.3, fill_color=DARK_L, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to([0, -2.85, 0])
        pan_r = Rectangle(width=2.0, height=0.16, fill_color=BOX_L, fill_opacity=1, stroke_color=KR, stroke_width=3).move_to([3.3, -0.95, 0])
        beam = VGroup(Rectangle(width=7.0, height=0.2, fill_color=BOX_R, fill_opacity=1, stroke_color=KR, stroke_width=4).move_to([0, -0.05, 0]),
                      Line([-3.3, -0.15, 0], [-3.3, -0.87, 0], color=KR, stroke_width=4),
                      Line([3.3, -0.15, 0], [3.3, -0.87, 0], color=KR, stroke_width=4),
                      Rectangle(width=2.0, height=0.16, fill_color=BOX_L, fill_opacity=1, stroke_color=KR, stroke_width=3).move_to([-3.3, -0.95, 0]),
                      pan_r)
        self.add(base, post, beam)
        until(self, "fifteen backgrounds")
        art = T("art", 40).move_to([-3.3, 2.6, 0])
        sheets = VGroup(*[Rectangle(width=1.5, height=0.14, fill_color=PAGE_TOP if k % 2 else GHOST, fill_opacity=1,
                                    stroke_color=BAR1, stroke_width=2).move_to([-3.3, -0.8 + k * 0.17, 0]) for k in range(8)])
        gplay(self, FadeIn(art), LaggedStart(*[FadeIn(s, shift=DOWN * 0.4) for s in sheets], lag_ratio=0.1), run_time=0.8)
        tipped = VGroup(beam, sheets)
        gplay(self, Rotate(tipped, angle=0.12, about_point=np.array([0.0, -0.05, 0.0])), run_time=0.5)
        until(self, "play as a greybox first")
        grey = T("greybox", 40).move_to([3.3, 2.6, 0])
        c = np.array(pan_r.get_center(), dtype=float)
        iso = Iso(float(c[0]), float(c[1]) + 0.08, 0.34)
        tiles = VGroup(*[grey_block(iso, -0.6, -0.6, k * 0.18, 1.2, 1.2, 0.15) for k in range(5)])
        gplay(self, FadeIn(grey), LaggedStart(*[FadeIn(t, shift=DOWN * 0.4) for t in tiles], lag_ratio=0.12), run_time=0.7)
        gplay(self, Rotate(VGroup(tipped, tiles), angle=-0.12, about_point=np.array([0.0, -0.05, 0.0])), run_time=0.5)
        until(self, "test the web export early")
        win = browser(5.2, -2.3, 1.6, 1.1)
        tick = check(5.25, -2.45, s=0.18)
        gplay(self, FadeIn(win), run_time=0.3)
        gplay(self, Create(tick), run_time=0.3)
        finish(self)


class B22_Questions(Scene):
    def construct(self):
        xs = [-4.0, 0.0, 4.0]
        pages = [paper(x, 0.5, 1.7, 2.1) for x in xs]
        lines = [scribbles_on(p, n=3, gap=0.34) for p in pages]
        marks = [T("?", 72, bold=True).move_to([x, 2.3, 0]) for x in xs]
        gplay(self, LaggedStart(*[FadeIn(VGroup(p, l), shift=DOWN * 0.3) for p, l in zip(pages, lines)], lag_ratio=0.2),
              LaggedStart(*[FadeIn(m) for m in marks], lag_ratio=0.2), run_time=0.8)
        labels = [T("boss", 38).move_to([-4.0, -2.8, 0]), T("barrier", 38).move_to([0, -2.8, 0]),
                  T("hosting", 38).move_to([4.0, -2.8, 0])]
        tools = [heart(-4.0, -1.65, s=0.4), VGroup(shield(-0.55, -1.65, 0.7), shield(0.55, -1.65, 0.7)),
                 browser(4.0, -1.65, 1.6, 1.0)]
        for i, ph in enumerate(["seven hearts", "barrier", "web build will be hosted"]):
            until(self, ph)
            gplay(self, FadeIn(labels[i]), run_time=0.3)
        until(self, "how I'll find out")
        gplay(self, LaggedStart(*[FadeIn(t, shift=UP * 0.3) for t in tools], lag_ratio=0.25), run_time=0.8)
        finish(self)


# ───────────────────────────── the seven questions ─────────────────────────────
class B23_Compare(Scene):
    def construct(self):
        divider = VGroup(Line([0, 2.9, 0], [0, 1.85, 0], color=BAR1, stroke_width=4),
                         Line([0, 0.65, 0], [0, -2.9, 0], color=BAR1, stroke_width=4))   # broken at the shared row
        left = T("Super Mario Bros.", 40).move_to([-3.4, 2.6, 0])
        right = T("Walker Rudy", 40).move_to([3.4, 2.6, 0])
        self.add(divider)
        gplay(self, FadeIn(left), FadeIn(right), run_time=0.5)
        until(self, "a hit takes your power-up first")
        band = Rectangle(width=11.6, height=0.9, fill_color=CARD, fill_opacity=1, stroke_color=BAR1,
                         stroke_width=3).move_to([0, 1.25, 0]).set_z_index(1)
        shared = T("power-up first", 38).move_to([0, 1.25, 0]).set_z_index(2)
        ticks = VGroup(check(-4.8, 1.3, s=0.22), check(5.1, 1.3, s=0.22)).set_z_index(2)
        gplay(self, FadeIn(band), FadeIn(shared), run_time=0.4)
        gplay(self, Create(ticks), run_time=0.4)
        until(self, "committed sword swing")
        arc = Arc(radius=1.1, start_angle=PI * 0.75, angle=-PI * 0.9, color=INK, stroke_width=8).move_arc_center_to([2.4, -1.0, 0])
        blade = Line([2.4, -1.0, 0], [3.3, -0.35, 0], color=INK, stroke_width=10)
        tip = Dot([3.35, -0.3, 0], radius=0.1, color=TERRA)
        sl = T("sword", 38).move_to([2.4, -2.6, 0])
        gplay(self, Create(arc), Create(blade), GrowFromCenter(tip), FadeIn(sl), run_time=0.6)
        until(self, "no lives to lose")
        lives = VGroup(heart(4.6, -0.9, s=0.36), T("× 3", 40).move_to([5.35, -0.9, 0]))
        nl = T("no lives", 38).move_to([5.0, -2.6, 0])
        gplay(self, FadeIn(lives), FadeIn(nl), run_time=0.35)
        cross = VGroup(Line([4.1, -0.35, 0], [5.9, -1.45, 0], color=INK, stroke_width=8),
                       Line([4.1, -1.45, 0], [5.9, -0.35, 0], color=INK, stroke_width=8))
        gplay(self, Create(cross), run_time=0.4)
        finish(self)


class B24_FirstMinute(Scene):
    def construct(self):
        readme = report(-4.6, 0.6, w=1.9, h=2.4)
        rl = T("README", 38).move_to([-4.6, -1.15, 0])
        gplay(self, FadeIn(readme, shift=DOWN * 0.3), FadeIn(rl), run_time=0.5)
        until(self, "target role")
        role = T("gameplay programmer", 40).move_to([0, -2.7, 0])
        gplay(self, FadeIn(role), run_time=0.4)
        until(self, "Within a minute")
        win = browser(2.2, 0.55, 5.0, 3.1)
        link = Line([-3.5, 0.6, 0], [-0.4, 0.6, 0], color=INK, stroke_width=5)
        gplay(self, Create(link), FadeIn(win), run_time=0.6)
        ground = Line([0.1, -0.45, 0], [4.3, -0.45, 0], color=BOX_R, stroke_width=8)
        try:
            rudy = ImageMobject(_os.path.join(HERE, "stills/rudy-run-a.png"))
            rudy.height = 1.3
        except Exception:
            rudy = Rectangle(width=1.3, height=1.3, fill_color=BAR2, fill_opacity=1, stroke_width=0)
        rudy.move_to([0.8, 0.2, 0])
        clock = Circle(radius=0.5, fill_color=CARD, fill_opacity=1, stroke_color=INK, stroke_width=5).move_to([5.6, 2.55, 0])
        hand = Line([5.6, 2.55, 0], [5.6, 2.95, 0], color=INK, stroke_width=6)
        ml = T("1 minute", 38).move_to([3.9, 2.55, 0])
        gplay(self, Create(ground), FadeIn(rudy), FadeIn(clock), FadeIn(hand), FadeIn(ml), run_time=0.5)
        gplay(self, Rotate(hand, angle=-2 * PI, about_point=[5.6, 2.55, 0]), rudy.animate.shift(RIGHT * 2.4),
              run_time=1.4, rate_func=linear)
        finish(self)


class B25_Tags(Scene):
    def construct(self):
        shelf = Rectangle(width=11.0, height=0.22, fill_color=SHELF, fill_opacity=1, stroke_color=INK,
                          stroke_width=4).move_to([0, -1.9, 0])
        self.add(shelf)
        tags = [("a5 · shader", "a shader I wrote"), ("a6 · particles", "particle effects"), ("a7 · animation", "animation states")]
        xs = [-4.2, -1.2, 1.8]
        for (tag, ph), x in zip(tags, xs):
            until(self, ph)
            box = Iso(x - 0.55, -1.79, 0.8).box(0, 0, 0, 1.2, 1.2, 1.2)
            lab = T(tag, 34).move_to([x + 0.1, -2.65, 0])
            page, ticks = checklist(x + 0.1, 1.45, w=1.2, h=1.3, n=2)
            gplay(self, FadeIn(box, shift=DOWN * 0.6), FadeIn(lab), run_time=0.45)
            gplay(self, FadeIn(page), Create(ticks), run_time=0.4)
        until(self, "the sources file")
        src = report(4.7, -0.55, w=1.5, h=1.9)
        sl = T("SOURCES", 34).move_to([4.7, -2.65, 0])
        gplay(self, FadeIn(src, shift=DOWN * 0.4), FadeIn(sl), run_time=0.5)
        finish(self)


class B26_FirstPiece(Scene):
    def construct(self):
        card = framed("stills/end-card.png", 16 / 9, w=4.6, x=-3.6, y=0.9)
        cl = T("end of level 1", 34).move_to([-3.6, -0.85, 0])
        gplay(self, FadeIn(card, shift=UP * 0.3), FadeIn(cl), run_time=0.6)
        until(self, "level two as a greybox")
        iso = Iso(0.2, -0.75, 0.6)
        blocks = [grey_block(iso, 0, 0, 0, 2.0, 1.3, 0.5), grey_block(iso, 2.3, -2.3, 0.9, 1.2, 1.3, 0.25),
                  grey_block(iso, 3.8, -3.8, 0, 2.0, 1.3, 0.5)]
        l2 = T("level 2 greybox", 38).move_to([2.7, -2.3, 0])
        gplay(self, LaggedStart(*[FadeIn(b, shift=LEFT * 0.6) for b in blocks], lag_ratio=0.2), FadeIn(l2), run_time=0.8)
        until(self, "headless test")
        mid = iso.p(2.9, -1.65, 1.15)
        crack = Line(mid + np.array([-0.05, 0.12, 0]), mid + np.array([0.08, -0.14, 0]), color=INK, stroke_width=5)
        gplay(self, Create(crack), run_time=0.25)
        gplay(self, VGroup(blocks[1], crack).animate.shift(DOWN * 1.2).set_opacity(0.0), run_time=0.5)
        page, ticks = checklist(5.1, 2.1, w=1.3, h=1.35, n=2)
        tl = T("headless test", 36).move_to([2.8, 2.35, 0])
        gplay(self, FadeIn(page), FadeIn(tl), run_time=0.4)
        gplay(self, LaggedStart(*[Create(t) for t in ticks], lag_ratio=0.5), run_time=0.45)
        finish(self)


class B27_Learn(Scene):
    def construct(self):
        low = Rectangle(width=4.9, height=0.22, fill_color=SHELF, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to([-3.25, -1.75, 0])
        high = Rectangle(width=7.9, height=0.22, fill_color=SHELF, fill_opacity=1, stroke_color=INK, stroke_width=4).move_to([-1.75, 0.85, 0])
        self.add(low)
        old = [Iso(-4.9 + k * 1.5, -1.64, 0.8).box(0, 0, 0, 1.1, 1.1, 1.1) for k in range(3)]
        ll = T("learned: a5–a7", 36).move_to([1.4, -1.0, 0])
        gplay(self, LaggedStart(*[FadeIn(b, shift=DOWN * 0.4) for b in old], lag_ratio=0.2), FadeIn(ll), run_time=0.7)
        until(self, "New in the final")
        new = [Iso(-4.9 + k * 1.25, 0.96, 0.8).box(0, 0, 0, 1.0, 1.0, 1.0, DESIGN_TOP, DESIGN_L, DESIGN_R, sw=3)
               for k in range(6)]
        nl = T("new in the final", 36).move_to([4.4, 1.6, 0])
        gplay(self, FadeIn(high), FadeIn(nl), run_time=0.35)
        gplay(self, LaggedStart(*[FadeIn(b, shift=DOWN * 0.4) for b in new], lag_ratio=0.15), run_time=0.9)
        finish(self)


# ───────────────────────────── appendix ─────────────────────────────
class B29_Floor(Scene):
    def construct(self):
        iso = Iso(-5.0, -0.3, 1.0)
        tiles = [tile(iso, i * 1.05, -i * 1.05, built=True) for i in range(6)]
        arts = [Polygon(*[iso.p(*q) for q in [(i * 1.05, -i * 1.05, 0.32), (i * 1.05 + 1.25, -i * 1.05, 0.32),
                                               (i * 1.05 + 1.25, -i * 1.05 + 1.25, 0.32), (i * 1.05, -i * 1.05 + 1.25, 0.32)]],
                        fill_color=ART, fill_opacity=1, stroke_color=INK, stroke_width=4) for i in range(6)]
        gold = [Dot(iso.p(i * 1.05 + 0.62, -i * 1.05 + 0.62, 0.32) + np.array([0, 0.35, 0]), radius=0.12, color=TERRA)
                for i in (1, 2, 3, 4)]
        title = T("cut order", 40).move_to([0, 2.6, 0])
        gplay(self, LaggedStart(*[FadeIn(VGroup(t, a)) for t, a in zip(tiles, arts)], lag_ratio=0.12), FadeIn(title), run_time=0.9)
        gplay(self, LaggedStart(*[GrowFromCenter(g) for g in gold], lag_ratio=0.15), run_time=0.4)
        until(self, "late art becomes greybox")
        greys = [a.copy().set_fill(GREY_R) for a in arts]   # the darker greybox grey, so Gate V keeps its contrast
        gplay(self, *[Transform(a, g) for a, g in zip(arts[3:], greys[3:])], run_time=0.5)
        until(self, "villagers go")
        gplay(self, *[g.animate.shift(UP * 0.8).set_opacity(0) for g in gold], run_time=0.45)
        until(self, "levels six, five and four")
        gone = VGroup(*[VGroup(t, a) for t, a in zip(tiles[3:], arts[3:])])
        gplay(self, gone.animate.shift(DOWN * 1.6 + RIGHT * 0.6).set_opacity(0), run_time=0.6)
        until(self, "the floor")
        base = floor_line(-5.5, -0.1, -0.42)
        fl = T("floor: levels 1–3", 38).move_to([-2.8, -1.25, 0])
        gplay(self, Create(base), FadeIn(fl), run_time=0.5)
        finish(self)


class B30_Assets(Scene):
    def construct(self):
        fig = framed("figures/level-1.jpg", 1600 / 630, w=7.3, x=-2.3, y=0.65)
        st = T("generated art, in the game at a7", 32).move_to([-2.3, -1.2, 0])
        source = T("sources: PROJECT-BRIEF.md · A2 SOURCES.md", 32).move_to([-1.3, -3.0, 0])
        gplay(self, FadeIn(fig, shift=UP * 0.3), FadeIn(st), FadeIn(source), run_time=0.6)
        rows = [("Images", "Gemini"), ("Sound", "Firefly, ElevenLabs"), ("Music", "Suno"), ("Shader, effects", "mine")]
        phrases = ["Images come from Gemini", "sound from Firefly", "music from Suno", "The shader and effects"]
        y = 2.45
        for (a, b), ph in zip(rows, phrases):
            until(self, ph)
            ta = T(a, 36, bold=True).move_to([4.35, y, 0])
            tb = T(b, 34).move_to([4.35, y - 0.48, 0])
            gplay(self, FadeIn(ta), FadeIn(tb), run_time=0.35)
            y -= 1.22
        until(self, "nothing is bought")
        nb = T("nothing bought", 34).move_to([3.75, -2.3, 0])
        tick = check(5.75, -2.3, s=0.24)
        gplay(self, FadeIn(nb), Create(tick), run_time=0.45)
        finish(self)


# ───────────────────────────── outro ─────────────────────────────
class BOUT_Title(Scene):
    def construct(self):
        t1 = T("Walker Rudy: The Long Way Home", 60).move_to([0, 1.0, 0])
        t2 = T("A Final Project Pitch", 44).move_to([0, 0.05, 0])
        gplay(self, FadeIn(t1), FadeIn(t2), run_time=0.6)
        until(self, "By Shuai Zhang")
        rule = Line([-2.2, -0.75, 0], [2.2, -0.75, 0], color=INK, stroke_width=4)
        by = T("By Shuai Zhang", 44).move_to([0, -1.45, 0])
        dot = Dot([0, -0.75, 0], radius=0.11, color=TERRA)
        gplay(self, Create(rule), GrowFromCenter(dot), FadeIn(by), run_time=0.6)
        finish(self)
