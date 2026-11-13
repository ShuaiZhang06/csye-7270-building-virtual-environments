# Session 1, the plan: my decision

The course text says of the plan prompt: "You decide whether to accept the plan." On 2026-11-12 I accepted the plan in `session-1-answer.md` with the four corrections below ("接受并修正": accept, with the corrections). Claude Code reviewed the answer against `CHANGE-BRIEF.md` and the revision note, and drafted this record at my request.

## The session

- **Prompt:** `prompt-1.txt`, the course text's plan prompt with three changes:
  - input only through `Input.parse_input_event`, as the revision note requires;
  - a test scene rather than a `--script` SceneTree script, because `rudy.gd` names the `Sfx` autoload (`CLAUDE.md`);
  - "Write your answer in English."
- **Run:** headless `claude -p` with read-only tools (Read, Glob, Grep, read-only git, `ls`) and Edit and Write denied. The result event was `success`, after 34 turns, about 206 s and USD 1.72. The one Bash call, a compound `ls -R | grep … && wc -l`, was denied, so the session ran no Godot command. No file in the repository changed.
- **README.** The plan prompt reads `README.md`, which this folder lacked (brief, Revision 2). A short README was written and committed first (`9194c98b`), so the prompt reads it as written.
- **Checked.** Claude spot-checked eight of the answer's line references (`main.gd:106-109`, `:188`, `sword_pickup.gd:49`, `rudy_look.gd:34`, `checks.gd:732`, `goblin.gd:107-109`, `spikes.gd:18`, `main.tscn:15`); all were right.
- **Not committed.** The raw stream, `session-1.jsonl`, stays on this machine: it holds local paths and session IDs.

## What it found that the brief did not

`checks.gd:732` accepts a swing within ±2 ticks of `slash_time`, so it cannot tell the measured 17-tick swing from 18 or 19 ticks. It is noted, not changed: earlier tests stay as they are.

## The corrections

1. **Step 2's expected FAILs are T1 and T2 as well as T6.** Today's code shows `RUN-A` for 7 ticks first, because its clock advances before it is read. The new clip shows it for 8, because its key at 0.125 s is reached on the eighth tick (brief, section 7). So the first-cell lines of T1 and T2 will fail after the wiring, and are classified then, with T6.
2. **Make the clips, then wire them.** The revision note splits "Make the clips" from "Wire them", and its sprite and rig prompts end "Do not wire the clip into the state machine yet". Steps 2 and 4 each become two steps:
   - 2a, the sprite clips and their read-back test, unwired;
   - 2b, the wiring;
   - 4a, the rig and its clip with their read-back, unwired;
   - 4b, the wiring.
3. **The pin's scene: the test's own scene, as proposed** (a floor, the sword pickup, spikes and Rudy, with no `Main`). The states that need `Main` are left out of the pin: the title, falling out, defeat, respawn and celebrate. They stay covered by `checks.tscn`, an earlier test that runs the real `Main` and must keep passing unchanged, and later by `test_rudy_states.tscn`.
4. **Add the mutation checks.** After the edge tests, each strengthened test is run on the pre-fix commit in a `git worktree` outside this folder, and must fail there (brief, section 6; the revision note).

## The accepted plan, as corrected

| Step | What |
|---|---|
| 0 | The pin, `game/tests/test_rudy_pin.tscn` and `.gd`. No game change |
| 1 | `tools/pack_rudy_sheet.py` and the 4 × 4 sheet. No game change |
| 2a | The sprite clips and `test_rudy_clips.tscn`, not wired |
| 2b | The wiring: the Sprite on the sheet, `rudy.gd` returns clip names, `_run_clock` and `run_frame_time` go. Expected FAILs: T1, T2 and T6 |
| 3 | `tools/cut_slash_rig.py` and the three rig parts. No game change |
| 4a | The `SlashRig` nodes and the keyed `slash` clip, with their read-back, not wired |
| 4b | The slash wired: I1–I8 must pass |
| 5 | `test_rudy_states.tscn` and `test_rudy_edges.tscn` (E1–E7, at 60 and at 30 with both tick offsets) |
| 5m | The mutation checks, in a worktree |
| 6 | Re-pin the asked-for TIMING lines, after I have played them |

Each step gets its own prompt and its own commit, which I make.
