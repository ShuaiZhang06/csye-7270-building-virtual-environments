# walker-rudy — animation (Assignment 7)

CSYE 7270, Assignment 7: *Doing Animation with Claude and Godot*. By Shuai Zhang.

**How this README was made:** Claude Code (Claude Opus 5.5) drafted it on 2026-11-12 at my request, from this folder's files, so that the plan prompt has a README to read. It describes the game as it stands before any animation change, and it is completed at Ship It. It is committed only after my review.

walker-rudy is my 2D side-scroller from Assignment 2: Rudy crosses Level 1, past spikes, goblins and a waystone checkpoint, to the teleport circle. This assignment adds one layer, animation, as [CHANGE-BRIEF.md](CHANGE-BRIEF.md) specifies:
- a looping **run cycle**, as a sprite clip from Rudy's own frames;
- the **sword slash**, as a committing action on a cutout rig;
- both driven by Rudy's existing state.

**None of it is built yet.**

| | |
|---|---|
| Starting point | Tag `a6`. `game/` is `../assignment-6/game/` as committed at `a6`, copied with `git archive` (`476621f6`, 168 files). The game itself started in Assignment 2 from an empty repository, with no starter code or art |
| Godot | 4.7.2.stable.official.ed1daf0bf, GL Compatibility renderer |
| Machine | macOS, Apple M3. Not tested on any other system |
| Final film | Not made yet |

## Run it

Import the project once in a fresh clone, from this folder, then run it, or open `game/project.godot` in Godot 4.7.2 and press F5:

```bash
godot --headless --path game --import
```

```bash
godot --path game
```

## Controls

- A/D or ←/→ move. On the ground, a tap of the other direction turns Rudy on the spot; hold it to move.
- Space, W or ↑ jump.
- J or X slash, once Rudy has the sword.
- Enter starts play on the title, and plays the level again on the end card.
- Esc pauses and resumes. M mutes the music and N the sound effects. F1 shows the debug line, and F9 turns vsync off and on.

## How to reach each state, today

| State | How |
|---|---|
| Idle | Stand still, or wait on the title |
| Run | Hold a direction on the ground |
| Rise, fall | Jump. He shows the falling pose only if he was moving sideways when the fall began |
| Slash | Pick up the sword and shield at x 2500, then press J or X |
| Hurt | Touch a goblin other than by landing on it from above, which defeats the goblin; or touch the spikes (x 1065 and 5180). With the sword, a hit knocks the sword away instead of costing a heart |
| Defeat | A hit that takes the last of his 3 hearts. A fall that takes the last heart starts the level over without this pose |
| Respawn | After a fall into a pit, at the last checkpoint: the start, or the waystone (x 4000) once it is lit. After a defeat, at the start |
| Celebrate | Reach the teleport circle (x 7200) |

Today every state shows one whole frame, which `rudy.gd` picks every physics tick and `rudy_look.gd` swaps in; the run alternates two frames. CHANGE-BRIEF.md section 1 has the detail.

## Tests

Run every test through the wrapper, from this folder:

```bash
scripts/run-test.sh <test-file in game/tests/> <fps|realtime> [timeout-seconds]
```

It writes `logs/<test>_<fps>fps.log`. It fails on `SHADER ERROR`, `SCRIPT ERROR` and resource-load lines, whatever Godot's exit code ([evidence/load-error-probe/](evidence/load-error-probe/README.md)). The earlier tests all pass on this starting point, 0 FAIL each:

| Test | Result |
|---|---|
| `checks.tscn` at 60 | 141 PASS |
| `invulnerable_tint_checks.tscn` at 30, 60 and 144 | 15 PASS each |
| `test_slash_sparks_config.gd` at 60 | 108 checks |
| `test_slash_sparks_state.tscn` at 60 | 14 PASS |
| `test_run_dust_config.gd` at 60 | 61 checks |
| `test_run_dust_state.tscn` at 60 | 14 PASS |

## Files so far

- [CHANGE-BRIEF.md](CHANGE-BRIEF.md): the change, committed before the first prompt, with its revisions.
- [CLAUDE.md](CLAUDE.md): stable project facts for the agent.
- [evidence/](evidence/): the probes behind the wrapper and the brief, and the motion reference.
