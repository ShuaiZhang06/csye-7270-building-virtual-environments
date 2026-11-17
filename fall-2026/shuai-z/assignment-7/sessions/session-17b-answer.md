The timing bug is fixed in the four files. Frame 30 is now the trigger frame in all four runs, and every frame to read matches its table except one. **Finding:** my own derived table for `run_preview` is wrong at frame 37. The game and the brief's frame strip table are not affected, and I left the header as it is.

All five runs exited 0 and the rerun is identical to the first run. No line in the five preview logs or `checks_60fps.log` matches the wrapper's error patterns (`scripts/run-test.sh:54`), and no log prints `-0.00`. `checks.tscn 60`: 141 PASS, 0 FAIL, `all checks passed`, 102 `res://` paths. I kept the `res://` paths in the headers.

## What changed
- **Trigger.** The first J (or D) is sent at the end of frame 29's `_process`, so it is read on frame 30's first tick (59). With `second-tick` it follows the edge test's method from there and is read on frame 30's second tick (60).
- **Releases are counted in ticks.** J is released at the first frame boundary after the tick it was read on. D is released once 24 ticks have run since its read. A release is never sent before its press has been read.
- **Later swings.** The next J is read 120 ticks after the last J's read tick, on the same slot of its frame.
- **Read lines.** The `# J read …` and `# D read …` lines come from `Input.is_action_just_pressed` (or `_just_released`), checked in the preview's `_physics_process`. That runs before Rudy's on each tick, so it sees the same press he reads.
- **Headers** now say what the log shows: frame 0 runs tick 0 alone, and frame N ≥ 1 runs ticks 2N−1 and 2N.
- **No −0.00.** Adding 0.0 was not enough: the second offset's frame 31 still printed `lean_pos (-0.00` and `arc -0.000`. Those were tiny negative values from interpolation, not exact −0.0. So each value that rounds to zero at its printed precision now prints as 0. This is a change to printing only.
- **Two changes to your commands.** I added `> /dev/null` to the rerun and the wrapper run so their output didn't flood this conversation. The logs are written the same way.

## slash_preview, first offset (`logs/slash_preview_headless.log`)
```
# argument: none (J read on the first tick of its frame)
# at --fixed-fps 30 frame 0 runs tick 0 alone, and frame N >= 1 runs ticks 2N-1 and 2N and shows the state after tick 2N
# the first J is sent at the end of frame 29 and read on the first tick of frame 30: tick 59 at --fixed-fps 30;
# trigger frame F = 30   (frames to read: Revision 5's table)
# J read on tick 59, the first tick of frame 30
```
| Frame | Brief (Revision 5) | Log | Match |
|---|---|---|---|
| F−1 = 29 | sword-idle Sprite | `CHAR-SWORD-IDLE`, sprite true, rig false | yes |
| F = 30 | tick 1; Grip −67.5, Lean −2; no arc; dead | swing 1, grip −67.50, lean −2.00, arc 0.000, live false | yes |
| F+1 = 31 | tick 3; Grip −53.3; arc 0.5; live | swing 3, grip −53.33, arc 0.500, live true | yes |
| F+2 = 32 | tick 5; Grip 0; Lean +3, 6 px; arc 0.86 | swing 5, grip 0.00, lean 3.00, lean_pos (6.00, 0.00), arc 0.857 | yes |
| F+3 = 33 | tick 7; Grip +5 | swing 7, grip 5.00 | yes |
| F+5 = 35 | tick 11; Grip +45; arc gone; dead | swing 11, grip 45.00, arc 0.000, live false | yes |
| F+8 = 38 | tick 17; sword-idle Sprite | `CHAR-SWORD-IDLE`, clip sword_idle pos 0.0000, rig false | yes |

## slash_preview, second offset (`logs/slash_preview_headless_second_tick.log`)
```
# argument: second-tick (J read on the second tick of its frame)
# the first J is sent at the end of frame 29 and read on the second tick of frame 30: tick 60 at --fixed-fps 30;
#   DERIVED, not the brief's ... Frame N shows swing tick 2N - 60.
# J read on tick 60, the second tick of frame 30
```
| Frame | Derived table | Log | Match |
|---|---|---|---|
| 29 | sword-idle | `CHAR-SWORD-IDLE` | yes |
| 30 | tick 0; −70, −2, (0, 0), α 0, dead | swing 0, −70.00, −2.00, (0.00, 0.00), 0.000, false | yes |
| 31 | tick 2; −60, −2, (0, 0), α 0, live | swing 2, −60.00, −2.00, (0.00, 0.00), 0.000, true | yes |
| 32 | tick 4; −33.33, +1.33, (4, 0), α 1, live | swing 4, −33.33, 1.33, (4.00, 0.00), 1.000, true | yes |
| 35 | tick 10; +31.25, +3, (6, 0), α 0.14, live | swing 10, 31.25, 3.00, (6.00, 0.00), 0.143, true | yes |
| 36 | tick 12; +35.83, +2.08, (4.17, 0), α 0, dead | swing 12, 35.83, 2.08, (4.17, 0.00), 0.000, false | yes |
| 38 | tick 16; +15.83, +0.08, (0.17, 0), α 0, dead | swing 16, 15.83, 0.08, (0.17, 0.00), 0.000, false | yes |
| 39 | tick 18; sword-idle | `CHAR-SWORD-IDLE`, clip sword_idle | yes |

## run_preview (`logs/run_preview_headless.log` and `logs/run_preview_headless_sword.log`)
```
# D is sent at the end of frame 29 and read on the first tick of frame 30: tick 59 at --fixed-fps 30;
# its release is read 24 ticks later (12 frames at 30 fps): tick 83, the first tick of frame 42
#   frames 30-33 RUN-A (k 1-7); 34-36 RUN-B (k 9-13); 37-40 RUN-A (k 15-21); 41 RUN-B (k 23)
# D read on tick 59, the first tick of frame 30
# D release read on tick 83, the first tick of frame 42, 24 ticks after D was read
```
Both runs have the same header and read lines; the sword run names the sword cells.

**Without the sword:** gear stays NONE throughout, so the hidden pickup was not taken. The cells are:

| Frames | Clip position | Cell shown |
|---|---|---|
| 30–33 | 0.0167–0.1167 | RUN-A, cell 1 |
| 34–36 | 0.1500–0.2167 | RUN-B, cell 2 |
| 37 | 0.2500 | RUN-B, cell 2 |
| 38–40 | 0.0333–0.1000 | RUN-A, cell 1 |
| 41 | 0.1333 | RUN-B, cell 2 |

**With the sword:** gear is SWORD from frame 1. The cells follow the same pattern with cells 12 and 13 (SWORD-RUN-A and SWORD-RUN-B), and frame 37 shows cell 13 at position 0.2500.

**Registration:** in frames 30–41 of both runs, y = 840.00 and floor is true. The screen origin stays at (960.00, 840.00) in every frame. Whether his soles actually sit on the walk line needs the windowed capture; a headless run draws nothing.

**The finding.** Frame 37 shows run tick k = 15, at clip position exactly 0.2500 (the clip's length). The clip still shows B there and only wraps to A after it. So B lasts k 8–15 (8 ticks), not k 8–14. The pin log agrees at 60 fps: A on ticks 16–23 (8), B on 24–31 (8), A on 32–38 (7), B on 39–46 (8) (`logs/test_rudy_pin_60fps.log:20-50`). So the fixture shows what the game does, and my derivation was wrong at the wrap.

From the log, the corrected frames would be 30–33 A, 34–37 B, 38–40 A, 41 B. That still fits the brief's "alternating about every 3.75 frames". Section 7's "cells then last 7 and 8 ticks in turn" also doesn't hold for the first B, which lasts 8. I left the header unchanged, as you asked; I can correct the derived line if you want.

## git status
```
 M logs/checks_60fps.log
?? game/previews/run_preview.gd
?? game/previews/run_preview.gd.uid
?? game/previews/run_preview.tscn
?? game/previews/slash_preview.gd
?? game/previews/slash_preview.gd.uid
?? game/previews/slash_preview.tscn
?? logs/run_preview_headless.log
?? logs/run_preview_headless_sword.log
?? logs/slash_preview_headless.log
?? logs/slash_preview_headless_rerun.log
?? logs/slash_preview_headless_second_tick.log
?? sessions/prompt-17.txt
?? sessions/prompt-17b.txt
?? sessions/session-17-answer.md
```
The only files I edited are the four preview files; the logs come from the runs. Nothing under `game/shaders/` or `scripts/` changed. Nothing is committed.
