# FRICTIONAL — Assignment 5, walker-rudy

What I tried, what I expected, what happened, how I checked it, what I did about it, and what I learned, with my work and Claude's kept apart.

**How this file is written.** Claude Code drafts each entry from our Claude Code conversation, and I check it against what I actually did. Where I recorded no expectation or lesson, the entry says so instead of inventing one. Each entry says when it was written; entries written after the event are labelled as retrospective.

**Tools.** Claude Opus 5.5 in Claude Code (desktop app), Claude Code 2.1.302; Godot 4.7.2; macOS.

---

## 2026-10-22 — Reading the assignment against my project

*Retrospective, written on 2026-10-24, from the conversation.*

- **Attempt (me):** I pasted the assignment and asked Claude, in Chinese, what to do step by step.
- **What Claude found, by reading my folders and the course repository's chapters:**
  - My game is 2D and uses GL Compatibility; my 3D scene is a separate Forward Plus project. So the shader from code goes in the game, and the textured shader goes in the props scene.
  - Two of the game's existing checks rule out a new material on the obvious objects. `checks.gd` lines 871–877 keep the outline on Rudy's sprite. Lines 1056–1061 allow a material only on the spikes and the goblin.
  - The props scene's check, `check_props.gd` lines 85–89, reads each `.glb`'s own material colours, so the importer's Use External would make it fail.
  - The course's wrapper cannot run as given, for three reasons:
    - `godot` is not on my PATH;
    - it hard-codes `--path godot`;
    - the game's checks are a scene (`checks.tscn`), which `--script` cannot run.
  - The new branch must start from `a3`, not from my Assignment 4 branch, whose GDD commit stays off GitHub.
  - The course repository's own `assignments/05-shader-and-material.md` is an older draft; I follow the Canvas text.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude read the files and wrote the plan; I asked for it.

## 2026-10-24 — Step 0: the folder, the wrapper and the baselines

*Written on 2026-10-24, from the conversation. Commits `84658acf` and `cca08046`.*

- **Attempt (Claude, at my request):**
  - Branched `shuai-z/assignment-5` from `a3`.
  - Copied `assignment-2/game` and `assignment-3/godot` into `assignment-5/` with `git archive`, so only committed files came across: 133 and 14 files, the same as in `a3`.
- **A problem found on the way (Claude):** the course repository's root `.gitignore` ignores `*.wav`. The game's six sound effects are tracked only because Assignment 2 force-added them. A plain `git add` of the copy would have left them out, and a fresh clone would then fail the game's check that every file it names exists. Claude added an exception for `game/systems/audio/sfx/*.wav` to this folder's `.gitignore`.
- **The wrapper (Claude):** the course's `scripts/run-test.sh`, changed in four places, which are listed at the top of the script:
  - the project is an argument;
  - a `.tscn` test runs as a scene;
  - Godot is found when it is not on PATH;
  - it runs from this folder wherever it is called from.
- **Checks (Claude):**
  - Both imports exited 0 in 3–4 s with no error line. Afterwards neither copy differed from its source (`diff -rq`, ignoring `.godot/`).
  - Baselines at 60 fps through the wrapper: the game's `checks.tscn`, 141 PASS and 0 FAIL; the props scene's `check_props.gd`, 44 ok and 0 FAIL. These are the counts Assignments 2 and 3 recorded. Logs: `logs/`.
  - The game's log ends with `WARNING: 41 ObjectDB instances were leaked at exit` and `ERROR: 8 resources still in use at exit`. Assignment 2's test report already explains these as the headless audio driver, not the game. The wrapper does not fail on them.
- **My decisions:**
  - I held the step 0 commits until the brief had been reviewed.
  - I asked for `godot` to be put on my PATH. Claude wrote a two-line shim at `/opt/homebrew/bin/godot`, and `godot --version` printed `4.7.2.stable.official.ed1daf0bf`.
- **Differs from the assignment:**
  - The wrapper's arguments are `<game|godot> <test> <fps>`.
  - The layout: this folder in the course repository plays the part of the `walker-` repository's root, as in Assignment 3.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude did all of step 0 and its checks; I asked for it and chose when to commit.

## 2026-10-24 — Step 1: the change brief

*Written on 2026-10-24, from the conversation. Commit `fc9cd523`.*

- **Attempt (me):** I asked Claude to draft a complete CHANGE-BRIEF.md for me to review.
- **First draft (Claude):** everything except the colour line, the predicted values and the short answers. It left those blank because the assignment asks for them from me.
- **Second draft (Claude):** I asked it to fill them in as well, since this course expects us to use AI and I would review the result. Claude filled them in and wrote at the top of the brief that it had drafted all of it.
- **Choices Claude made, with its reasons in the brief:**
  - The hearts (`Hud/Hearts`) carry the shader from code instead of Rudy, because of the two existing checks above.
  - The state is the invulnerable window after a hit or a respawn. The hearts take the lit waystone's blue, fading as the window runs out.
  - The timing comes from the game's code. The spikes and goblins hit Rudy before his own countdown in the same physics tick. So the first frame shows 71/72 = 0.986, and the tint is visible for 71 ticks, 1.183 s.
  - With `Engine.time_scale` at 0.5, the tint lasts 2.4 s, because 64-bit rounding adds one tick (checked in Python).
  - The textured shader uses Poly Haven's Rock 01, by Rob Tuytel, CC0; Claude checked it on the Poly Haven API and licence page. It goes on the waystone's Stone and the circle's DarkStone surfaces, attached as overrides rather than through Use External.
- **A design value changed by a computation (Claude):** at `tint_strength` 0.6, the heart's outline would fall to 2.1:1 contrast against the sky beside it at full tint. At 0.4 it stays at 3.5:1, above 3:1, so the brief uses 0.4.
- **Review (me):** I reviewed the brief and found no problems.
- **One change before the commit (Claude):** the note at the top said I had checked the predicted values by hand as part of my review. Claude replaced it with what is known: I reviewed the brief on 2026-10-24, and section 3 shows the arithmetic, so each value can be checked by hand. The brief was then committed, before either shader exists.
- **Hand check of the predicted values:** none recorded. The rubric asks for predictions "computed by hand".
- **Still to do:** type the colour line into the shader myself, and record it as Claude's suggestion.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude drafted the whole brief, including the colour line, the predicted values and the short answers. I asked for it, reviewed it and approved the commit.

## 2026-10-24 — Step 2: the first CLAUDE.md run could not log in

*Written on 2026-10-24, from the conversation. Transcript: `sessions/session-1-auth-failed.jsonl`.*

- **Attempt (Claude, at my request):** the course's scoped run, `claude -p` with `sessions/prompt-1.txt`, which is the course's prompt with paths for this folder's two projects.
  - It started at 22:19:16 EDT, from Claude's own shell.
  - `CLAUDECODE` was unset for the run, because the run was started from inside another Claude Code session.
- **What happened:** it stopped after 3 s with exit code 1. Its only reply was "Failed to authenticate: OAuth session expired and could not be refreshed".
- **What the transcript's last line says:** `"subtype":"success"`, but also `"is_error":true` and `"terminal_reason":"api_error"`, with 0 tokens used. Read alone, `subtype` would have reported a success; the check has to read `is_error` and the reply as well.
- **Check (Claude):** the run created only its transcript. There is no CLAUDE.md, and `game/shaders`, `godot/shaders` and the wrapper are unchanged.
- **Next:** I log the command-line `claude` in again, and Claude repeats the run.
- **Human / AI:** Claude started the run and read its transcript; logging in is mine to do.

## 2026-10-26 — Step 2: the CLAUDE.md draft

*Written on 2026-10-26, from the conversation. Transcript: `sessions/session-1.jsonl`.*

- **Attempt:** I logged the command-line `claude` in again, and Claude repeated the same run with the same prompt and permissions.
- **The run:**
  - It started at 22:06:38 EDT and ended at 22:08:05 EDT.
  - Its result event reads `"subtype":"success"`, `"is_error":false` and `"terminal_reason":"completed"`: 25 turns in 84 s.
  - It used model `claude-opus-5-5` in Claude Code 2.1.310, and reports a `total_cost_usd` of 1.11.
- **Permission denials: 2.** Both were Bash commands outside the allowed list. One read the logs with `tail` and the two `.glb` files' JSON with Python; the other read the `.glb` files again. The scoping held: instead of the answer, the draft lists the surface indices as unconfirmed.
- **Checks (Claude, in this conversation):**
  - The run created only `CLAUDE.md` (82 lines) and its transcript.
  - `game/shaders`, `godot/shaders` and the wrapper are unchanged.
  - The first line is a heading, which is right because there is no `AGENTS.md`. Line 56 is exactly `@CHANGE-BRIEF.md`.
  - The transcript holds no e-mail or account field.
  - Claude opened every file and line the draft cites, and each one says what the draft says it does.
- **Left for the review, after the unedited draft is committed:**
  - the surface indices and mesh node names the draft could not confirm;
  - a "Headless facts" block, confirmed on this machine;
  - the brief citations the draft did not open.
- **Expected / learned:** none recorded.
- **Human / AI:** the scoped `claude -p` session wrote `CLAUDE.md`. Claude, in this conversation, ran that session and checked its output. I logged the command line in.
