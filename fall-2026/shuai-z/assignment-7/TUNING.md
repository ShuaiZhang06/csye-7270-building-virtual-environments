# TUNING — the slash and the run, revision by revision

The assignment's Step 7: "Look before Claude does. Run the preview windowed at the project's window size and write your first verdict in TUNING.md, in visual terms, before you ask Claude to read anything." Each revision then records what I saw, Claude's reading, the change, Claude's prediction, its comparison, and my verdict.

**Who wrote what.** The verdicts are mine. I give them in Chinese, and Claude Code (Claude Opus 5.5) records them word for word, with its English translation beside them, marked as a translation. Claude Code drafted everything else in this file: the layout, the capture notes, and every reading, prediction and comparison of Claude's.

**Every capture in this file is a fixture capture**, from the preview scenes in `game/previews/`, not from the running game.

## r0 — the keys as committed (`13707a13`)

### The captures (fixture)

**Who ran them.** Claude Code ran them on 2026-11-16, at my request ("还是你来跑", "you run them after all"). It had first pointed out that the text says I run every capture ("you run every capture"; Step 7: "You run the capture, not the agent"). So these captures do not follow the text.

Each ran windowed from `assignment-7/`:

```bash
godot --path game res://previews/<scene>.tscn --write-movie "$PWD/captures/<folder>/frame.png" --fixed-fps 30 --quit-after 90 --debug-collisions [-- <argument>] 2>&1 | tee logs/<log>.log
```

| Folder | Scene and argument | Log | Trigger | Frames to read |
|---|---|---|---|---|
| `captures/slash/r0/` | `slash_preview` | `logs/slash_preview_r0.log` | J read on tick 59, the first tick of frame 30 | 29, 30, 31, 32, 33, 35, 38 (`CHANGE-BRIEF.md`, Revision 5, "The frame strip") |
| `captures/slash/r0-second-tick/` | `slash_preview -- second-tick` | `logs/slash_preview_r0_second_tick.log` | J read on tick 60, the second tick of frame 30 | 29, 30, 31, 32, 35, 36, 38, 39 (derived from the phase table, as the log's header says) |
| `captures/run/r0/` | `run_preview` | `logs/run_preview_r0.log` | D read on tick 59, the first tick of frame 30 | 30 to 41 |
| `captures/run/r0-sword/` | `run_preview -- sword` | `logs/run_preview_r0_sword.log` | the same | 30 to 41 |

- Each capture wrote 90 PNGs of 1280 × 720 (`frame00000000.png` to `frame00000089.png`) and a `frame.wav`.
- Each log's `frame` and `#` lines are identical to those of the headless run of the same scene (`logs/*_preview_headless*.log`). In the window too, frame 0 runs one tick, and frame N ≥ 1 runs ticks 2N−1 and 2N.
- No log line matches the wrapper's error patterns (`scripts/run-test.sh:54`). In each log, the one line naming the output path was shortened to start at `assignment-7/`.
- Only the frames to read are committed, 39 in all. The other PNGs and the four `frame.wav` files were deleted, as the text says ("Commit those frames and delete the rest of the sequence"). The same command can make them again: its log was the same in every run so far, headless and windowed. Whether the PNGs come out pixel for pixel the same has not been checked.

### My first verdict, before Claude read anything

2026-11-16, my words:

> 起手、出招、收招，三段分得开；剑扫过去没有卡一下；其余的肉眼没看出明显问题

Claude's translation: "Startup, active and recovery: the three phases are distinct. The sword does not catch as it sweeps across. Beyond that, I saw no obvious problem with my eyes."

The verdict does not say which previews I watched, or at which speed.

### Claude's reading (a claim, not a check)

A `claude -p` session read the frames after my verdict (`sessions/prompt-18.txt`, `sessions/session-18-answer.md`; result success, 27 turns, USD 1.48). It read 14 frames: 7 from each capture, leaving out the second capture's frame 29, which is the same pose. It described each frame before comparing it with the table and the log. Its request to crop and enlarge the frames was refused, so it called its angles rough, "a few degrees at best". Its reading, in short:
- **The phases follow the table** on every tick: the startup, the active and recovery ticks, the hitbox and the end cut. It agrees with me that the three phases are distinct.
- **The blade nearly stops at tick 5.** From frame 31 to 32 it turns 53°, from 32 to 33 only 5°, and frames 32 and 33 look nearly the same. The cause is in the keys: the Grip keys at 2/60 and 5/60 both ease in (transition 2.0), so the blade reaches 0° at full speed and starts again from rest (1.25° on tick 6).
- **The strike is late against the motion reference.** The blade is horizontal (Grip about +30.9°) only at tick 9.97, the last live tick; the reference reaches horizontal about two-thirds of the way through, about tick 8 (`CHANGE-BRIEF.md` section 8).
- **The hitbox is live on ticks 2–4 while the blade is still above his head** (r0 frame 31, second-capture frame 31). Left for a later round.
- **Smaller points:**
  - Revision 5's "+45, forward and down" is only about 14° below horizontal on screen.
  - The blade is forward and up on tick 16, then cuts to the idle pose with the sword low (a cut by design, section 3).
  - Revision 5's "the stall of Revision 4" cites nothing in Revision 4. That is an error in the brief, to be corrected in its next revision.

### Claude against me

- **The catch.** I saw no catch in the sweep. Claude reads frames 32 and 33 as a near-stop.
- **Claude's own reasons the two might differ:**
  - at normal speed, two near-equal frames right after a big jump may read as a solid hit;
  - my verdict does not say at which speed I watched;
  - the second capture keeps no frames between 32 and 35.

This goes into "Claude against you" in TEST-REPORT.md.

## r1 — Grip's key at 5/60 eases out

### What drove it

Claude's reading of r0, not something I observed: my verdict saw no catch. So this is not the observation-driven revision the text asks for ("At least one revision must be driven by something you observed in the running game, not by Claude's first reading"). That one is still to come.

### The change

- **What changed.** Session 18 proposed one change, and I approved it on 2026-11-16 ("批准，续跑去改", "approved; resume and make the change"). On the Grip track, the key at 5/60 (0°) changes its transition from 2.0 (ease-in) to 0.5 (ease-out). No key time or value changes, and no phase or gameplay timing changes.
- **Where.** The resumed session (`sessions/prompt-18b.txt`, `sessions/session-18b-answer.md`; success, 22 turns, USD 2.48) made the change in three places:
  - `game/animations/rudy_animations.tres:417`;
  - the read-back's expected value, `game/tests/test_rudy_clips.gd:132`, with its reason at `:115`;
  - the two lines of the preview's header that now print its prediction, `game/previews/slash_preview.gd:206` and `:219`.
- **The brief is not revised yet.** Revision 5's table still says +5 at F+3. A brief revision follows only if I keep the change after recapturing and playing.

### Claude's prediction, before the capture

- **The slash capture, J on a frame's first tick.**
  - Frames 29–32 and 35–38 are unchanged.
  - Frame 33 (tick 7) shows Grip +25 instead of +5: the blade clearly past frame 32, about 6° above horizontal.
  - Frame 34 (tick 9), not a frame to read, shows +40, just below horizontal.
  - The turn per frame over frames 31–35 goes from 53°, 5°, 15°, 25° to 53°, 25°, 15°, 5°. The slow pair moves to frames 34–35, an ease into the farthest pose. Claude predicts that it reads as a settle, not a new catch, "for your eyes".
- **The second capture, J on a frame's second tick.**
  - Frame 33 (tick 6) shows +13.75.
  - Frame 34 (tick 8) shows +33.75, already horizontal.
  - Frame 35 (tick 10) shows +43.75.
  - From frame 35 to 36 the blade now pulls back, from 43.75 to 35.83.
- **Horizontal** comes at tick 7.64 instead of 9.97.
- **Everything else is unchanged:** Lean, the arc, the hitbox (live on ticks 2–10), the rig's ticks and the clip position.

### After the change, headless

- **Tests.** Every test keeps its count: clips 51 PASS, states 99, edges 108 at 60 and 66 at 30, the pin 20 PASS, checks 141 with 102 res:// paths.
- **What changed in the logs.**
  - The states and edges logs differ from the committed ones only in their per-tick Grip values (Claude's comparison, with Grip masked).
  - The pin's log is byte-identical, since it does not record Grip.
  - The headless preview logs show Grip 25.00 on frame 33 and 40.00 on frame 34.
- **The check.** Claude reran all of these itself, and its logs equal the session's.

### The capture, Claude's comparison, my verdict

Not yet.
