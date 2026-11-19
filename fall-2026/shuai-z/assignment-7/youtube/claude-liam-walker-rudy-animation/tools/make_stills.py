#!/usr/bin/env python3
"""Compose the film's still evidence cards from real files, and copy the ones
the Remotion scenes read into the toolkit's public/ folder.

Every picture here is an existing engine capture (the committed frame strips in
captures/, all fixture captures of game/previews/, or the film's own Movie
Maker takes in capture/), the sheet itself, or a recorded log; this script only
crops, scales, places and labels. Strip crops are enlarged with nearest-
neighbour, so no pixel is blended. Code lines, log lines and the brief's and
TUNING.md's words are read from the files, not retyped: each quoted phrase is
asserted to be in its file, and each number printed under a strip frame is
parsed from that capture's own log.

    python3 tools/make_stills.py        # from the reel folder
"""
import os, re, shutil, subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

REEL = Path(__file__).resolve().parents[1]
A7 = REEL.parents[1]                        # fall-2026/shuai-z/assignment-7
ART = Path(os.environ.get("BRUTALIST_ART", Path.home() / "csye7270/brutalist.art"))   # the toolkit checkout
FONTS = ART / "runtime/fonts"
PUBLIC = ART / "runtime/remotion/public/reels" / REEL.name
OUT = REEL / "stills"
W, H = 3840, 2160
CREAM, INK, MUTED, ACCENT = (250, 249, 245), (61, 57, 41), (110, 100, 86), (217, 119, 87)
RED, GREEN, LINE = (164, 74, 50), (48, 110, 70), (214, 207, 194)
DARK, DTEXT, DMUTED = (32, 37, 49), (237, 241, 247), (190, 200, 215)
DBLUE, DGREEN, DYELLOW, DRED = (139, 199, 243), (174, 231, 209), (236, 224, 161), (255, 150, 130)
TUNING = (A7 / "TUNING.md").read_text()
REPORT = (A7 / "TEST-REPORT.md").read_text()
BRIEF = (A7 / "CHANGE-BRIEF.md").read_text()

BOX = (555, 410, 735, 570)                  # window px of the 1280 × 720 strip frames: Rudy at x 640, soles at y 560, the blade, the hitbox
RUN_BOX = (575, 420, 715, 570)              # narrower, for twelve run frames in a row


def font(name, size):
    paths = {"sans": FONTS / "Inter/static/Inter_28pt-Regular.ttf", "bold": FONTS / "Inter/static/Inter_28pt-Medium.ttf",
             "mono": FONTS / "PT_Mono/PTMono-Regular.ttf", "cjk": Path("/System/Library/Fonts/Hiragino Sans GB.ttc")}
    return ImageFont.truetype(str(paths[name]), size)


CJK = re.compile(r"([　-鿿＀-￯]+)")


def mtext(d, xy, text, f, fill):
    """Text that may hold the user's Chinese words: CJK runs in Hiragino Sans GB (macOS), the rest in f."""
    x, y = xy
    for run in CJK.split(text):
        if not run:
            continue
        ff = font("cjk", f.size) if CJK.fullmatch(run) else f
        d.text((x, y + (round(f.size * 0.04) if ff is not f else 0)), run, font=ff, fill=fill)
        x += d.textlength(run, font=ff)


def scaled(img, k, nearest=False):
    return img.resize((round(img.width * k), round(img.height * k)), Image.NEAREST if nearest else Image.LANCZOS)


def lines(path, a, b):
    return (A7 / path).read_text().splitlines()[a - 1:b]


def log(path):
    return (A7 / path).read_text().splitlines()


def quoted(text, *phrases):
    """Every phrase a card quotes must be written in its source."""
    for p in phrases:
        assert p in text, f"not in the source: {p!r}"


FRAME_RX = re.compile(r"^frame +(\d+) ticks +(\d+)- *(\d+) .*?clip (\w+) +pos ([\d.]+) cell +(\d+) sprite (\w+) +rig (\w+) +grip +([\d.-]+) .*?live (\w+) +swing +(-|\d+)")


def strip_log(name):
    """Per-frame state of a preview capture, from its own log: frame -> dict."""
    out = {}
    for l in log(f"logs/{name}.log"):
        m = FRAME_RX.match(l)
        if m:
            f, t0, t1, clip, pos, cell, spr, rig, grip, live, swing = m.groups()
            out[int(f)] = {"clip": clip, "cell": int(cell), "rig": rig == "true", "grip": float(grip), "live": live == "true",
                           "tick": None if swing == "-" else int(swing), "ticks": (int(t0), int(t1))}
    assert out, name
    return out


def strip(folder, frame, box, k):
    im = Image.open(A7 / f"captures/{folder}/frame{frame:08d}.png").convert("RGB").crop(box)
    return scaled(im, k, nearest=True)


def frame_of(mp4, n):
    """One frame of a capture, decoded from the hashed MP4."""
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(REEL / mp4), "-vf", f"select=eq(n\\,{n})", "-vframes", "1",
                          "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], capture_output=True, check=True).stdout
    return Image.frombytes("RGB", (W, H), raw)


def card(title, banner=None, dark=False):
    c = Image.new("RGB", (W, H), DARK if dark else CREAM)
    d = ImageDraw.Draw(c)
    if banner:
        bw = d.textbbox((0, 0), banner, font=font("bold", 50))[2] + 80
        d.rounded_rectangle((200, 110, 200 + bw, 210), radius=16, fill=ACCENT if dark else (48, 61, 52))
        d.text((240, 132), banner, font=font("bold", 50), fill=(255, 255, 255))
        d.text((200 + bw + 50, 128), title, font=font("bold", 66 if dark else 72), fill=DTEXT if dark else INK)
    else:
        d.text((200, 110), title, font=font("bold", 84), fill=DTEXT if dark else INK)
    return c, d


def foot(d, rows, dark=False):
    for i, t in enumerate(rows):
        d.text((200, H - 200 - 64 * (len(rows) - 1 - i)), t, font=font("sans", 40), fill=DMUTED if dark else MUTED)


def mlength(d, text, f):
    return sum(d.textlength(r, font=font("cjk", f.size) if CJK.fullmatch(r) else f) for r in CJK.split(text) if r)


def wrap(d, text, f, width):
    """Lines that fit `width`: Latin text breaks at spaces, Chinese between any two characters."""
    tokens = re.findall(r"[\u3000-\u9fff\uff00-\uffef]|[^\s\u3000-\u9fff\uff00-\uffef]+\s*|\s+", text)
    rows, cur = [], ""
    for tok in tokens:
        if mlength(d, (cur + tok).rstrip(), f) > width and cur.strip():
            rows.append(cur.rstrip()); cur = tok.lstrip()
        else:
            cur += tok
    rows.append(cur.rstrip())
    return rows


def para(d, x, y, text, f, width, fill, gap=1.38):
    for r in wrap(d, text, f, width):
        mtext(d, (x, y), r, f, fill)
        y += round(f.size * gap)
    return y


def phase(tick):
    if tick is None:
        return "no swing"
    return "startup" if tick <= 1 else "active" if tick <= 10 else "recovery" if tick <= 16 else "the end"


# ── B02 ─────────────────────────────────────────────────────────────────────
GAME_FRAMES = {"run": 120, "slash": 200}    # play-01-run.log: running on cell 2; swing tick 5, Grip 0, the hitbox live


def game_card():
    play = {int(m.group(1)): m.group(0) for m in re.finditer(r"^frame (\d+) .*$", (REEL / "capture/play-01-run.log").read_text(), re.M)}
    assert " clip run " in play[GAME_FRAMES["run"]] and " cell 2 " in play[GAME_FRAMES["run"]], play[GAME_FRAMES["run"]]
    assert all(f" {s} " in play[GAME_FRAMES["slash"]] for s in ("clip slash", "rig true", "grip 0.00", "live true", "swing 5")), play[GAME_FRAMES["slash"]]
    a = frame_of("capture/play-01.mp4", GAME_FRAMES["run"]).crop((1340, 1200, 2500, 1820))   # around Rudy, 4K pixels
    b = frame_of("capture/play-01.mp4", GAME_FRAMES["slash"]).crop((1340, 1200, 2500, 1820))
    k = 1480 / a.width
    a, b = scaled(a, k), scaled(b, k)
    c, d = card("Walker Rudy: Two Clips, One Authority")
    y = 280
    c.paste(a, (200, y)); c.paste(b, (W - 200 - b.width, y))
    for x, rows in ((200, [("run, sword_run · the loop", "bold"), ("Route: Sprite2D + AnimationPlayer frame track", "sans"),
                           ("Look/Sprite on a 4 × 4 sheet of his own frames", "sans"), ("2 cells, 8 a second, LOOP_LINEAR", "sans")]),
                    (W - 200 - b.width, [("slash · the committing action", "bold"), ("Route: cutout rig keyed as resource text", "sans"),
                                         ("Look/SlashRig: Lean, Grip, Blade, Body, Arc", "sans"),
                                         ("startup 2 ticks · active 9 · recovery 6, LOOP_NONE", "sans")])):
        yy = y + a.height + 40
        for t, f in rows:
            d.text((x, yy), t, font=font(f, 56 if f == "bold" else 48), fill=INK if f == "bold" else MUTED)
            yy += 76
    d.text((200, 1640), "One authority: Look/AnimationPlayer writes every animated property; rudy.gd's _pick_clip() alone tells it what to play.",
           font=font("bold", 50), fill=INK)
    foot(d, [f"Crops (1160 × 620 around Rudy) of frames {GAME_FRAMES['run']} and {GAME_FRAMES['slash']} of the film's own engine capture, capture/play-01.mp4: the real Main in Godot 4.7.2,",
             "GL Compatibility, Movie Maker at 3840 × 2160 and 30 fps, scripted input from a film-only driver on a copy; scaled 1.28×. Left: run, cell 2. Right: slash, swing tick 5."])
    return c


# RudyLook's cell table (game/content/rudy/rudy_look.gd lines 46–51): cell N shows CELLS[N].
CELLS = re.findall(r'&"(CHAR-[A-Z-]+)"', "\n".join(lines("game/content/rudy/rudy_look.gd", 46, 51)))
assert len(CELLS) == 16 and CELLS[1] == "CHAR-RUN-A" and CELLS[13] == "CHAR-SWORD-RUN-B", CELLS


# ── B04 ─────────────────────────────────────────────────────────────────────
def sheet_slicing():
    sheet = Image.open(A7 / "game/content/rudy/sheet/rudy_sheet.png").convert("RGBA")
    assert sheet.size == (1640, 1544), sheet.size
    k = 1480 / sheet.height
    bg = Image.new("RGBA", sheet.size, (236, 231, 220, 255))
    bg.alpha_composite(sheet)
    im = scaled(bg.convert("RGB"), k)
    c, d = card("The Sheet, and What Godot Drew From It", "SHEET + FIXTURE CAPTURES")
    x0, y0 = 200, 290
    c.paste(im, (x0, y0))
    cw, ch = 410 * k, 386 * k
    for i in range(5):
        d.line((x0 + i * cw, y0, x0 + i * cw, y0 + 4 * ch), fill=ACCENT, width=4)
        d.line((x0, y0 + i * ch, x0 + 4 * cw, y0 + i * ch), fill=ACCENT, width=4)
    for n in range(16):
        cx, cy = x0 + (n % 4) * cw, y0 + (n // 4) * ch
        hl = n in (1, 2, 12, 13)
        d.rounded_rectangle((cx + 10, cy + 10, cx + 96, cy + 70), radius=10, fill=(48, 61, 52) if hl else (61, 57, 41))
        d.text((cx + 22, cy + 14), f"{n:>2}", font=font("mono", 48), fill=(255, 255, 255))
        if hl:
            d.rectangle((cx + 3, cy + 3, cx + cw - 3, cy + ch - 3), outline=(48, 110, 70), width=8)
    x1 = x0 + im.width + 120
    d.text((x1, 290), "hframes 4 × vframes 4 → 16 cells of 410 × 386 px, row by row", font=font("bold", 48), fill=INK)
    d.text((x1, 360), "rudy_sheet.png, 1640 × 1544: Rudy's 16 Assignment 2 frames, unscaled, unedited", font=font("sans", 42), fill=MUTED)
    runlog = strip_log("run_preview_r0"); swlog = strip_log("run_preview_r0_sword")
    rows = [("run", "run/r0", runlog, ((30, 1), (34, 2))), ("sword_run", "run/r0-sword", swlog, ((30, 12), (34, 13)))]
    kk = 2.7
    y = 470
    for label, folder, lg, picks in rows:
        d.text((x1, y), f"{label} · what Godot drew", font=font("bold", 46), fill=INK)
        x = x1
        for f, cell in picks:
            assert lg[f]["cell"] == cell, (folder, f, lg[f])
            s = strip(folder, f, BOX, kk)
            c.paste(s, (x, y + 70))
            d.text((x, y + 80 + s.height), f"frame {f} · cell {cell}", font=font("bold", 42), fill=INK)
            d.text((x, y + 134 + s.height), CELLS[cell], font=font("mono", 36), fill=MUTED)
            x += s.width + 60
        y += 70 + round((BOX[3] - BOX[1]) * kk) + 220
    foot(d, ["Left: game/content/rudy/sheet/rudy_sheet.png (sheet SHA-256 4eba0d1e…), scaled 0.96×, over a light ground; the grid and numbers are drawn by this film's script.",
             "Right: fixture captures of game/previews/run_preview.tscn (captures/run/r0/, r0-sword/; c70c8367), crops enlarged 2.7× nearest; each cell from that capture's log."])
    return c


# ── B07 ─────────────────────────────────────────────────────────────────────
def registration():
    quoted(REPORT, "我亲手做过了。循环接缝没问题。实际玩也没问题。对位正常，背景正常。", "They do not say how many wraps I watched")
    c, d = card("Registration and the Seam: the Run Strip", "FIXTURE CAPTURES")
    k = 1.75
    y = 320
    for label, folder, name in (("run", "run/r0", "run_preview_r0"), ("sword_run", "run/r0-sword", "run_preview_r0_sword")):
        lg = strip_log(name)
        d.text((200, y + 90), label, font=font("bold", 50), fill=INK)
        x = 520
        for f in range(30, 42):
            s = strip(folder, f, RUN_BOX, k)
            c.paste(s, (x, y))
            wl = round((560 - RUN_BOX[1]) * k)      # the walk line, y 560 in the window
            d.line((x, y + wl, x + s.width, y + wl), fill=(230, 30, 30), width=6)
            cell = lg[f]["cell"]
            ab = {1: "A", 2: "B", 12: "A", 13: "B"}[cell]
            d.text((x + 8, y + s.height + 10), f"{f}", font=font("bold", 38), fill=INK)
            d.text((x + 8, y + s.height + 58), f"cell {cell} {ab}", font=font("sans", 34), fill=MUTED)
            x += s.width + 14
        y += round((RUN_BOX[3] - RUN_BOX[1]) * k) + 200
    d.text((520, y - 30), "Red line: the walk line, y 840 in the game (560 in the 1280 × 720 window). The cells change every 3–4 frames: 8, 8, 7, 8 … ticks.",
           font=font("sans", 40), fill=MUTED)
    y += 70
    mtext(d, (200, y), "My human checks (TEST-REPORT.md): “循环接缝没问题” — the cycle seam: no problem; “对位正常” — registration is normal.",
          font("bold", 50), GREEN)
    d.text((200, y + 80), "They do not say how many wraps I watched, or which form: the plain run, the sword run, or both.", font=font("sans", 46), fill=INK)
    foot(d, ["Fixture captures of game/previews/run_preview.tscn (Level 1, enemies frozen, the real Rudy; D read on tick 59), Movie Maker 1280 × 720 at 30 fps, run by Claude at",
             "shuai-z's request: captures/run/r0/ and r0-sword/ (c70c8367), frames 30–41, crops enlarged 1.75× nearest. Cells from logs/run_preview_r0.log and _r0_sword.log."])
    return c


# ── B10 ─────────────────────────────────────────────────────────────────────
def missing_property():
    probe = (A7 / "evidence/load-error-probe/README.md").read_text()
    quoted(probe, "**Nothing at all for the missing property**", "`probe_track.gd`")
    plog = log("evidence/load-error-probe/logs/probe_track_a7-wrapper.log")
    warn = next(l for l in plog if "couldn't resolve track" in l)
    m1 = log("logs/mutation_M1.txt")
    c, d = card("Why a Missing Property Fails Silently", "PROBE + HEADLESS TEST OUTPUT", dark=True)
    y = 280
    d.text((200, y), "1 · The probe: one clip, two bad tracks, played for 5 frames (evidence/load-error-probe/probe_track.gd, 2026-11-11)", font=font("bold", 48), fill=DTEXT)
    y += 90
    d.text((260, y), "Nobody:frame          a missing node", font=font("mono", 44), fill=DTEXT)
    d.text((1500, y), re.sub(r"\s+", " ", warn.strip()).split(" This warning")[0], font=font("mono", 38), fill=DYELLOW)
    y += 70
    d.text((260, y), "Sprite:no_such_prop   a missing property", font=font("mono", 44), fill=DTEXT)
    d.text((1500, y), "(nothing printed)", font=font("mono", 40), fill=DRED)
    y += 120
    d.text((200, y), "2 · The read-back asks each node for the property (game/tests/test_rudy_clips.gd, track_problems())", font=font("bold", 48), fill=DTEXT)
    y += 90
    for n, l in enumerate(lines("game/tests/test_rudy_clips.gd", 419, 421), 419):
        d.text((260, y), f"{n}", font=font("mono", 40), fill=(120, 130, 145))
        d.text((400, y), l.replace("\t", "    "), font=font("mono", 46), fill=DTEXT)
        y += 70
    d.text((260, y + 10), "(the default branch of the match on the track's type: a value track names a property, and `sub in node` asks the node for it)", font=font("sans", 38), fill=DMUTED)
    y += 60
    y += 70
    d.text((200, y), "3 · Mutation M1, in a fresh git worktree at f1680bfb (logs/mutation_M1.txt)", font=font("bold", 48), fill=DTEXT)
    y += 90
    for l in m1:
        if l.startswith(("-tracks/2/path", "+tracks/2/path")):
            d.text((260, y), l, font=font("mono", 42), fill=DRED if l.startswith("-") else DGREEN); y += 62
    fail = next(l for l in m1 if l.startswith("FAIL  1 "))
    d.text((260, y + 10), fail[:150], font=font("mono", 36), fill=DRED)
    res = next(l for l in m1 if l.startswith("RESULT"))
    d.text((260, y + 80), "exit 1 · " + res, font=font("mono", 40), fill=DRED)
    foot(d, ["The probe ran in a scratch copy through the A7 wrapper, which fails on the warning (evidence/load-error-probe/README.md); a missing property gives the wrapper",
             "nothing to fail on. track_problems() is the assignment's function, copied unchanged. Mutation M1: TEST-REPORT.md, Mutations; commit 6eab8f49."], dark=True)
    return c


# ── B14 ─────────────────────────────────────────────────────────────────────
def clock_strip():
    lg = strip_log("slash_preview_r1")
    states = log("logs/test_rudy_states_60fps.log")
    swing_line = next(l for l in states if l.startswith("PASS  swing on ") and "clip position = (ticks since the press)/60" in l)
    c, d = card("One Clock: the Picture and the Hitbox Change on the Same Ticks", "FIXTURE CAPTURES")
    k = 2.3
    x, y = 200, 300
    for f in (29, 30, 31, 32, 33, 34, 35, 38):
        s = strip("slash/r1", f, BOX, k)
        c.paste(s, (x, y))
        st = lg[f]
        d.text((x, y + s.height + 14), f"frame {f}", font=font("bold", 44), fill=INK)
        if st["tick"] is None:
            d.text((x, y + s.height + 70), "no swing" if f == 29 else "tick 17: over", font=font("sans", 38), fill=MUTED)
            d.text((x, y + s.height + 120), st["clip"], font=font("mono", 38), fill=MUTED)
        else:
            d.text((x, y + s.height + 70), f"tick {st['tick']} · {phase(st['tick'])}", font=font("sans", 38), fill=INK)
            d.text((x, y + s.height + 120), f"Grip {st['grip']:+.1f}°", font=font("mono", 38), fill=MUTED)
        d.text((x, y + s.height + 170), "hitbox LIVE" if st["live"] else "hitbox dead", font=font("bold", 40), fill=GREEN if st["live"] else RED)
        x += s.width + 18
    assert lg[30]["tick"] == 1 and not lg[30]["live"] and lg[31]["tick"] == 3 and lg[31]["live"] and lg[35]["tick"] == 11 and not lg[35]["live"]
    y = 300 + round((BOX[3] - BOX[1]) * k) + 290
    d.text((200, y), "The AnimationPlayer runs on the physics tick (callback_mode_process = 0), the tick rudy.gd decides the hitbox on:", font=font("sans", 46), fill=INK)
    d.text((200, y + 75), "the frame that first shows the sweep is the frame the hitbox opens, and the first recovery frame is the one it closes.", font=font("sans", 46), fill=INK)
    d.rounded_rectangle((200, y + 170, 3640, y + 330), radius=16, fill=DARK)
    d.text((240, y + 185), "HEADLESS TEST OUTPUT · logs/test_rudy_states_60fps.log", font=font("bold", 36), fill=DMUTED)
    d.text((240, y + 240), (swing_line[:150] + " …") if len(swing_line) > 152 else swing_line, font=font("mono", 34), fill=DGREEN)
    foot(d, ["Fixture captures of game/previews/slash_preview.tscn with --debug-collisions (the blue box is the sword's hitbox), Movie Maker 1280 × 720 at 30 fps, run by Claude at",
             "shuai-z's request: captures/slash/r1/ (66103310), crops enlarged 2.3× nearest. Tick, Grip and hitbox per frame from logs/slash_preview_r1.log (two ticks a frame)."])
    return c


# ── B15 (figure) ────────────────────────────────────────────────────────────
TRES = (A7 / "game/animations/rudy_animations.tres").read_text().splitlines()


def tres_track(path):
    i = next(n for n, l in enumerate(TRES) if l.endswith(f'path = NodePath("{path}")'))
    times = [float(x) for x in re.search(r"PackedFloat32Array\(([^)]*)\)", TRES[i + 4]).group(1).split(",")]
    trans = [float(x) for x in re.search(r"PackedFloat32Array\(([^)]*)\)", TRES[i + 5]).group(1).split(",")]
    vals = re.search(r'"values": \[(.*)\]', TRES[i + 7]).group(1)
    return times, trans, vals, i + 1


def phase_keys():
    c = Image.new("RGB", (3300, 1260), CREAM)
    d = ImageDraw.Draw(c)
    quoted(BRIEF, "| **Startup** | 0–1 | 0 – 2/60 s | dead |", "| **Active** | 2–10 | 2/60 – 11/60 s | **live** |",
           "| **Recovery** | 11–16 | 11/60 – 17/60 s | dead |", "| **End** | 17 | 17/60 s |")
    x0, x1, y0 = 120, 3180, 40
    tw = (x1 - x0) / 18
    d.text((60, y0), "The phase table (CHANGE-BRIEF.md §2.2): ticks at 60 a second, tick 0 = the press", font=font("bold", 50), fill=INK)
    yb = y0 + 90
    for a, b, name, sub, col in ((0, 2, "STARTUP", "hitbox dead", (205, 160, 96)), (2, 11, "ACTIVE", "hitbox live", (48, 110, 70)),
                                 (11, 17, "RECOVERY", "hitbox dead", (110, 120, 150)), (17, 18, "END", "", (61, 57, 41))):
        d.rectangle((x0 + a * tw, yb, x0 + b * tw - 4, yb + 120), fill=col)
        d.text((x0 + a * tw + 16, yb + 14), name, font=font("bold", 44 if b - a > 1 else 34), fill=(255, 255, 255))
        d.text((x0 + a * tw + 16, yb + 68), sub, font=font("sans", 34), fill=(255, 255, 255))
    for t in range(18):
        d.text((x0 + t * tw + tw / 2 - 18, yb + 132), f"{t}", font=font("mono", 40), fill=INK)
    keys = [0, 2, 5, 11, 17]
    for t in keys:
        x = x0 + t * tw + tw / 2
        d.polygon([(x, yb + 196), (x - 18, yb + 230), (x + 18, yb + 230)], fill=ACCENT)
    d.text((60, yb + 250), "▲ key times, derived from the table: 0, 2/60, 5/60, 11/60, 17/60 s", font=font("bold", 44), fill=ACCENT)
    y = yb + 340
    d.text((60, y), "The keys as written in game/animations/rudy_animations.tres (times ×60 = ticks)", font=font("bold", 48), fill=INK)
    y += 80
    hdr = ["track (line)", "tick 0", "2", "5", "11", "17", "transitions"]
    cols = [60, 1020, 1330, 1600, 1870, 2140, 2440]
    for x, h in zip(cols, hdr):
        d.text((x, y), h, font=font("bold", 42), fill=MUTED)
    y += 70
    for path, label in (("SlashRig/Lean/Grip:rotation_degrees", "Grip, degrees"), ("SlashRig/Lean:rotation_degrees", "Lean, degrees"),
                        ("SlashRig/Lean:position", "Lean, position"), ("SlashRig/Lean/Arc:modulate:a", "Arc alpha")):
        times, trans, vals, ln = tres_track(path)
        ticks = [round(t * 60, 4) for t in times]
        assert all(abs(t * 60 - round(t * 60)) < 1e-4 for t in times), (path, times)
        want = [0, 2, 4, 11, 17] if "Arc" in path else keys
        assert [round(t) for t in ticks] == want, (path, ticks)
        v = [s.strip() for s in re.split(r",\s*(?![^()]*\))", vals)]
        v = [s.replace("Vector2", "").replace(".0", "") for s in v]
        d.line((60, y - 12, 3240, y - 12), fill=LINE, width=2)
        d.text((60, y), f"{label} (times at :{ln + 4})", font=font("sans", 42), fill=INK)
        for j, s in enumerate(v):
            d.text((cols[1 + j], y), s, font=font("mono", 42), fill=INK)
        d.text((cols[6], y), " ".join(f"{t:g}" for t in trans), font=font("mono", 40), fill=MUTED)
        if "Arc" in path:
            d.text((cols[3], y + 50), "(this key at tick 4)", font=font("sans", 32), fill=MUTED)
        y += 96
    d.text((60, y + 10), "Transitions: 2 eases in (accelerating), 0.5 eases out (settling), 1 is linear. Tuning r1 changed one: Grip's key at tick 5, 2 → 0.5.",
           font=font("sans", 40), fill=MUTED)
    return c


# ── B17 ─────────────────────────────────────────────────────────────────────
def boundary_strip():
    first = strip_log("slash_preview_r1"); second = strip_log("slash_preview_r1_second_tick")
    quoted(BRIEF, "| F+1 = 31 | 2 | the first active key | Grip −60°; hitbox live, the blade still above his head |",
           "| F+5 = 35 | 10 | the last live tick | Grip +43.75°; arc α 0.14 |", "| F+8 = 38 | 16 | the last slash frame | Grip +15.83° |",
           "| F, the trigger | 1 | startup | the rig: blade raised back over his shoulder, Grip −67.5°",
           "| F+5 | 11 | recovery, the first frame | blade forward and down at +45°; arc gone; hitbox dead |",
           "| F+8 | 17 | the swing is over | the sword-idle Sprite again |")
    picks = [("startup → active", [(1, "slash/r1", first, 30, "rig, Grip −67.5°, dead"), (2, "slash/r1-second-tick", second, 31, "Grip −60°, live")]),
             ("active → recovery", [(10, "slash/r1-second-tick", second, 35, "Grip +43.75°, live"), (11, "slash/r1", first, 35, "Grip +45°, dead")]),
             ("the end", [(16, "slash/r1-second-tick", second, 38, "Grip +15.83°"), (17, "slash/r1", first, 38, "the sword-idle Sprite")])]
    c, d = card("The Strip at Each Phase Boundary", "FIXTURE CAPTURES · BOTH TICK OFFSETS")
    k = 2.6
    x = 200
    y = 330
    for gi, (name, pair) in enumerate(picks):
        d.text((x, y - 10), name, font=font("bold", 52), fill=INK)
        xx = x
        for tick, folder, lg, f, brief in pair:
            st = lg[f]
            if tick == 17:
                assert st["tick"] is None and st["clip"] == "sword_idle" and not st["rig"], st
            else:
                assert st["tick"] == tick, (folder, f, st)
            s = strip(folder, f, BOX, k)
            c.paste(s, (xx, y + 70))
            yy = y + 80 + s.height
            d.text((xx, yy), f"tick {tick}", font=font("bold", 50), fill=INK)
            d.text((xx, yy + 66), f"{'2nd' if 'second' in folder else '1st'} capture · frame {f}", font=font("sans", 36), fill=MUTED)
            d.text((xx, yy + 116), "brief: " + brief, font=font("sans", 34), fill=MUTED)
            logged = (f"log: {st['clip']}, Sprite back" if st["tick"] is None else
                      f"log: Grip {st['grip']:+.2f}°, {'LIVE' if st['live'] else 'dead'}")
            d.text((xx, yy + 166), logged, font=font("bold", 36), fill=GREEN)
            xx += s.width + 36
        x = xx + 90
    d.text((200, 1380), "1st capture: J read on a frame's first tick (frame N shows tick 2N − 59). 2nd capture: J read a tick later (tick 2N − 60).", font=font("sans", 44), fill=MUTED)
    d.text((200, 1560), "At 30 fps Movie Maker draws two ticks a frame, so one capture never shows tick 2, 10 or 16: the second capture reads J a tick later.",
           font=font("sans", 46), fill=INK)
    d.text((200, 1635), "Every logged value equals the brief's table (Revision 5's first-tick table, Revision 6's second-tick table). The pictures are Godot's.",
           font=font("sans", 46), fill=INK)
    foot(d, ["Fixture captures of game/previews/slash_preview.tscn with --debug-collisions, Movie Maker 1280 × 720 at 30 fps, run by Claude at shuai-z's request: captures/slash/r1/",
             "and r1-second-tick/ (66103310), crops enlarged 2.6× nearest. Ticks, Grip and hitbox from logs/slash_preview_r1.log and _r1_second_tick.log. Tables: CHANGE-BRIEF.md."])
    return c


# ── B18 ─────────────────────────────────────────────────────────────────────
def tuning_r1():
    v0 = "起手、出招、收招，三段分得开；剑扫过去没有卡一下；其余的肉眼没看出明显问题"
    v1 = "我用0.25倍速看的，保留这处改动，就这样了，没什么大问题"
    quoted(TUNING, v0, v1, "From frame 31 to 32 it turns 53°, from 32 to 33 only 5°", "Frame 33 (tick 7) shows Grip +25 instead of +5",
           "Frame 34 (tick 9), not a frame to read, shows +40", "the key at 5/60 (0°) changes its transition from 2.0 (ease-in) to 0.5 (ease-out)",
           "Claude's reading of r0, not something I observed", "批准，续跑去改",
           "Startup, active and recovery: the three phases are distinct. The sword does not catch as it sweeps across. Beyond that, I saw no obvious problem with my eyes.", "I watched it at 0.25 speed. Keep this change. That's it; no big problem.")
    r0, r1 = strip_log("slash_preview_r0"), strip_log("slash_preview_r1")
    assert r1[33]["grip"] == 25.0 and r1[34]["grip"] == 40.0 and r0[33]["grip"] == 5.0
    c, d = card("Tuning r1: a Reading, One Change, a Verdict", "FIXTURE CAPTURES")
    k = 2.0
    for row, (name, folder, lg, kept) in enumerate((("r0", "slash/r0", r0, (31, 32, 33, 35)), ("r1", "slash/r1", r1, (31, 32, 33, 34, 35)))):
        y = 280 + row * 450
        d.text((200, y + 120), name, font=font("bold", 64), fill=INK)
        x = 360
        for f in (31, 32, 33, 34, 35):
            if f in kept:
                s = strip(folder, f, BOX, k)
                c.paste(s, (x, y))
                d.text((x, y + s.height + 10), f"frame {f} · tick {lg[f]['tick']}", font=font("bold", 36), fill=INK)
                d.text((x, y + s.height + 56), f"Grip {lg[f]['grip']:+.1f}°", font=font("mono", 36), fill=MUTED)
            else:
                d.rectangle((x, y, x + 360, y + 320), outline=LINE, width=3)
                d.text((x + 60, y + 140), "not kept in r0", font=font("sans", 36), fill=MUTED)
            x += 360 + 40
    xs = 360 + 5 * 400 + 40
    para(d, xs, 300, "r0 → r1: one change, proposed by Claude and approved by shuai-z (“批准，续跑去改”): Grip's key at tick 5 eases out, transition 2.0 → 0.5. "
         "No key time or value changed.", font("sans", 42), W - 200 - xs, INK, 1.32)
    para(d, xs, 760, "Claude's prediction, before the capture: Grip +25° on frame 33, +40° on frame 34. Logged in r1: +25.00 and +40.00.",
         font("sans", 42), W - 200 - xs, GREEN, 1.32)
    colw = 1640
    y = 1200
    yl = para(d, 200, y, "shuai-z, first, before Claude read a frame:", font("bold", 42), colw, INK)
    yl = para(d, 200, yl, "“" + v0 + "”", font("sans", 42), colw, INK)
    yl = para(d, 200, yl + 6, "Claude's translation: Startup, active and recovery: the three phases are distinct. The sword does not catch as it sweeps across. Beyond that, I saw no obvious problem with my eyes.", font("sans", 38), colw, MUTED)
    yl = para(d, 200, yl + 24, "shuai-z, after r1, in the game at --time-scale 0.25:", font("bold", 42), colw, INK)
    yl = para(d, 200, yl, "“" + v1 + "”", font("sans", 42), colw, INK)
    yl = para(d, 200, yl + 6, "Claude's translation: I watched it at 0.25 speed. Keep this change. That's it; no big problem.", font("sans", 38), colw, MUTED)
    xr = 200 + colw + 160
    yr = para(d, xr, y, "Claude's reading of r0 (a claim, not a check):", font("bold", 42), W - 200 - xr, INK)
    yr = para(d, xr, yr, "frames 31 → 32 turn 53°, 32 → 33 only 5°: a near-stop, because both keys around tick 5 eased in. shuai-z saw no catch. "
              "The two readings disagree, and neither was overruled.", font("sans", 42), W - 200 - xr, INK)
    yr = para(d, xr, yr + 24, "Driven by Claude's reading, not by something shuai-z observed in play: the observation-driven revision the assignment asks for is still owed.",
              font("bold", 42), W - 200 - xr, RED)
    foot(d, ["Fixture captures of game/previews/slash_preview.tscn, Movie Maker 1280 × 720 at 30 fps, run by Claude at shuai-z's request: captures/slash/r0/ (c70c8367) and r1/",
             "(66103310), crops enlarged 2× nearest; Grip from each capture's log. Verdicts, reading, prediction and comparison: TUNING.md (sessions 18, 18b, 18c)."])
    return c


# ── B23 ─────────────────────────────────────────────────────────────────────
def count(path):
    L = log(path)
    r = next(l for l in reversed(L) if l.startswith("RESULT"))
    return r


def tests():
    c, d = card("What the Read-Backs Proved", "HEADLESS TEST OUTPUT", dark=True)
    clips = log("logs/test_rudy_clips_60fps.log")
    y = 270
    d.text((200, y), "$ scripts/run-test.sh test_rudy_clips.tscn 60", font=font("mono", 44), fill=DBLUE)
    d.text((2500, y), count("logs/test_rudy_clips_60fps.log").replace("RESULT ", ""), font=font("mono", 44), fill=DGREEN)
    y += 74
    for key in ("PASS  1 every track", "PASS  2 key times", "PASS  3 loop_mode", "PASS  4 every frame track", "PASS  11 every clip's step", "PASS  7 the library"):
        l = next(x for x in clips if x.startswith(key))
        l = l.split("  (")[0]
        d.text((260, y), (l[:128] + " …") if len(l) > 130 else l, font=font("mono", 34), fill=DTEXT)
        y += 52
    neg = sum(1 for x in clips[clips.index("NEGATIVE") + 2:] if x.startswith("PASS"))
    d.text((260, y), f"NEGATIVE: {neg} damaged in-memory copies, each failing its own check; a control copy passes", font=font("mono", 34), fill=DYELLOW)
    assert neg == 30, neg
    y += 100
    rows = [("test_rudy_states.tscn 60", "logs/test_rudy_states_60fps.log", "the real Main, key events only: 20 scenarios; 54 of 58 transitions reached, 4 listed"),
            ("test_rudy_edges.tscn 60", "logs/test_rudy_edges_60fps.log", "E1 re-press on ticks 1,2,3 · 10,11,12 · 16,17,18; E3 a hit on 1,2,3 · 10,11,12 · 16; E2, E4–E7"),
            ("test_rudy_edges.tscn 30", "logs/test_rudy_edges_30fps.log", "E1 and E2 at 30 fps, at both tick offsets"),
            ("test_rudy_pin.tscn 60", "logs/test_rudy_pin_60fps.log", "the pin: T1, T2 and T6 re-pinned in their own commit (e45658e6), as the brief predicted"),
            ("checks.tscn 60 · tint 30/60/144 · sparks · dust", "logs/checks_60fps.log", "every earlier test at its count: 141, 15 × 3, 108, 14, 61, 14")]
    for cmd, path, what in rows:
        r = count(path).replace("RESULT ", "") if "checks" not in cmd else "141 PASS · 0 FAIL"
        if "checks" in cmd:
            L = log(path)
            assert sum(1 for l in L if l.startswith("PASS")) == 141 and not any(l.startswith("FAIL") for l in L)
        d.text((200, y), "$ scripts/run-test.sh " + cmd, font=font("mono", 42), fill=DBLUE)
        d.text((2500, y), r[:46], font=font("mono", 40), fill=DGREEN)
        d.text((260, y + 60), what, font=font("sans", 38), fill=DMUTED)
        y += 140
    foot(d, ["Recorded headless output, Godot 4.7.2 --headless through scripts/run-test.sh at a pinned --fixed-fps (the logs named above), committed with each step; TEST-REPORT.md",
             "reran every test at 09ce1cb7 with the same counts. Headless runs read structure and state; they draw nothing (B25)."], dark=True)
    return c


# ── B24 ─────────────────────────────────────────────────────────────────────
def mutations():
    c, d = card("The Four Mutations, Each in a Worktree", "HEADLESS TEST OUTPUT", dark=True)
    rows = [("C0", "control: no change"), ("M1", "slash track 2's subname rotation_degrees → rotation_degree"),
            ("M2", "run's loop_mode 1 (LOOP_LINEAR) → 0 (LOOP_NONE)"), ("M3", "run's first frame key 1 → 16, hframes × vframes"),
            ("M4", "game/.godot deleted, then --import from the empty cache")]
    y = 280
    for m, what in rows:
        L = log(f"logs/mutation_{m}.txt")
        ex = next(l for l in L if l.startswith("exit "))
        res = next(l for l in L if l.startswith("RESULT"))
        bad = ex != "exit 0"
        d.text((200, y), m, font=font("bold", 60), fill=DRED if bad else DGREEN)
        d.text((380, y + 8), what, font=font("bold", 46), fill=DTEXT)
        d.text((2600, y + 8), f"{ex} · {res.replace('RESULT ', '')}", font=font("mono", 40), fill=DRED if bad else DGREEN)
        diff = [l for l in L if l[:1] in "+-" and not l.startswith(("---", "+++"))]
        fail = next((l for l in L if l.startswith("FAIL")), None)
        yy = y + 76
        for l in diff[:2]:
            d.text((420, yy), l[:110], font=font("mono", 34), fill=DRED if l.startswith("-") else DGREEN); yy += 48
        if fail:
            d.text((420, yy), (fail[:140] + " …") if len(fail) > 142 else fail, font=font("mono", 32), fill=DYELLOW); yy += 48
        y = yy + 40
    quoted(REPORT, "**Why M4 does not fail.** The rig is keyed as resource text, not imported")
    d.text((200, y + 10), "Why M4 passes, as predicted: the rig is keyed as resource text, not imported, so no clip, key or loop mode lives in the import cache.",
           font=font("sans", 44), fill=DTEXT)
    foot(d, ["Each run in a fresh git worktree at f1680bfb beside the repository, thrown away after (logs/mutation_C0–M4.txt and their _test_rudy_clips_60fps.log; evidence/mutations/;",
             "commit 6eab8f49). Claude ran them in the conversation. TEST-REPORT.md, Mutations and Fresh cache."], dark=True)
    return c


# ── B25 ─────────────────────────────────────────────────────────────────────
def headless_limits():
    P = log("logs/probe_headless_facts_60fps.log")
    adv = next(l for l in P if l.startswith("FACT1 advances: 12 physics ticks"))
    pos = next(l for l in P if l.startswith("FACT1 advances: clip position"))
    draws = next(l for l in P if l.startswith("FACT1 draws"))
    quoted(REPORT, "我亲手做过了。循环接缝没问题。实际玩也没问题。对位正常，背景正常。", "跑过了，没问题")
    c, d = card("What No Headless Run Can Show", "HEADLESS LOG + FIXTURE CAPTURE")
    d.rounded_rectangle((200, 290, 2320, 900), radius=20, fill=DARK)
    d.text((240, 315), "HEADLESS · logs/probe_headless_facts_60fps.log (dummy renderer)", font=font("bold", 40), fill=DMUTED)
    y = 390
    for l in (adv, pos[:92] + " …", draws):
        d.text((240, y), l, font=font("mono", 36), fill=DGREEN if "draws" not in l else DRED)
        y += 64
    para(d, 240, y + 30, "Headless, the clip advances and its structure can be read, tick by tick. Nothing is drawn: the frame cannot be read back.",
         font("sans", 42), 2040, DTEXT)
    s = strip("slash/r1", 33, BOX, 3.2)
    c.paste(s, (2420, 290))
    d.text((2420, 290 + s.height + 14), "The same slash, drawn: a windowed Movie Maker run", font=font("bold", 38), fill=INK)
    d.text((2420, 340 + s.height + 14), "(fixture capture r1, frame 33, tick 7, enlarged 3.2×)", font=font("sans", 34), fill=MUTED)
    y = 1100
    d.text((200, y), "So these rest on eyes: whether the slash reads, whether the run wraps without a visible seam, whether the action feels committed.",
           font=font("bold", 46), fill=INK)
    y += 100
    mtext(d, (200, y), "shuai-z's human checks: “我亲手做过了。循环接缝没问题。实际玩也没问题。对位正常，背景正常。” · the editor run: “跑过了，没问题”",
          font("sans", 46), GREEN)
    y += 80
    d.text((200, y), "Claude's translation: I did them myself. The cycle seam: no problem. Actual play: no problem too. Registration is normal, the background is normal.",
           font=font("sans", 40), fill=MUTED)
    y += 90
    d.text((200, y), "Not stated: how many wraps, which form, which interrupts in which phase, which stretches of the level.", font=font("sans", 46), fill=INK)
    foot(d, ["evidence/headless-facts-probe/ (probe_headless_facts.gd, 2026-11-13; CLAUDE.md, Headless facts). Fixture: captures/slash/r1/frame00000033.png, run by Claude at",
             "shuai-z's request. The human checks: TEST-REPORT.md, 2026-11-16, in shuai-z's words with Claude's translation."])
    return c


def main():
    OUT.mkdir(exist_ok=True)
    PUBLIC.mkdir(parents=True, exist_ok=True)
    figures = {"phase-keys.png": phase_keys()}
    for name, im in figures.items():
        im.save(OUT / name)
        shutil.copy(OUT / name, PUBLIC / name)
    for name, fn in [("game-card.png", game_card), ("sheet-slicing.png", sheet_slicing), ("registration.png", registration),
                     ("missing-property.png", missing_property), ("clock-strip.png", clock_strip), ("boundary-strip.png", boundary_strip),
                     ("tuning-r1.png", tuning_r1), ("tests.png", tests), ("mutations.png", mutations), ("headless-limits.png", headless_limits)]:
        if name == "game-card.png" and not (REEL / "capture/play-01.mp4").exists():
            print("skip game-card.png: capture/play-01.mp4 not made yet"); continue
        fn().save(OUT / name)
    print(f"stills written to {OUT}; public copies of {len(figures)} figures in {PUBLIC}")


if __name__ == "__main__":
    main()
