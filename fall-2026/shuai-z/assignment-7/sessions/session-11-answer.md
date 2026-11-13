I rewrote `CLAUDE.md`. It is now **105 lines**, and no other file changed. There's no `AGENTS.md`, so the file doesn't start with `@AGENTS.md`. I ran no tests: every count in the file comes from the existing `logs/`.

## What changed from the old CLAUDE.md, and why

- **Top line:** it now says a scoped Claude Code session drafted the file from `sessions/prompt-11.txt` on 2026-11-13, and that you review it. It also no longer says "where this file and the brief differ, the brief holds". Revision 5 withdraws Revision 2, so the brief is now imported, not just pointed to.
- **"Project context"** replaces "The project" and adds what this change needs, each with a file reference:
  - **Version and renderer:** Godot 4.7.2 stable, and the renderer from `project.godot:95-96`.
  - **State machine:** `rudy.gd` owns it. `_pick_clip()` hands a clip name to `RudyLook.play_clip()` every physics tick.
  - **The clips:** both sit on one player, `Look/AnimationPlayer`, set to the physics callback. `run` and `sword_run` play on `Look/Sprite` as a frame track. `slash` plays on the `Look/SlashRig` cutout rig, and its six track paths are listed.
  - **The library:** it is at `game/content/rudy/rudy_animations.tres` today, and Revision 5 moves it to `game/animations/`. That folder doesn't exist yet. The move must also update `test_rudy_clips.gd:43` and `test_rudy_states.gd:752`, which load the library by path.
  - **Scenes the clips appear in:** `rudy.tscn`, `main.tscn` and `test_rudy_pin.tscn`; the states and edges tests load `main.tscn` while they run.
  - **Previews:** the two existing previews hold only a frozen placeholder Rudy, not the clips. The previews Revision 5 names don't exist yet.
- **Tests:** the wrapper now has the `realtime` mode, how logs are named, the timeout, and the `couldn't resolve track` failure.
  - There is an exact command for every test, with its current count: clips 46, states 81, edges 98 at 60 and 66 at 30, and checks 141.
  - The pin's 19 checks are noted with T1, T2 and T6 failing on purpose.
  - Esc was added to the keys new tests may press, because the edge test uses it.
- **New sections:**
  - **"Current change"**, followed by exactly `@CHANGE-BRIEF.md`.
  - **"Ownership"**: every file in `game/shaders/` is yours and never edited by an agent, and clips are resources, never built in code at runtime. I also added that the wrapper stays as committed, because Revision 5 says so.
  - **"One authority"**: a table giving the single writer of each animated node and property, and saying who writes `Look` and the hitbox.
  - **"Out of scope"** and **"Unconfirmed"**.
- **"Godot 4 names"** now states the rule as you asked, including `AnimatedSprite` → `AnimatedSprite2D`. It also notes that no clip sets `Animation.step` yet.
- **Git** stays read-only, with `restore` and `clean` added to the forbidden list.

## What I could not confirm

1. **That `game/shaders/` is unchanged from Assignment 6.** Revision 5 says so, but this session wasn't allowed to run shell commands, so I couldn't run `git diff`.
2. **That `Animation.step` defaults to 1/30 s in 4.7.2.** Only Revision 5 says so; no probe in `evidence/` records it. All the file says for certain is that the library has no `step` lines.
3. **That the `realtime` mode works here.** There's no `*_realtime.log`, so no test has run that way in this folder. Its description comes only from the wrapper's code.
4. **Whether the read-back test breaks the "never built in code at runtime" rule.** Its negative checks make damaged copies of existing clips in memory (`test_rudy_clips.gd:34-38`). I read the rule as applying to game code, not tests; that's your call.
5. **The tint, sparks and dust counts** come from PASS lines in `logs/`, not from runs in this session. For the sparks config log, my search found 109 lines against the 108 checks recorded, which I didn't resolve.