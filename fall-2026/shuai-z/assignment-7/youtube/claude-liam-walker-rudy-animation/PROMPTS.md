# PROMPTS — A Run and a Slash for Walker Rudy.

Every prompt shown or read in the film.

## B00 — Jambo, Liam

**Status:** reconstructed prompt — illustrative, not a transcript

```text
Please use Walker to convert my game design document about Walker Rudy — a chibi boy who crosses the Harvest Fields with a sword — into two animations: a looping run cycle sliced from a sprite sheet of his own frames, and a sword slash on a cutout rig whose startup, active and recovery frames come from a phase table, each clip read back by a test, driven by one state machine, and judged in a frame strip and in play.
```

On-screen result lines (each checked in FACTCHECK.md):

- Repo walker-rudy · assignment-7/game at 775c14c · Godot 4.7.2 · GL Compatibility · one 2D game.
- Built: run and sword_run (a 4 × 4 sheet, a frame track) and slash (a cutout rig keyed as resource text), one AnimationPlayer.
- Clips and tests: scoped claude -p sessions · every verdict and approval: shuai-z · captures: Claude, at shuai-z's request.

## BHTF — Your turn.

**Status:** suggested prompt for the viewer

```text
Read my CHANGE-BRIEF.md and the slash clip in game/animations/rudy_animations.tres. Before you change anything, let me predict by hand Grip's angle on strip frame 33 and the tick the blade passes horizontal (about +30.9°) if the phase table's middle active key moves from tick 5 to tick 4. Then change the phase table, build the key from it, update the read-back's expected tick in game/tests/test_rudy_clips.gd, run scripts/run-test.sh test_rudy_clips.tscn 60, and print the slash preview's Grip values beside my prediction. I run the capture myself.
```

## The prompts behind the work shown

The film quotes no prompt from the build sessions. The scoped `claude -p` prompts it refers to are in the assignment folder's `sessions/`, `prompt-1.txt` to `prompt-18c.txt`, each beside its answer; `sessions/transcripts/` holds the redacted streams. The ones the film names: `prompt-3.txt` (the sheet), `prompt-4.txt` and `prompt-5.txt` (the sprite clips and the wiring), `prompt-6.txt` and `6b` (the rig's parts), `prompt-7.txt` and `prompt-8.txt` (the rig clip and its wiring), `prompt-9.txt`, `10`, `13` and `14` (the state and edge tests), `prompt-12.txt` (the library's move and `step`), `prompt-17.txt` and `17b` (the previews), `prompt-18.txt`, `18b` and `18c` (the r0 reading, the r1 change, the r1 comparison).
