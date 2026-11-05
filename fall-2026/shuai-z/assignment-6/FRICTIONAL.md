# FRICTIONAL — Assignment 6, walker-rudy

What I tried, what I expected, what happened, how I checked it, what I did about it, and what I learned, with my work and Claude's kept apart.

**How this file is written.** Claude Code drafts each entry from our Claude Code conversation, and I check it against what I actually did. Where I recorded no expectation or lesson, the entry says so instead of inventing one. Each entry says when it was written; entries written after the event are labelled as retrospective.

**Tools.** Claude Opus 5.5 in Claude Code (desktop app), Claude Code 2.1.310; Godot 4.7.2; macOS on an Apple M3.

---

## 2026-11-04 — Reading the assignment, and keeping to the 2D game

*Retrospective, written on 2026-11-04, from the conversation.*

- **Attempt (me):** I pasted the assignment and asked Claude, in Chinese, what it asks me to do step by step. Claude explained the steps.
- **My decision:** Assignment 5 is submitted. This assignment changes only my 2D game, so the 3D props scene from Assignment 3 is not copied into this folder.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude explained the assignment; I decided the scope.

## 2026-11-04 — Setup: the folder, the wrapper and the baselines

*Retrospective, written on 2026-11-04, from the conversation. Commits `e61e8025` and `47ce9e2d`.*

- **Attempt (Claude, at my request):**
  - Branched `shuai-z/assignment-6` from tag `a5`.
  - Copied `assignment-5/game` into `assignment-6/game/` with `git archive`, so only committed files came across: 142 files. After a headless import it did not differ from its source (`diff -rq`, ignoring `.godot/`).
  - Wrote this folder's `.gitignore`: it keeps the `.godot` cache out and lets the game's six `.wav` sound effects past the root `*.wav` rule.
  - At my request, committed `CLAUDE.md` empty, so that Step 1's scoped session writes it from nothing.
- **The wrapper (Claude):** the course's Assignment 6 `scripts/run-test.sh`, changed in four places listed at its top: `--path game`; a `.tscn` test runs as the scene; Godot is found off PATH; it runs from this folder.
- **Baselines (Claude), through the wrapper:** `checks.tscn` 141 PASS and 0 FAIL at 60 fps; `invulnerable_tint_checks.tscn` 15 PASS at 30, 60 and 144 fps; no `SHADER ERROR` or `SCRIPT ERROR`. Each log differs from Assignment 5's only in the random camera-shake offset and the ObjectDB leak warning at exit (`logs/`).
- **A false sentence in a commit message, caught before any push.** The first commit's message said I had reviewed the files before committing. I had read only Claude's summary. Claude amended the local commit (`8f59f3ef` became `e61e8025`) to say it was committed on my word.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude did the setup, the wrapper and the baselines; I asked for them and decided each commit.

## 2026-11-04 — Choosing the two effects, and the Compatibility probe

*Retrospective, written on 2026-11-04, from the conversation. The probe is commit `9e19fe47`.*

- **Attempt (me):** I asked Claude to choose Effect A, and asked for Effect B to be a trail behind Rudy when he runs.
- **Two blockers Claude found:**
  - **Effect A.** Claude's first candidate was a burst when a goblin is defeated. The goblins start 1,500 px or more apart and patrol 400 px, so no two ever come within about 1,100 px (`game/content/level_1/level_1.tscn:69-77`, `game/content/goblin/goblin.gd:27`). Two defeats inside one burst lifetime cannot happen in real play, so the retrigger rule could never be exercised. Rudy's `hit` cannot repeat that fast either, because of his 1.2 s invulnerability.
  - **Effect B.** Claude wrote a throwaway probe (`evidence/compat-probe/`) and ran it under both renderers. Under GL Compatibility, the game's renderer, a `GPUParticles2D` with `trail_enabled` drew nothing, and the engine warned `The Compatibility renderer does not support particle trails.` Under Forward+ the same emitter drew trails. Damping and a box emission shape worked under both.
- **A third finding:** `RenderingServer.viewport_get_measured_render_time_gpu()` read 0.0 ms under both renderers. So the Visual Profiler's GPU time may also be unreadable on this Mac.
- **A probe that proved nothing:** a turbulence emitter in the first version stayed at its origin under both renderers. Its settings were wrong, so it was dropped and the README says so.
- **My choice,** from the options Claude put to me: Effect A is sparks when the sword's hitbox goes live (cuts at least about 0.32 s apart, bursts living 0.45 s, so the retrigger rule is exercised). Effect B is a world-space dust trail, an ordinary emitter with `local_coords` off, as Chapter 9's Dodge the Creeps makes its trail. I kept the renderer, because switching it would change the whole game.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude found the blockers, wrote and ran the probe, and proposed the options; I chose the effects.

## 2026-11-04 — The change brief

*Retrospective, written on 2026-11-04, from the conversation. Commit `cc9f7195`.*

- **Attempt (me):** I asked Claude to draft the whole of CHANGE-BRIEF.md, as I do for course documents, with its authorship stated in the file.
- **The draft (Claude):** the state of the game with file and line references, a background luminance table, both effects' intent, settings and rules (A1-A5, B1-B5), the boundaries, the evidence split, frame-by-frame predictions for both strips, 13 predicted failures, the prices and budget, and the six short answers.
- **Corrected before I read it (Claude):** rechecking its own draft, Claude found two of its statements wrong and fixed them: the yellow sparks' contrast against the sky and the wheat (about 1.1:1 and 1.5:1, which is why each spark has a dark rim), and the goblins' spacing. It also printed every line the brief cites to check it.
- **Review (me):** I read the brief and said to commit it. The probe went in first, then the brief alone, before any Step 1 prompt.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude drafted the whole brief, including the predictions and short answers; I chose the effects, read it and approved the commit.

## 2026-11-04 — Step 1: the CLAUDE.md draft

*Written on 2026-11-04, from the conversation. Prompt `sessions/prompt-1.txt`; transcript `sessions/session-1.jsonl`; commit `998fd175`.*

- **The prompt (Claude):** the course's Step 1 prompt with this folder's paths (`game/` for `godot/`, this folder as the repository root), and "Write" for "Revise", because `CLAUDE.md` was empty. The `game/shaders/` rule is stated in the prompt instead of "keep the existing rule".
- **The command (Claude, at my request):** the course's read-only command, plus a deny rule on `game/shaders/` for Edit and Write written as an absolute path (`//Users/...`), because Assignment 5 found that an agent's `cd` re-anchors relative rules. `CLAUDECODE` was unset, because the run started inside another Claude Code session.
- **The run:**
  - It started at 21:04:12 EST and ended at 21:06:20 EST.
  - Its result event reads `"subtype":"success"`, `"is_error":false` and `"terminal_reason":"completed"`: 13 turns in 121 s, model `claude-opus-5-5`, Claude Code 2.1.310, `total_cost_usd` 1.16.
  - **Permission denials: 2.** Both were Bash commands that counted log lines with `grep -c` inside `$(...)`. The agent read the logs another way instead.
  - Its final reply was in Chinese; the file it wrote is in English.
- **Checks (Claude, in this conversation):**
  - A hash of every file in the folder before and after the run: only `CLAUDE.md` changed, apart from the transcript.
  - `git diff --stat game/shaders/ scripts/run-test.sh` printed nothing.
  - `CLAUDE.md` is 84 lines, byte-identical to its one Write. The first line is a heading, which is right because there is no `AGENTS.md`, and `@CHANGE-BRIEF.md` is on its own line.
  - The transcript holds no e-mail or account field.
  - Claude printed every line the draft cites.
- **Left for the review:** two imprecise references, 18 property names and the `godot` binary listed as unconfirmed, and the "Headless facts" block.
- **Expected / learned:** none recorded.
- **Human / AI:** the scoped `claude -p` session wrote `CLAUDE.md`. Claude, in this conversation, wrote the prompt, ran the session and checked it. I approved the commit of the unedited draft.

## 2026-11-04 — Step 1: reviewing the CLAUDE.md draft

*Written on 2026-11-04, from the conversation. The unedited draft is commit `998fd175`; the review is commit `a3242b9d`.*

- **Attempt (Claude, at my request):** check every reference and add the "Headless facts" block, confirmed on this machine.
- **The probe (Claude):** `evidence/headless-probe/probe_particles.gd`, in a throwaway Compatibility project, run headless at `--fixed-fps 60` and once in a window; then the Compatibility probe under Movie Maker with `--headless`. Logs: `logs/probe_particles_headless.log`, `logs/probe_particles_window.log`, `logs/probe_movie_headless.log`.
- **Two mistakes in Claude's probe, fixed before the logs were kept:**
  - The first run stopped at a parse error: Claude called `OS.get_current_rendering_driver_name()`, which is on `RenderingServer` in 4.7.2.
  - The first version hid the container after the burst had already finished, so "hidden: emitting false" said nothing about hiding. Claude restarted a burst before hiding it: hiding leaves `emitting` true.
- **What it found:**
  - Headless, the frame cannot be read back, and the error comes from the dummy renderer. In a window the same probe read back a frame with 2,653 particle pixels.
  - Node state is observable: a 0.45 s one-shot sent `finished` at frame 27 and showed `emitting` false by frame 28; `amount_ratio` reads back; a container's child count gives the instance count.
  - `capture_rect()` returned an empty rectangle headless, and also in a Compatibility window, where the particle buffer could not be read back. A test cannot use it.
  - Headless CPU time per frame: empty scene 0.0028 ms, 20,000 GPU particles 0.0040 ms, 20,000 CPU particles 0.74 ms.
  - Movie Maker under `--headless` crashed with signal 11 and wrote no frame.
  - Every name the brief uses exists in 4.7.2. **The surprise:** the Godot 3 names `initial_velocity`, `scale`, `damping` and `hue_variation` also exist, as editor-only `Vector2` ranges. A scene line `scale = 2.0` loads without an error and sets the scale to 0.
- **Changes to CLAUDE.md** (84 lines, now 91): three references corrected (`is_on_floor()` at `rudy.gd:298`; the music also runs while paused, `music.gd:40`; the "read back" claim replaced by the ClassDB result); the Headless facts block, with the claim that no GPU process runs marked as an inference; the Godot 3 names note; three settled items removed from Unconfirmed.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude did the review and wrote and ran the probe; I read the summary and approved the commit.

## 2026-11-04 — Revision 2 of the brief: Godot 3 names in a scene file

*Written on 2026-11-04, from the conversation. The commit that adds this file.*

- **Why:** the review's probe showed that failure 1 in the brief predicts the wrong result for `scale`. I asked Claude to add the revision and this file.
- **A second probe (Claude):** `evidence/headless-probe/probe_mutation.gd` loads scene files written with Godot 3 lines (`logs/probe_mutation.log`):
  - Godot saves `initial_velocity_min` before `initial_velocity_max`. So the brief's Step 2 mutation, renaming that line to `initial_velocity`, loads as 0 to 420 px/s, not as speed 0. With the lines the other way round it loads as 0 to 0.
  - `scale = 0.7` followed by `scale_max = 1.0` loads as 0 to 1.
  - `flag_disable_z` still sets `particle_flag_disable_z`, but `flag_align_y` is dropped and `particle_flag_align_y` stays false.
  - A `Particles2D` node with a `ParticlesMaterial` sub-resource loads as a `GPUParticles2D` with a `ParticleProcessMaterial`, its values kept.
  - None of these printed a warning or an error.
- **Changes:**
  - CHANGE-BRIEF.md gains Revision 2: the corrected failure 1, the new prediction for the Step 2 mutation (the configuration test fails on `initial_velocity_min`; on screen the burst looks almost the same), and two imprecise references from Revision 1 (`rudy.gd:215`; the music's `music.gd:40`). Revision 1 is unchanged.
  - CLAUDE.md gains one line under "Godot 4 names": the remapped class names and the dropped `flag_align_y`.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude wrote and ran the probe and drafted the revision, the CLAUDE.md line and this file; I asked for them and decided the commit.

## 2026-11-04 — Step 2: Effect A, its configuration test and its preview

*Written on 2026-11-04, from the conversation. Prompt `sessions/prompt-2.txt`; transcript `sessions/session-2.jsonl`; commit `ea4419ae`.*

- **The prompt (Claude):** the course's Step 2 prompt with this folder's paths and the effect's name, plus one sentence saying where the session may write.
- **The command (Claude, at my request):** `dontAsk`, as Assignment 5's implementation runs, with writes allowed only in `game/effects/`, `game/previews/` and `game/tests/test_slash_sparks_config.gd`; the wrapper under four spellings; a headless import; read-only `git`; an absolute deny rule on `game/shaders/`.
- **The run:** 22:06:55 to 22:10:38 EST: `success`, `is_error` false, `terminal_reason` completed, 19 turns, $1.53. **Permission denials: 3**: a chained read of several files, the wrapper with `; echo` after it (it then ran the wrapper alone), and its own headless run of the preview, which no rule allowed.
- **What it built:** the effect scene, a configuration test of 108 checks that also scans the scene text for Godot 3 names, and a preview over Level 1 with the bursts fired on frames 10 and 20. Its first test run hit a GDScript type-inference error in its own test, which it fixed.
- **Checks (Claude, in this conversation):**
  - Only the four new files, their logs and the transcript appeared; nothing existing changed; `game/shaders/` and the wrapper are untouched.
  - Every value in the effect scene matches the brief's table.
  - The configuration test passes at 30, 60 and 144 fps; `checks.tscn` still passes 141 (it now finds 83 `res://` paths, all present) and the tint test 15.
  - Claude ran the preview headless, which the session could not: Burst1 fired on frame 10 and Burst2 on frame 20.
- **Noted:** at zoom 1 the preview frames x 1240–3160, wider than the brief's x 1950–2450, so the frozen goblins and the sword pickup are in the picture.
- **Expected / learned:** none recorded.
- **Human / AI:** the scoped session wrote the effect, the test and the preview. Claude wrote the prompt, ran the session and checked it. I approved the commit of its files unedited.

## 2026-11-04 — Step 2: the first strip, my first look, and tuning round r1

*Written on 2026-11-04, from the conversation. The record of the round is `TUNING.md`, "Effect A, revision r1".*

- **The capture:** I asked Claude to run it. It ran the course's Movie Maker command in a window on my screen, into `captures/slash_sparks/r0/`. The 60 frames took 14 s to record, so the window played at about a seventh of real speed.
- **A command that failed:** when I ran the preview myself, Godot said `Invalid project path specified: "game"`. Claude had left the session's shell in `captures/slash_sparks/r0/` after listing the frames. Claude moved it back and played the preview for me three times at real speed instead (`--fixed-fps 30 --max-fps 30`).
- **My first look,** before Claude opened any frame: the sparks are too sparse, too few. Claude wrote it into `TUNING.md` in English, with my Chinese words beside it.
- **The round:** Claude read the six frames and agreed with me, proposed `Sparks` `amount` 14 → 28 with a prediction for each frame, and I approved it. Claude made only that change, moved the test's expected value, ran the test at 60, captured r1 and compared it with its prediction. Frames 10–15 matched; frames 20 and 30 showed more of the first burst than it predicted, and it wrote down why. I watched r1 three times at real speed and kept the change.
- **After the verdict (Claude):** the brief's Revision 3 records the new value and the new peak of 58 particles; only frames 10, 12, 15, 20, 30 and 50 of each strip are kept.
- **Still to do for Step 2:** the two mutations of the effect scene, recorded in TEST-REPORT.md.
- **Expected / learned:** none recorded.
- **Human / AI:** I judged the preview twice and approved the change. Claude ran the captures and the plays, read and compared the strips, made the change and drafted the records.

## 2026-11-04 — Step 2: the two mutations of Effect A

*Written on 2026-11-04, from the conversation. The results are in `TEST-REPORT.md`, "Mutations".*

- **Attempt (Claude, at my request):** the assignment's two mutations of `game/effects/slash_sparks.tscn`, one line each, each followed by the configuration test at 60 fps and a `git checkout` of the file.
- **Results:** the Godot 3 name (`initial_velocity_min` → `initial_velocity`) exited 1 with two failures, the text scan and the value; the changed value (`spread` 30 → 45, brief unchanged) exited 1 with one failure. The file's SHA-1 matched the committed one after each restore, and the test passed again.
- **The game check:** the effect is not in the game yet, so Claude captured the mutated preview in a window instead. The burst still fired and still read as a spray, with a few slow sparks left near the hitbox.
- **Logs:** the wrapper writes every run of the test to the same log, so Claude copied each mutation's log to its own name before restoring the file.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude ran the mutations, the capture and the checks, and drafted TEST-REPORT.md; I asked for them.
