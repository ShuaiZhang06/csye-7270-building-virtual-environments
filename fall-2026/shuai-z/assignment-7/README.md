# walker-rudy — animation (Assignment 7)

CSYE 7270, Assignment 7: *Doing Animation with Claude and Godot*. By Shuai Zhang.

**How this README was made.** Claude Code (Claude Opus 5.5) drafted it on 2026-11-12, so that the plan prompt had a README to read. Claude rewrote it on 2026-11-16 at my request, for Ship It, from this folder's files. It is committed only after my review.

walker-rudy is my 2D side-scroller from Assignment 2: Rudy crosses Level 1, past spikes, goblins and a waystone checkpoint, to the teleport circle. This assignment animates him, as [CHANGE-BRIEF.md](CHANGE-BRIEF.md) specifies:
- **a looping run cycle.** A sprite clip, a `Sprite2D` with an `AnimationPlayer` frame track, on a 4 × 4 sheet packed from his own frames (`run`, `sword_run`);
- **the sword slash, the committing action.** A cutout rig keyed as resource text, with startup, active and recovery phases (`slash`);
- **one authority.** One `AnimationPlayer`, `Rudy/Look/AnimationPlayer`, draws him. `rudy.gd`'s `_pick_clip()` alone chooses what it plays, every physics tick.

| | |
|---|---|
| Starting point | Tag `a6`. `game/` is `../assignment-6/game/` as committed at `a6`, copied with `git archive` (`476621f6`, 168 files). The game itself started in Assignment 2 from an empty repository, with no starter code or art. No change of game since Assignment 2 |
| Godot | 4.7.2.stable.official.ed1daf0bf, GL Compatibility renderer |
| Machine | macOS 15.1, Apple M3. Not tested on any other system |
| Final film | Not made yet |

## Run it

From this folder, import the project once in a fresh clone, then run it. Or open `game/project.godot` in Godot 4.7.2 and press F5.

```bash
godot --headless --path game --import
```

```bash
godot --path game
```

To watch the animation slowly:

```bash
godot --path game --time-scale 0.25
```

## Controls

- A/D or ←/→ move. On the ground, a tap of the other direction turns Rudy on the spot; hold it to move.
- Space, W or ↑ jump.
- J or X slash, once Rudy has the sword.
- Enter starts play on the title, and plays the level again on the end card.
- Esc pauses and resumes. M mutes the music and N the sound effects. F1 shows the debug line, and F9 turns vsync off and on.

## What this assignment added

| What | Where |
|---|---|
| The sheet, packed by code from the 16 frames, and its credits | `game/content/rudy/sheet/`, `tools/pack_rudy_sheet.py` |
| The rig's parts, cut by code from the slash frame, and their credits | `game/content/rudy/rig/`, `tools/cut_slash_rig.py` |
| The clip library: 13 clips as resource text, each with its `step` | `game/animations/rudy_animations.tres` |
| The player and the rig under `Look`; the selector returns clip names | `game/content/rudy/rudy.tscn`, `rudy.gd`, `rudy_look.gd` |
| The pin, the read-back, the state test and the edge test | `game/tests/test_rudy_*.tscn` |
| The preview scenes the frame strips are captured from (fixtures) | `game/previews/slash_preview.tscn`, `run_preview.tscn` |
| The strips | `captures/` |
| The probes behind the brief, the wrapper and `CLAUDE.md`; the motion reference; the mutations | `evidence/` |

## How to reach each state

| State | How |
|---|---|
| Idle | Stand still, or wait on the title |
| Run | Hold a direction on the ground. The cycle restarts from RUN-A every time he enters it |
| Rise, fall | Jump. He shows the falling pose only if he was moving sideways when the fall began |
| Slash | Pick up the sword and shield at x 2500, then press J or X. It plays to its end unless a hit, a fall out, a respawn or the circle ends it |
| Hurt | Touch a goblin other than by landing on it from above, which defeats the goblin; or touch the spikes (x 1065 and 5180). With the sword, a hit knocks the sword away instead of costing a heart |
| Defeat | A hit that takes the last of his 3 hearts. A fall that takes the last heart starts the level over without this pose |
| Respawn | After a fall into a pit, at the last checkpoint: the start, or the waystone (x 4000) once it is lit. After a defeat, at the start |
| Celebrate | Reach the teleport circle (x 7200) |

## Tests

Run every test through the wrapper, from this folder:

```bash
scripts/run-test.sh <test-file in game/tests/> <fps|realtime> [timeout-seconds]
```

It writes `logs/<test>_<fps>fps.log`. It fails on `SHADER ERROR`, `SCRIPT ERROR`, resource-load lines and `couldn't resolve track`, whatever Godot's exit code ([evidence/load-error-probe/](evidence/load-error-probe/README.md)). At `09ce1cb7`, every test passes with 0 FAIL:

| Test | Mode | Result |
|---|---|---|
| `test_rudy_pin.tscn` | 60 | 20 PASS (T1, T2 and T6 re-pinned in `e45658e6`) |
| `test_rudy_clips.tscn`, the read-back | 60 | 51 PASS |
| `test_rudy_states.tscn` | 60 | 99 PASS |
| `test_rudy_edges.tscn` | 60; 30 | 108 PASS; 66 PASS |
| `checks.tscn` | 60 | 141 PASS |
| `invulnerable_tint_checks.tscn` | 30, 60 and 144 | 15 PASS each |
| `test_slash_sparks_config.gd` | 60 | 108 checks |
| `test_slash_sparks_state.tscn` | 60 | 14 PASS |
| `test_run_dust_config.gd` | 60; realtime | 61 checks each |
| `test_run_dust_state.tscn` | 60 | 14 PASS |

[TEST-REPORT.md](TEST-REPORT.md) has every result, the mutations and the human checks.

## Frame strips

The previews are fixtures, not the game. They run Level 1 with its enemies frozen, the real Rudy, and scripted key events. To watch one, or capture it (each capture also writes a per-frame log):

```bash
godot --path game res://previews/slash_preview.tscn --debug-collisions
```

```bash
godot --path game res://previews/slash_preview.tscn --write-movie "$PWD/captures/slash/r<N>/frame.png" --fixed-fps 30 --quit-after 90 --debug-collisions 2>&1 | tee logs/slash_preview_r<N>.log
```

- **Other captures.** Add `-- second-tick` for the second tick offset. Use `run_preview.tscn`, with `-- sword` for the sword form.
- **Who ran them.** Strips r0 and r1 were captured by Claude at my request, not by me as the text asks (`TUNING.md`).

## Known limitations

- **Every change of state is a cut.** Whole frames cannot cross-fade, and the rig appears and disappears on a tick (`CHANGE-BRIEF.md`, section 3).
- **The slash's last frame pops.** On its last tick the blade points forward and up, and then the idle pose shows with the sword low.
- **The sword kinks at the fist.** The grip and pommel stay in the body part while the blade turns (`CHANGE-BRIEF.md`, Revision 4).
- **The hitbox comes before the blade.** It is live on swing ticks 2–4 while the blade is still above his head (Claude's reading of r0, a claim; not changed).
- **The repaired band.** Removing the arc left a repaired band on the robe and shield: 3,413 pixels, 308 of them not exact (`sessions/session-6b-answer.md`). No check looked for a ghost band on its own. My first verdict saw no other obvious problem (`TUNING.md`, r0).
- **The cadence.** Rudy steps every 0.125 s, faster than the motion reference's runners: a cartoon scurry (`CHANGE-BRIEF.md`, section 8).
- **Four transitions** in section 3's table cannot be reached on Level 1 (`CHANGE-BRIEF.md`, Revision 6).
- **Headless runs show structure, not feel.** They show the clips' structure and the state machine's choices, not whether the motion reads. That rests on my human checks.
- **What the text asks for that is not done:**
  - the captures were run by Claude, not by me;
  - no tuning revision was driven by my own observation in play.

## Files

- [CHANGE-BRIEF.md](CHANGE-BRIEF.md): the change, committed before the first prompt, with Revisions 2–6.
- [CLAUDE.md](CLAUDE.md): the agent's project facts, its draft by Step 1's session and my review committed apart.
- [TUNING.md](TUNING.md): rounds r0 and r1, with Claude's readings and my verdicts.
- [TEST-REPORT.md](TEST-REPORT.md): every check of "Use It".
- [FRICTIONAL.md](FRICTIONAL.md): the dated log of what was tried, what happened, and who did what.
- [SOURCES.md](SOURCES.md): credits, tools, and the human and AI contributions.
- `sessions/`: every prompt and every session's answer. `sessions/transcripts/` holds each `claude -p` stream, redacted: in full when it is under 1 MB, and as a labelled excerpt when it is over (`tools/redact_transcripts.py`).
