#!/usr/bin/env python3
"""Author beat_sheet.json for the walker-rudy Assignment 7 godot-gamedev film.

Every code excerpt is cut by line range from game/ here, so the text on screen
is the text in the file. Timing fields (durationSeconds, cue times) are filled
later by build_reel.py from the measured narration. Gameplay frame numbers are
the frames of capture/play-0N.mp4, read from capture/play-0N-run.log.

    python3 tools/make_sheet.py        # from the reel folder
"""
import json
from pathlib import Path

REEL = Path(__file__).resolve().parents[1]
A7 = REEL.parents[1]
PUB = "reels/claude-liam-walker-rudy-animation"   # Remotion public/ subfolder for this reel's figures
TITLE = "A Run and a Slash for Walker Rudy."
SLUG = "claude-liam-walker-rudy-animation"
REV = "775c14c"
FULL_REV = "775c14c3d3f60d82d12a32264ba565683c9fb0da"
PROJECT = f"Walker Rudy · game/ @ {REV}"
TOPIC = "WALKER-RUDY · ANIMATION IN GODOT 4.7"
CHIP = "SCRIPTED INPUT · a film-only driver on a copy presses Enter, move, jump and slash"
WHO = "CAPTURED BY CLAUDE AT SHUAI-Z'S REQUEST"
CHIPS = (CHIP, WHO)


def lines(path, a, b):
    return "\n".join((A7 / "game" / path).read_text().splitlines()[a - 1:b])


def code(bid, act, path, a, b, title, narration, cues, notes, output, components, font=25):
    return {
        "beat_id": bid, "act": act, "narration_text": narration, "components": components,
        "shot": {"type": "REMOTION", "lane": "code", "remotion": {"pattern": "GodotDevWorkbench", "props": {
            "mode": "code", "title": title, "project": PROJECT, "path": "res://" + path,
            "source": f"Source: assignment-7/game/{path}, lines {a}–{b} (verbatim). Godot editor reconstruction.",
            "code": lines(path, a, b), "startLine": a, "codeFontSize": font,
            "inspectorLabel": "Source notes — not Inspector values",
            "notes": [{"label": k, "value": v} for k, v in notes],
            "output": output}},
            "cue_phrases": [{"phrase": p, "line": ln, "label": lb} for p, ln, lb in cues]},
        "excerpt": {"project": "game", "path": path, "start_line": a, "end_line": b},
    }


def figure(bid, act, title, status, image, source, cards, cues, narration, components=()):
    return {"beat_id": bid, "act": act, "narration_text": narration, "components": list(components),
            "shot": {"type": "REMOTION", "lane": "card", "remotion": {"pattern": "GodotDesignFigure", "props": {
                "title": title, "status": status, "image": f"{PUB}/{image}", "imageLabel": "",
                "excerpt": "", "source": source, "cards": [{"label": a, "text": b} for a, b in cards]}},
                "cue_cards": [[p, k] for p, k in cues]}}


# Stills whose engine images fill most of the frame: the whole-frame ink average measures the pictures, so the
# contrast check is made on the card's own title instead (normalised boxes).
TITLE_REGIONS = {}
for name in ("game-card", "sheet-slicing", "registration", "clock-strip", "boundary-strip", "tuning-r1", "headless-limits"):
    TITLE_REGIONS[name + ".png"] = [0.052, 0.05, 0.62, 0.098]


def still(bid, act, image, observation, narration, components=()):
    qc = {"full_bleed": False}
    if image in TITLE_REGIONS:
        qc.update({"contrast_regions": [{"label": "card title", "box": TITLE_REGIONS[image]}],
                   "contrast_reason": "Engine captures fill much of this card; the whole-frame ink average measures them, not text. The title is measured locally."})
    return {"beat_id": bid, "act": act, "narration_text": narration, "components": list(components),
            "shot": {"type": "VIDEO", "lane": "evidence", "source": "own", "treatment": "none",
                     "evidence_media": f"stills/{image}", "still_plan": {"image": f"stills/{image}"},
                     "observation": observation},
            "qc": qc}


def gameplay(bid, act, segments, observation, narration, components, chips=CHIPS):
    return {"beat_id": bid, "act": act, "components": components, "narration_text": narration,
            "shot": {"type": "VIDEO", "lane": "gameplay", "source": "own", "treatment": "none", "evidence_media": f"media/{bid}.mp4",
                     "capture_plan": {"segments": segments, "chips": list(chips)}, "observation": observation},
            "qc": {"full_bleed": True, "full_bleed_reason": "Engine capture renders edge to edge at 3840x2160; the film's chips sit inside the title-safe inset. Only the edge-bleed check is waived."}}


def seg(take, a, b, speed=1.0, label="", crop=None):
    d = {"capture": take, "from": a, "to": b, "speed": speed, "label": label}
    if crop:
        d["crop"] = list(crop)
    return d


# 16:9 regions (x, y, w, h) of the 4K capture, shown enlarged: the camera keeps Rudy at x 1920, his soles at y 1680.
STAND = (1152, 1080, 1536, 864)    # 2.5× around Rudy standing or running: his whole body, the blade, a goblin behind him
APEX = (960, 640, 1920, 1080)      # 2× around a jump: the top of the jump and the ground

B = []

# ── walker bookends ─────────────────────────────────────────────────────────
B.append({"beat_id": "B00", "act": "cold open — the Walker ask", "components": [],
  "role_note": "walker modifier B00. Reconstructed prompt, said out loud; not a transcript.",
  "narration_text": "Jambo, this is Liam, in for Bear. That prompt is an illustrative reconstruction, not something anyone typed. "
                    "What is real is underneath it: walker-rudy, the 2D game shuai-z started in Assignment 2, now animated. "
                    "A run cycle sliced from a sprite sheet of Rudy's own frames, and a sword slash on a cutout rig.",
  "shot": {"type": "REMOTION", "lane": "bookend", "remotion": {"pattern": "ClaudeComposerAsk", "props": {
    "greeting": "Jambo, Liam", "topic": TOPIC, "segment": TITLE,
    "command": "Please use Walker to convert my game design document about Walker Rudy — a chibi boy who crosses the Harvest Fields with a "
               "sword — into two animations: a looping run cycle sliced from a sprite sheet of his own frames, and a sword slash on a cutout "
               "rig whose startup, active and recovery frames come from a phase table, each clip read back by a test, driven by one state "
               "machine, and judged in a frame strip and in play.",
    "runningText": "reconstructed prompt — illustrative, not a transcript…",
    "output": [f"Repo walker-rudy · assignment-7/game at {REV} · Godot 4.7.2 · GL Compatibility · one 2D game.",
               "Built: run and sword_run (a 4 × 4 sheet, a frame track) and slash (a cutout rig keyed as resource text), one AnimationPlayer.",
               "Clips and tests: scoped claude -p sessions · every verdict and approval: shuai-z · captures: Claude, at shuai-z's request."],
    "folderLabel": "@NikBearBrown", "modelLabel": "Opus 5.5", "effortLabel": "High"}}}})

B.append({"beat_id": "B01", "act": "BLUF — what was actually built", "components": [], "lead_silence_s": 0.8,
  "role_note": "EXECUTIVE-SUMMARY LAW. The correction is the misconception: feel is designed in frames, not seconds.",
  "qc": {"sparse_by_design": True, "sparse_reason": "BrutalistHesitantWriter types the overview token by token; mid-beat frames are mostly cream by design."},
  "narration_text": "A run and a slash for Walker Rudy, keyed from a table, and designed in frames, not seconds. The slash is seventeen "
                    "physics ticks: two to wind up, nine that can hit, six to recover. Every key time comes from that table, a test reads "
                    "every key back, and shuai-z's eyes, not a test, judged whether it reads.",
  "shot": {"type": "REMOTION", "lane": "bookend", "remotion": {"pattern": "BrutalistHesitantWriter", "props": {
    "text": "A run and a slash for Walker Rudy,\nkeyed from a table,\ndesigned in seconds.",
    "triggerWords": "seconds", "replacementWords": "frames",
    "seed": "walker-rudy-animation-bluf-2026-11-16", "face": "serif", "fontSize": 112, "lineSpacing": 1.4,
    "align": "center", "charMs": 24, "jitter": 6, "mistakeRate": 3, "hesitateWithin": 1, "hesitateBetween": 4, "banner": ""}}}})

# ── the game and the two clips ──────────────────────────────────────────────
B.append(still("B02", "the game, both clips, their routes", "game-card.png",
  "Two crops of the film's own Movie Maker capture of the real Main at 775c14c (play-01): Rudy running on cell 2 of the sheet, and "
  "Rudy mid-slash on the cutout rig; beside them the two clips, their routes, nodes, which loops and which commits, and the one authority.",
  "Walker Rudy is a 2D side-scroller in Godot four point seven, on the Compatibility renderer. This assignment adds two clips. Run, with "
  "its sword form, is the loop: a Sprite 2D whose frame an Animation Player keys, cut from a sheet of Rudy's own frames. Slash is the "
  "committing action: a cutout rig keyed as resource text, with startup, active and recovery. One Animation Player plays both, and only "
  "Rudy's state machine tells it what to play.", ["run-cycle", "slash-rig", "state-machine"]))

# ── clip 1: the sheet, its slicing, the frame track ─────────────────────────
B.append(code("B03", "the sheet and its slicing", "content/rudy/rudy.tscn", 31, 38, "The Sheet, Sliced by Two Numbers",
  "The sheet first. This is the Sprite 2D under Look, in Rudy's scene. Its texture is the whole sheet: sixteen frames in one image. Two "
  "numbers slice it: h-frames four, v-frames four. That makes a grid of sixteen cells, numbered row by row from zero, and which cell is "
  "frame three is decided here, by the slicing, not by the picture. Scale one half, and the same offset every frame had, so his soles "
  "land on the origin in every cell.",
  [("texture is the whole sheet", 34, "texture = rudy_sheet.png, 1640 × 1544"), ("h-frames four", 37, "hframes = 4: four columns"),
   ("v-frames four", 38, "vframes = 4: four rows → cells 0–15"), ("Scale one half", 33, "scale 0.5: 2 texture px per game px"),
   ("same offset", 36, "offset (−205, −370): his soles on the origin")],
  [("Sheet", "rudy_sheet.png, 1640 × 1544"), ("Cells", "16; the last is 15"), ("Built by", "claude -p sessions 3, 5")],
  ["game/content/rudy/rudy.tscn · Look/Sprite"], ["run-cycle"], font=30))
B.append(still("B04", "result — the sheet, and what Godot drew from it", "sheet-slicing.png",
  "The sheet game/content/rudy/sheet/rudy_sheet.png with the 4 × 4 grid and cell numbers drawn over it by the film's script; beside it, "
  "fixture-capture crops of run_preview frames in which Godot drew cells 1, 2, 12 and 13 (captures/run/r0/, r0-sword/).",
  "Here is that sheet, with the grid drawn over it for the film. Sixteen cells of four hundred and ten by three hundred and eighty-six "
  "pixels: Rudy's sixteen Assignment 2 frames, packed by a script with no scaling and no edits, every cell checked against its source "
  "pixel for pixel. Run uses cells one and two, the sword run twelve and thirteen. On the right is what Godot actually drew from those "
  "cells: crops of the run preview, a fixture capture.", ["run-cycle"]))

B.append(code("B05", "the frame track that reads it", "animations/rudy_animations.tres", 47, 60, "The Frame Track That Reads It",
  "And this is the frame track that reads the sheet: the run clip. One value track on Sprite, colon, frame. Two keys: cell one at "
  "zero, cell two at point one two five seconds. Update one is discrete, so the frame jumps from cell to cell and never sweeps through "
  "the cells between. Length point two five, and loop mode one, linear. That is the seam rule for a frame track: no duplicate across "
  "the wrap. The last key is cell two, the first is cell one, and the gap from the last key to the end equals the key interval. "
  "Step, point one two five: one frame period, at eight cells a second.",
  [("Sprite, colon, frame", 53, "Sprite:frame — a value track on one integer"), ("cell one at zero", 57, "times 0 and 0.125 s"),
   ("Update one", 59, "update 1: UPDATE_DISCRETE"), ("never sweeps", 60, "values [1, 2]: cells 1 and 2"),
   ("Length point two five", 47, "length 0.25 s"), ("loop mode one", 48, "loop_mode 1: LOOP_LINEAR"),
   ("Step, point one two five", 49, "step 0.125 s: one frame period at 8 cells/s")],
  [("Seam", "no duplicate at the wrap"), ("sword_run", "cells 12 and 13"), ("Built by", "claude -p sessions 4, 12")],
  ["game/animations/rudy_animations.tres · run"], ["run-cycle"], font=23))
B.append(gameplay("B06", "result — the run in play",
  [seg("play-01", 28, 182), seg("play-01", 108, 128, 0.25, "REPLAY ¼× · ENLARGED 2.5× · the run: cell 1, cell 2, 8 cells a second", STAND),
   seg("play-01", 110, 124, 0.125, "REPLAY ⅛× · ENLARGED 2.5× · the seam: cell 2 wraps to cell 1, no frame doubled", STAND),
   seg("play-01", 158, 190, 0.25, "REPLAY ¼× · ENLARGED 2.5× · the sword, mid-run: sword_run starts on cell 12", STAND),
   seg("play-01", 164, 176, 0.125, "REPLAY ⅛× · ENLARGED 2.5× · cell 2 on frame 167, then sword_run from cell 12", STAND)],
  "The real Main in Godot 4.7.2 Compatibility, Movie Maker at 3840×2160 and 30 fps, scripted input (play-01): Enter on the title, the run "
  "from frame 51 (cells 1 and 2), rise and fall over the first spikes and the first goblin, the sword picked up mid-run on frame 168 "
  "(sword_run from cell 12), the stop on frame 180; then labelled replays, enlarged 2.5×: frames 108–127 at ¼× and 110–123 at ⅛× "
  "(cells 1, 1, 2, 2, 2, 2, 1 …: no frame between, none doubled at the wrap), frames 158–189 at ¼× and 164–175 at ⅛× (cell 2 on "
  "frame 167, sword_run from cell 12 on 168).",
  "In the game, real engine output. Enter, and he runs: cell one, cell two, eight cells a second. He jumps the spikes, rise then fall, "
  "and jumps the first goblin. At a quarter speed: the frame jumps between two cells, nothing in between, and the cycle wraps with no "
  "doubled frame. He reaches the sword mid-run, and the sword run starts from its own first cell, twelve. A clip restarts whenever he "
  "enters it.", ["run-cycle", "state-machine"]))
B.append(still("B07", "registration and the seam, in the run strip", "registration.png",
  "Fixture captures of game/previews/run_preview.tscn, frames 30–41 of captures/run/r0/ and r0-sword/, cropped around Rudy and enlarged "
  "2× nearest, with the walk line drawn; each frame's cell read from logs/run_preview_r0*.log; shuai-z's human checks quoted from TEST-REPORT.md.",
  "Registration and the seam, in the run strip: a fixture, the preview scene over the real level. Twelve frames of each form, with the "
  "walk line drawn across. His soles sit on it in every cell, and the two cells do not jump against each other. The log puts his origin "
  "on the same screen point every frame, but a log is not a look. shuai-z's human checks: the seam, no problem; registration, normal. "
  "How many wraps, and which form, those words do not say.", ["run-cycle"]))

# ── question 1: what a clip is ──────────────────────────────────────────────
B.append(code("B08", "question 1 — what a clip is", "animations/rudy_animations.tres", 409, 420, "A Clip Is a List of Keys",
  "The first question: what is a clip? This one, the slash's Grip track, is the whole answer. A track names a node path and a property: "
  "Slash Rig, Lean, Grip, colon, rotation degrees. Then keys: five times, five values, five transitions. Update zero is continuous, so "
  "the angle is interpolated between keys. Playing the clip means setting that property to those values at those times. Nothing in it "
  "knows about the sword, the goblin or the hitbox.",
  [("node path and a property", 412, "SlashRig/Lean/Grip : rotation_degrees"), ("five times", 416, "times 0, 2/60, 5/60, 11/60, 17/60 s"),
   ("five values", 419, "values −70, −60, 0, 45, 15 degrees"), ("five transitions", 417, "2 ease-in · 0.5 ease-out · 1 linear"),
   ("Update zero", 418, "update 0: UPDATE_CONTINUOUS")],
  [("Clip", "slash: 6 tracks, 17/60 s"), ("Loop", "LOOP_NONE (no line)"), ("Keyed by", "claude -p sessions 7, 8")],
  ["game/animations/rudy_animations.tres · slash, track 2"], ["slash-rig"], font=27))
B.append(gameplay("B09", "result — the keys played, in the game",
  [seg("play-01", 190, 212), seg("play-01", 196, 208, 0.25, "REPLAY ¼× · ENLARGED 2.5× · one slash: swing ticks 1, 3, 5 … 15, two a frame", STAND),
   seg("play-01", 196, 208, 0.125, "REPLAY ⅛× · ENLARGED 2.5× · one slash", STAND),
   seg("play-01", 197, 207, 1 / 24, "FRAME BY FRAME 1/24× · ENLARGED 2.5× · frames 197–206: sword_idle, ticks 1, 3 … 15, sword_idle", STAND)],
  "The same capture: one slash standing, the rig shown on frames 198–205 (swing ticks 1 to 15, two ticks a frame; Grip −67.5, −53.3, 0, "
  "25, 40, 45, 28.3, 18.3 in the run log), sword_idle again on frame 206; then labelled replays, enlarged 2.5×, at ¼× and ⅛×, and "
  "frame by frame (each game frame held 0.8 s) from frame 197 to 206.",
  "Played, in the game: one swing, standing. At a quarter speed the keys come out as motion. The first drawn frame is tick one, the "
  "blade back over his shoulder. By tick five it is at zero, the angle it was drawn at. Forty-five on tick eleven, then it settles back, "
  "and on tick seventeen the sword idle frame returns.", ["slash-rig", "state-machine"]))
B.append(still("B10", "why a missing property fails silently", "missing-property.png",
  "A card of recorded evidence: the load-error probe's track row and log line (evidence/load-error-probe/), test_rudy_clips.gd lines "
  "419–421 verbatim, and mutation M1's diff and first FAIL line (logs/mutation_M1.txt). Labelled HEADLESS TEST OUTPUT.",
  "Why does a track that names a property that does not exist fail silently? Because a path is only text until the clip plays. A probe "
  "gave one clip a track to a missing node and one to a missing property. The missing node printed one warning, which the wrapper "
  "now fails on. The missing property printed nothing at all: that part simply does not move. So the read-back asks each node whether the "
  "property is in it. Mutation one dropped one letter, rotation degree. The game would load without a word; the read-back failed.",
  ["animation-tests"]))

# ── question 2: one authority ───────────────────────────────────────────────
B.append(code("B11", "question 2 — one authority", "content/rudy/rudy.gd", 231, 241, "One Authority, One Call",
  "The second question: what does one authority mean? Exactly one thing writes to an animated node. Here that is the Animation Player "
  "under Look. It alone keys the Sprite's frame and visibility, the rig's visibility, and Grip, Lean and the arc. Rudy's script writes "
  "only Look itself: its scale, for facing, and its alpha, for the flash, which no clip keys. And it tells the player what to play in "
  "one place, line two forty-one, every physics tick, restarting the slash on every new swing. With two writers on one node, the one "
  "that runs last in the frame wins, and that depends on node order, not on any design.",
  [("its scale", 238, "Look.scale.x = facing: Rudy's own write"), ("its alpha", 239, "Look.modulate.a: the flash"),
   ("line two forty-one", 241, "play_clip(_pick_clip(), new_swing): the one call"),
   ("restarting the slash", 232, "new_swing: a fresh press, no swing under way")],
  [("Player writes", "Sprite, SlashRig, the rig"), ("Rudy writes", "Look scale.x, modulate.a"),
   ("Never added", "a second writer")],
  ["game/content/rudy/rudy.gd · _physics_process"], ["state-machine"], font=23))
B.append(gameplay("B12", "result — one authority in play",
  [seg("play-01", 288, 345), seg("play-01", 294, 330, 0.25, "REPLAY ¼× · ENLARGED 2.5× · turn, run, slash, run: the rig flips with Look", STAND),
   seg("play-01", 312, 327, 0.125, "REPLAY ⅛× · ENLARGED 2.5× · the slash while running left: the rig mirrored", STAND),
   seg("play-01", 314, 325, 1 / 24, "FRAME BY FRAME 1/24× · ENLARGED 2.5× · frames 314–324: sword_run, slash ticks 0 … 16, sword_run cell 12", STAND),
   seg("play-01", 296, 345, 0.5, "REPLAY ½× · ENLARGED 2.5× · turn, run, slash, run", STAND)],
  "The same capture: he turns left on frame 298 (Look flips), runs from frame 301 (sword_run), slashes while running on frames 315–323 "
  "and runs on in sword_run from cell 12 on frame 324, stopping on frame 338; then labelled replays, enlarged 2.5×: ¼×, ⅛× of the "
  "slash while running, frame by frame from 314 to 324 (each game frame held 0.8 s), and ½×.",
  "In play. He turns and runs left, and the Sprite flips with Look, because Rudy's script flips Look and the player owns everything "
  "under it. He slashes while running: the selector switches to slash on the tick of the press, and back to the sword run on tick "
  "seventeen, starting over from cell twelve, and the rig is mirrored with him. The brief predicted what a second authority would look "
  "like: a flicker between a whole frame and a sheet cell. The read-back checks that no script sets the Sprite's texture or frame.",
  ["state-machine", "slash-rig"]))

# ── question 3: two clocks ──────────────────────────────────────────────────
B.append(code("B13", "question 3 — the two clocks", "content/rudy/rudy.tscn", 69, 76, "Two Clocks, Made One",
  "The third question: the two clocks. An Animation Player advances on the tick its callback mode names: the process tick, once per "
  "drawn frame, or the physics tick. Gameplay here reads on the physics tick: the hitbox is decided from the swing clock inside Rudy's "
  "physics process. So the player is set to physics, zero, here in the scene, not the default, idle. Both clocks are now the same tick. "
  "Its root node is Look, the parent, so every track path starts there. Autoplay is empty, so nothing plays a clip on its own, and "
  "speed scale is one.",
  [("callback mode", 76, "callback_mode_process = 0: physics"), ("root node is Look", 70, "root_node ..: track paths start at Look"),
   ("Autoplay is empty", 74, "autoplay \"\": nothing starts by itself"), ("speed scale is one", 75, "speed_scale 1.0")],
  [("Gameplay", "rudy.gd:248, each tick"), ("Default", "idle (1): per drawn frame"), ("Measured", "0 s apart, every tick")],
  ["game/content/rudy/rudy.tscn · Look/AnimationPlayer"], ["state-machine"], font=30))
B.append(still("B14", "result — one clock, in the strip", "clock-strip.png",
  "Fixture captures r1 (first-tick offset), frames 29–35 and 38 of captures/slash/r1/, enlarged 2× nearest, drawn with "
  "--debug-collisions so the hitbox shows; each frame's swing tick, Grip and hitbox state read from logs/slash_preview_r1.log; and the "
  "state test's per-swing line from logs/test_rudy_states_60fps.log.",
  "What one clock looks like, in the strip: a fixture, with the collision shapes drawn. Frame thirty, tick one: the wind-up, the hitbox "
  "dead. Frame thirty-one, tick three: the blade on its way, the hitbox live. Frame thirty-five, tick eleven, the first frame of recovery: "
  "blade forward, hitbox dead. The picture and the hitbox change on the same ticks. The state test checked it on every swing tick: the "
  "clip position equals the ticks since the press over sixty, and the largest disagreement is zero. On the idle callback, at thirty "
  "frames a second, the clip would have trailed by up to a drawn frame.", ["state-machine", "slash-rig"]))

# ── question 4: feel designed in frames ─────────────────────────────────────
B.append(figure("B15", "question 4 — feel designed in frames", "The Phase Table, and the Keys Built From It",
  "CHANGE-BRIEF.md §2.2 · the phase table, in ticks at 60 · beside the keys of rudy_animations.tres", "phase-keys.png",
  "Source: CHANGE-BRIEF.md §2.2 (296c6bdf) and Revision 6; game/animations/rudy_animations.tres lines 416–419. Drafted by Claude, reviewed by shuai-z.",
  [("Startup", "ticks 0–1 · hitbox dead"), ("Active", "ticks 2–10 · live"), ("Recovery", "ticks 11–16 · dead"), ("End", "tick 17 · the swing ends")],
  [["Startup", 0], ["Active", 1], ["Recovery", 2], ["swing ends", 3]],
  "The fourth question: what it means to design feel in frames. The phase table is the design, in ticks at sixty a second. Startup, "
  "ticks zero and one, the hitbox dead. Active, two to ten, live. Recovery, eleven to sixteen, dead. On seventeen the swing ends. These "
  "are the game's existing timings, kept on purpose, though the motion reference's wind-up is fifteen times longer. The keys are "
  "derived from the table: zero, two, five, eleven and seventeen, over sixty. To change the feel, you change the table, and the keys "
  "follow.", ["slash-rig"]))
B.append(code("B16", "the read-back pins the ticks", "tests/test_rudy_clips.gd", 131, 139, "The Read-Back Writes the Table in Ticks",
  "The read-back writes the same table in ticks. Grip: tick zero, minus seventy; two, minus sixty; five, zero; eleven, forty-five; "
  "seventeen, fifteen; each with its transition. Lean, its position and the arc follow at the same boundary ticks. The test divides by "
  "sixty and compares each key time to within a microsecond, never with equals, because the file stores them as thirty-two-bit "
  "floats. And line one thirty-two is where tuning changed one number: the key at tick five eases out, point five, instead of in.",
  [("Grip: tick zero", 131, "Grip:rotation_degrees, continuous"), ("seventeen, fifteen", 132, "[tick, degrees, transition] × 5"),
   ("Lean, its position", 134, "Lean: −2, −2, 3, 3, 0 degrees"), ("the arc", 139, "Arc alpha: on by tick 4, off by 11"),
   ("divides by sixty", 132, "ticks; the check divides each by 60"), ("line one thirty-two", 132, "[5, 0.0, 0.5]: tuning r1's one change")],
  [("Tolerance", "1 µs, never =="), ("Checks", "51 · 30 NEGATIVE"), ("Written by", "sessions 4–8, 12, 18b")],
  ["game/tests/test_rudy_clips.gd · RIG_TRACKS"], ["animation-tests", "slash-rig"], font=23))
B.append(still("B17", "result — the strip at each phase boundary", "boundary-strip.png",
  "Fixture captures r1 at both tick offsets (captures/slash/r1/ and r1-second-tick/), enlarged 2× nearest, ordered by swing tick: 1 and "
  "2 (startup into active), 10 and 11 (active into recovery), 16 and 17 (the end); each frame's tick, Grip and hitbox read from "
  "logs/slash_preview_r1*.log beside CHANGE-BRIEF.md Revision 6's table.",
  "And the strip at each phase boundary. Movie Maker at thirty frames a second draws two ticks a frame, so two captures, a tick apart, "
  "cover every boundary. Startup into active: tick one, the blade back and the hitbox dead; tick two, the first active key, the hitbox "
  "live. Active into recovery: tick ten, the last live tick; tick eleven, the blade at forty-five and the hitbox dead. And the end: "
  "tick sixteen, the last slash frame; tick seventeen, the sword idle frame again. Each logged value matches the brief's table.",
  ["slash-rig"]))
B.append(still("B18", "tuning r1 — a reading, a change, a verdict", "tuning-r1.png",
  "Fixture captures r0 and r1, frames 31–35 (first-tick offset), enlarged 2× nearest, with Grip per frame from the logs; shuai-z's first "
  "verdict and r1 verdict quoted in Chinese with Claude's translation, and Claude's reading, prediction and comparison, from TUNING.md.",
  "Then tuning. shuai-z watched the previews first, before Claude read a frame, and said: the three phases are distinct, and the sword "
  "does not catch as it sweeps. Claude's reading disagreed. From frame thirty-two to thirty-three the blade turns only five degrees, a "
  "near stop, because both keys around tick five eased in. That is a claim, and the record keeps both. One change, proposed by Claude "
  "and approved by shuai-z: the key at tick five eases out. Claude predicted Grip twenty-five on frame thirty-three and forty on "
  "thirty-four, and strip r one logged exactly those. shuai-z watched it in the game at a quarter speed, and kept it. That round was "
  "driven by Claude's reading, not by something shuai-z saw in play, so the observation-driven revision the assignment asks for is "
  "still owed.", ["slash-rig"]))

# ── the state machine in play, interrupts in each phase ─────────────────────
B.append(code("B19", "the state machine", "content/rudy/rudy.gd", 307, 320, "The State Machine Is a Priority List",
  "The state machine is a priority list, run every physics tick. The mode decides first, in the lines just above these: celebrate, "
  "respawn, defeat, hurt. Then the "
  "swing: while the swing clock runs, slash. Then the air: rise, or fall, if he was moving sideways when the fall began. Then the "
  "floor: run if he is moving, idle if not. While he has the sword, the sword form of each. It returns a name, and the player plays it.",
  [("while the swing clock runs", 307, "under is_slashing(): slash"),
   ("moving sideways", 314, "fall only if sideways when the fall began"), ("run if he is moving", 318, "|velocity.x| > 1 → run"),
   ("idle if not", 320, "otherwise idle"), ("sword form", 308, "gear == SWORD → the sword_ clips")],
  [("Lines 296–306, above", "match mode, then is_slashing()"), ("Returns", "13 clip names"), ("Wired by", "claude -p sessions 5, 8")],
  ["game/content/rudy/rudy.gd · _pick_clip()"], ["state-machine"], font=23))
B.append(gameplay("B20", "result — the states in play, and a committed swing",
  [seg("play-01", 78, 156), seg("play-01", 82, 152, 0.5, "REPLAY ½× · rise and fall over the spikes and the first goblin, the run between"),
   seg("play-01", 214, 236),
   seg("play-01", 219, 232, 0.25, "REPLAY ¼× · ENLARGED 2.5× · J again on swing ticks 1, 5, 13: ignored", STAND),
   seg("play-01", 220, 231, 0.125, "REPLAY ⅛× · ENLARGED 2.5× · J read on swing ticks 1, 5 and 13: still one swing", STAND),
   seg("play-01", 246, 282),
   seg("play-01", 252, 280, 0.25, "REPLAY ¼× · ENLARGED 2× · a jump on swing tick 5: the slash plays on in the air", APEX),
   seg("play-01", 253, 265, 0.125, "REPLAY ⅛× · ENLARGED 2× · the swing ends in the air, then sword_rise on frame 263", APEX)],
  "The same capture: rise (frame 87) and fall (99) over the first spikes and the first goblin, the run between; a slash from frame 221 with "
  "the slash key pressed again on swing ticks 1, 5 and 13 (each read, each ignored: one swing, sword_idle on frame 230); a slash from "
  "frame 254 with a jump read on swing tick 5 (airborne on frame 257, sword_rise on 263 after the swing ends, landing on 277); with "
  "labelled replays: the air at ½×, each swing at ¼× and ⅛×, enlarged.",
  "In play: rise and fall over the spikes and the first goblin, and the run between. Then two swings with the sword. In the first, the "
  "slash key is pressed again on swing ticks one, five and thirteen, one in each phase. All three are ignored: one swing, one slash "
  "sound. In the second, a jump on swing tick five. He leaves the ground, and the slash plays on to its end in the air, then the sword "
  "rise. No input cancels a committed swing.", ["state-machine", "slash-rig"]))
B.append(code("B21", "what ends a swing early", "content/rudy/rudy.gd", 145, 158, "What Ends a Committed Swing",
  "What can end a committed swing early? Only the world: a hit, a fall out of the level, a respawn, the teleport circle. Here is the "
  "hit. Just above, with the sword, it knocks the sword away instead of a heart. He turns toward the hit. The swing clock goes below zero, so on "
  "that same tick the selector returns the hurt clip: the rig hides, the Sprite shows, and the hitbox is dead. Then the knockback.",
  [("turns toward the hit", 146, "facing = −away"),
   ("swing clock goes below zero", 148, "_slash_clock = −1.0: the swing ends"), ("hurt clip", 156, "mode = HURT, for hurt_time 0.35 s"),
   ("knockback", 158, "velocity: away and up")],
  [("Lines 139–144, above", "the sword goes, not a heart"), ("Also ends it", "a fall, a respawn, the circle"), ("Tested by", "edge test E3")],
  ["game/content/rudy/rudy.gd · take_hit()"], ["state-machine"], font=23))
B.append(gameplay("B22", "result — a hit in startup, active and recovery",
  [seg("play-01", 706, 734), seg("play-01", 712, 728, 0.25, "REPLAY ¼× · ENLARGED 2.5× · take 1 · a hit on swing tick 1: STARTUP", STAND),
   seg("play-01", 716, 721, 1 / 16, "FRAME BY FRAME 1/16× · ENLARGED 2.5× · take 1 · frames 716–720: idle, the rig at tick 0, hurt", STAND),
   seg("play-02", 358, 384), seg("play-02", 364, 380, 0.25, "REPLAY ¼× · ENLARGED 2.5× · take 2 · a hit on swing tick 5: ACTIVE", STAND),
   seg("play-02", 367, 372, 1 / 16, "FRAME BY FRAME 1/16× · ENLARGED 2.5× · take 2 · frames 367–371: idle, ticks 1 and 3, hurt", STAND),
   seg("play-03", 356, 384), seg("play-03", 361, 380, 0.25, "REPLAY ¼× · ENLARGED 2.5× · take 3 · a hit on swing tick 13: RECOVERY", STAND),
   seg("play-03", 364, 372, 1 / 16, "FRAME BY FRAME 1/16× · ENLARGED 2.5× · take 3 · frames 364–371: idle, ticks 1 … 11, hurt", STAND)],
  "Three Movie Maker takes of the real Main, each a fresh boot with scripted input that times the slash against goblin B walking into "
  "Rudy's back: play-01 (slash read on the second tick of frame 718, hit on swing tick 1, hurt on frame 719), play-02 (hit on swing tick "
  "5, hurt on frame 371), play-03 (hit on swing tick 13, hurt on frame 371), each at 1.0×, as a labelled quarter-speed replay, and "
  "frame by frame around the hit (each game frame held 0.53 s), enlarged 2.5×.",
  "Three takes, each a fresh boot of the game, scripted to time the slash against goblin B walking into his back. Take one: the hit on "
  "swing tick one, in startup. One drawn frame of the wind-up, then hurt, and the sword flies. Take two: tick five, mid-sweep, the hitbox "
  "live but on his other side. Hurt, on that tick. Take three: tick thirteen, in recovery. Hurt. In every phase the swing ends on the "
  "tick of the hit.", ["state-machine", "slash-rig"]))

# ── the tests ───────────────────────────────────────────────────────────────
B.append(still("B23", "what the read-backs proved", "tests.png",
  "Recorded headless output through scripts/run-test.sh at pinned frame rates: the read-back's assertion lines and summary (51 PASS), "
  "the state test (99), the edge test (108 at 60, 66 at 30), the pin (20) and the earlier tests, read from logs/.",
  "What the read-backs proved. One test reads both clips back against the player in Rudy's scene: fifty-one checks. Every track "
  "resolves to a real node and property. Key times match the phase table to a microsecond. The step is one frame period. Loop modes: "
  "linear for the run, none for the slash. Every frame track is discrete, and every frame key is inside the sheet. Thirty damaged "
  "copies each fail their own check. The state test, ninety-nine checks, drives the real game with key events and reaches fifty-four "
  "of the table's fifty-eight transitions; the other four cannot happen on Level one. The edge test presses before, on and after every "
  "phase boundary: a hundred and eight checks at sixty, sixty-six at thirty. And the pins pass again, with the three changes the brief "
  "predicted.", ["animation-tests"]))
B.append(still("B24", "the four mutations", "mutations.png",
  "Recorded output of the four mutations, each run in a fresh git worktree at f1680bfb (logs/mutation_M1–M4.txt): M1–M3 exit 1 with "
  "their FAIL lines; M4 exits 0 with 51 PASS after the cache was deleted and rebuilt; the control C0 passes.",
  "The four mutations, each in its own git worktree. One, a broken subname: exit one, six failures. Two, the run's loop mode set to "
  "none: exit one. Three, a frame keyed to cell sixteen, one past the sheet: exit one. Four, the import cache deleted and rebuilt: the "
  "read-back still passes, fifty-one, as predicted. The rig is keyed as resource text, not imported, so nothing the clips need lives in "
  "the cache.", ["animation-tests"]))
B.append(still("B25", "what no headless run can show", "headless-limits.png",
  "The headless-facts probe's lines (logs/probe_headless_facts_60fps.log: clips advance; get_image() returns null), beside a fixture "
  "capture frame of the same slash; shuai-z's four human checks and editor run quoted from TEST-REPORT.md.",
  "And what no headless run can show. Headless, Godot advances the clips and reads their structure, but it draws nothing: the probe "
  "asked for an image and got null. Whether the slash reads, whether the run wraps without a visible seam, whether the action feels "
  "committed: those rest on eyes. shuai-z's checks: the seam, no problem; play, no problem; registration and background, normal. Those "
  "words do not say how many wraps, which interrupts, or which stretches of the level.", ["animation-tests"]))

# ── verdict, your turn, outro ───────────────────────────────────────────────
B.append({"beat_id": "BVD1", "act": "verdict — checked, overruled, caught", "components": ["animation-tests"], "lead_silence_s": 0.4,
  "narration_text": "Verdict. Checked by machine: the read-back, the state and edge tests and the re-pinned pins pass, every earlier test "
                    "keeps its count, and three mutations fail as they should; the fourth passes, as predicted. Checked by eye: shuai-z's "
                    "first verdict, the kept round, four human checks and the editor run. Overruled: none of Claude's strip readings. On "
                    "r zero the two disagreed, and Claude's reading drove the change. Caught by shuai-z: the brief's claim that every "
                    "prompt reads the CLAUDE file, and Claude reading a rule from another file, measured frame counts, as this assignment's own. Caught by the "
                    "tests and the sessions: a play-then-seek that ended the slash a tick early, a rig prompt that contradicted itself, "
                    "previews one frame late, and two wrong citations in the brief.",
  "shot": {"type": "REMOTION", "lane": "card", "remotion": {"pattern": "ClaudeVerdictArtifact", "props": {
    "artifactTitle": TITLE, "artifactHeading": "Checked, overruled, caught",
    "artifactLines": ["Machine: read-back 51/51; states 99; edges 108 at 60 fps and 66 at 30; pin 20, with T1, T2, T6 re-pinned as predicted; every earlier test at its count. M1–M3 exit 1; M4 passes, as predicted.",
                      "Eyes: shuai-z's first verdict before Claude read a frame; r1 kept after play at 0.25×; the seam, play, registration and background checks; the editor run.",
                      "Overruled: none. Disagreed: on r0 Claude read a near-stop at tick 5 (5° from frame 32 to 33); shuai-z saw no catch. Claude's reading drove r1.",
                      "Caught by shuai-z: Revision 1's claim that every prompt reads CLAUDE.md; Claude taking a base file's measured-frame-count rule as the assignment's. Caught by tests and sessions: play-then-seek ending the slash a tick early (pin T3, I7); a self-contradicting rig prompt; previews a frame late; two wrong brief citations."]}}}})
B.append({"beat_id": "BVD2", "act": "verdict — uncertain, and the next step", "components": [],
  "narration_text": "Still uncertain, or not done. No revision was driven by shuai-z's own observation in play; that is owed. The "
                    "captures were run by Claude at shuai-z's request, though the assignment says the student runs them. The kept round "
                    "was judged at a quarter speed only. Claude reads the hitbox as opening while the blade is still above his head. The kink at the fist "
                    "and the repaired band on the robe have not been judged by eye. One machine, and no other player. The next step: play "
                    "at normal speed, name one thing that reads wrong, change the phase table, predict, and capture two strips.",
  "shot": {"type": "REMOTION", "lane": "card", "remotion": {"pattern": "ClaudeVerdictArtifact", "props": {
    "artifactTitle": TITLE, "artifactHeading": "Uncertain, and the next step",
    "artifactLines": ["Not done: no tuning revision was driven by shuai-z's own observation in play (the assignment asks for one). The captures were run by Claude at shuai-z's request, not by the student.",
                      "Judged only partly: r1 at 0.25× only, never at normal speed; the human checks do not say how many wraps, which interrupts, or which stretches of the level.",
                      "Unjudged by eye: the hitbox live on ticks 2–4 while the blade is overhead (Claude's claim); the kink at the fist; the repaired band on the robe; the pop on the last slash frame.",
                      "One machine (Apple M3, macOS 15.1), and no other player. The film's gameplay frames are 4K but scaled by Movie Maker, not pixel-native.",
                      "Next: play at normal speed, name one thing that reads wrong, change the phase table, predict the strip, capture two strips, give a verdict in play."]}}}})
B.append({"beat_id": "BVD3", "act": "verdict — who made what, sources, revision", "components": [],
  "narration_text": "Who made what. shuai-z chose both clips and their routes, kept the slash's timing, chose open footage and checked "
                    "Claude's counts, approved every prompt, revision and commit, and gave every verdict and human check. Claude Code "
                    "drafted the brief, its phase table, cycle spec and predictions, wrote and ran every agent session, the probes, the "
                    "mutations and the captures, drafted the records, and made this film. The sheet and the rig are cut by code from "
                    "shuai-z's own Assignment 2 frames, made with Gemini's image generation under Google's terms. The motion reference: "
                    "a sword exercise by Kuroczynski, C C B Y S A four point oh, and running videos by Arellano, McDermott, Kram and "
                    "Grabowski, C C B Y four point oh. The source shown is seven seven five c one four c.",
  "shot": {"type": "REMOTION", "lane": "card", "remotion": {"pattern": "ClaudeVerdictArtifact", "props": {
    "artifactTitle": TITLE, "artifactHeading": "Who made what · sources · revision",
    "artifactLines": ["shuai-z: chose both clips and routes and kept the slash's timing; chose open footage and checked Claude's frame counts; approved every prompt, brief revision, change and commit; every verdict and human check.",
                      "Claude Code (Opus 5.5): drafted CHANGE-BRIEF (phase table, cycle spec, predictions), TUNING, TEST-REPORT, FRICTIONAL; prepared and ran the claude -p sessions that keyed the clips and wrote the tests; probes, mutations, captures, strip readings; this film. Narration: Liam, Kokoro am_onyx.",
                      "Sheet and rig: packed and cut by code from shuai-z's own Assignment 2 frames (Gemini app image generation; Google ToS and Generative AI Additional Terms); no found sheet. Motion reference, measured, not shown: “IMG 8252” by Kuroczynski, CC BY-SA 4.0; PLOS ONE S1/S3 videos, Arellano, McDermott, Kram, Grabowski (2015), CC BY 4.0.",
                      f"Source shown: walker-rudy assignment-7/game at {REV} (game unchanged since 09ce1cb, except two ATTRIBUTION.md files added in c2da5ba)."]}}}})
B.append({"beat_id": "BHTF", "act": "your turn", "components": [],
  "narration_text": "Your turn. Here is the prompt; read it with me. Read my change brief and the slash clip. Before you change anything, "
                    "let me predict by hand Grip's angle on strip frame thirty-three, and the tick the blade passes horizontal, if the "
                    "middle active key moves from tick five to tick four in the phase table. Then change the table, build the key from it, "
                    "update the read-back's expected tick, run it through the wrapper, and print the preview's Grip values beside my "
                    "prediction. I run the capture myself. Write your prediction down first. Liam, in for Bear.",
  "shot": {"type": "REMOTION", "lane": "bookend", "remotion": {"pattern": "ClaudeComposerAsk", "props": {
    "greeting": "Your turn.", "topic": TOPIC, "segment": TITLE,
    "command": "Read my CHANGE-BRIEF.md and the slash clip in game/animations/rudy_animations.tres. Before you change anything, let me predict "
               "by hand Grip's angle on strip frame 33 and the tick the blade passes horizontal (about +30.9°) if the phase table's middle "
               "active key moves from tick 5 to tick 4. Then change the phase table, build the key from it, update the read-back's expected "
               "tick in game/tests/test_rudy_clips.gd, run scripts/run-test.sh test_rudy_clips.tscn 60, and print the slash preview's Grip "
               "values beside my prediction. I run the capture myself.",
    "runningText": "paste this into your own Claude session…", "folderLabel": "@NikBearBrown", "modelLabel": "Opus 5.5", "effortLabel": "High"}}}})
B.append({"beat_id": "BOUT", "act": "outro", "components": [], "kind": "outro_voice",
  "role_note": "OUTRO-LOCK: exact title, @NikBearBrown, slug-seeded mascot, no subline; spoken, never scored; 1.0 s tail.",
  "narration_text": f"{TITLE} At Nik Bear Brown.", "tail_s": 1.0,
  "shot": {"type": "REMOTION", "lane": "bookend", "remotion": {"pattern": "ClaudeTitleOutro", "props": {"title": TITLE, "slug": SLUG}}}})

for b in B:
    b.setdefault("voice", "am_onyx")
    b.setdefault("engine", "kokoro")

sheet = {"metadata": {
    "title": TITLE, "slug": SLUG, "topic": TOPIC, "register": "Teardown",
    "audience": "Claude", "brand": "claude-liam", "persona": "Liam (in for Bear)", "voice": "am_onyx", "engine": "kokoro",
    "voice_kokoro": "am_onyx", "palette": "claude", "style_preset": "claude", "ground": "#FAF9F5", "greeting": "Jambo, Liam",
    "folderLabel": "@NikBearBrown", "in_for_bear": True, "aspect_ratio": "16:9", "fps": 30,
    "skill": "godot-gamedev (walker modifier)", "student": "shuai-z",
    "game": {"name": "walker-rudy (assignment-7: game/)", "revision": FULL_REV, "short_revision": REV,
             "engine": "4.7.2.stable.official.ed1daf0bf", "folders": ["assignment-7/game"]}},
    "beats": B}
(REEL / "beat_sheet.json").write_text(json.dumps(sheet, indent=1, ensure_ascii=False) + "\n")
print(f"wrote beat_sheet.json: {len(B)} beats")
