# mutations — the assignment's four, each in its own git worktree

The text's Step 6: "Make each change in a git worktree, so your working tree is never left broken … Confirm each one makes its test exit 1, then throw the worktree away." Brief Revision 5 lists the four and predicts 1–3 fail the read-back and 4 passes.

**How it was made:** Claude Code (Claude Opus 5.5) wrote `mutate.sh` and ran it on 2026-11-13, 18:31–18:32 EST, in our conversation, at my request. The tree was commit `f1680bfb`. The script's output for each run is `logs/mutation_<id>.txt`, and the read-back's log from inside each worktree is `logs/mutation_<id>_test_rudy_clips_60fps.log`.

## How each run went

`mutate.sh <id> <output folder>`, from anywhere. The committed copy finds the repository from its own location; the copy that ran had the repository and scratch paths written out, and was otherwise the same:
1. `git worktree add --no-checkout --detach ../a7-mutate HEAD`, beside the course repository, as the text has it. The repository is a sparse checkout, so the script then checks out only `fall-2026/shuai-z/assignment-7` in the worktree. The main working tree's sparse setting is not touched.
2. `godot --headless --path game --import` in the worktree, since a fresh checkout has no import cache.
3. The change, made by a short Python edit that asserts it matched exactly once. The worktree's `git diff` is printed.
4. `scripts/run-test.sh test_rudy_clips.tscn 60`, the worktree's own wrapper and read-back, and its exit code.
5. `git worktree remove --force` and `git worktree prune`. After the last run, `git worktree list` shows only the main tree.

## Results

| Run | The change | Read-back | What caught it |
|---|---|---|---|
| C0 | none, a control | **exit 0**, 51 PASS | — |
| M1 | slash track 2's subname `rotation_degrees` → `rotation_degree` (`SlashRig/Lean/Grip`), in the clip only | **exit 1**, 6 of 51 fail | check 1, `track_problems()`: "slash track 2: Grip has no property rotation_degree"; check 2's track and Grip samples; the NEGATIVE control and the two NEGATIVE lines built on that track. The wrapper flagged nothing, since a missing property prints nothing |
| M2 | run's `loop_mode` 1 → 0 (`LOOP_NONE`) | **exit 1**, 2 of 51 fail | check 3: "run loop_mode 0, want 1"; the NEGATIVE control |
| M3 | run's first frame key 1 → 16, which is `hframes * vframes` | **exit 1**, 2 of 51 fail | check 4: "run key 0 cell 16 is outside the sheet's 16 cells"; the NEGATIVE control |
| M4 | `game/.godot` deleted, then `--import` from the empty cache | **exit 0**, 51 PASS | nothing, as predicted |

**Why M4 does not fail.** The rig is keyed as resource text in `game/animations/rudy_animations.tres`, not imported from a 3D file, so no clip, loop mode or key lives in the import cache. Only the textures (the sheet and the rig parts) are imported, and the read-back's check 6 and check 8 read their `.import` settings after the fresh import, and passed. This is the result the text asks to record: "including a mutation that did not fail its test, and why".

**The NEGATIVE control fails in M1–M3, as it should.** It runs the checks on an undamaged copy of the scene's player. In a mutated worktree that copy holds the mutation too, so the control reports it as well.
