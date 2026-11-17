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

### Claude's reading

Not yet. It is written only after the verdict above.

### Open

Revision 5's frame table predicts that frame F+3 (tick 7) shows the blade "at +5: almost where F+2 left it, the stall of Revision 4". My verdict says the sweep does not catch. Claude's reading of frames 32 and 33 is to be set beside it, under "Claude against you" in TEST-REPORT.md.
