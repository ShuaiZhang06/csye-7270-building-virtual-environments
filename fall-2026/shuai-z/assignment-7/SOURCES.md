# SOURCES — Assignment 7, walker-rudy's animation

Credits, tools, versions, and who did what. The dated record is [FRICTIONAL.md](FRICTIONAL.md).

**How this file was made.** Claude Code (Claude Opus 5.5) drafted it on 2026-11-16 at my request, from the commits, [TUNING.md](TUNING.md), [TEST-REPORT.md](TEST-REPORT.md), the sessions' answers and our conversation. I review it before it is committed.

## Starting point

- **My Assignment 2 game**, `game/`. It is `../assignment-6/game/` as committed at tag `a6`, copied unchanged with `git archive` (commit `476621f6`, 168 files). I have not changed games since Assignment 2.
- **Credits for what it already had:**
  - its art, sound and music, with their models and terms: [../assignment-2/SOURCES.md](../assignment-2/SOURCES.md) and [../assignment-2/ASSET-LOG.md](../assignment-2/ASSET-LOG.md);
  - Assignment 5's tint shader, which this assignment leaves alone: [../assignment-5/SOURCES.md](../assignment-5/SOURCES.md);
  - Assignment 6's particle effects, also left alone: [../assignment-6/SOURCES.md](../assignment-6/SOURCES.md).
- **The test wrapper,** `scripts/run-test.sh`. It is the course's wrapper as Assignment 6 adapted it, with resource-load failures added (commit `db2f8989`). Its header lists every change.
- **The assignment text.** I pasted it from Canvas on 2026-11-13, and it is the base of the brief from Revision 5 on.
  - The read-back's `track_problems()` follows the function the text gives (`game/tests/test_rudy_clips.gd`).
  - Two prompts are the text's own: Step 1's `CLAUDE.md` prompt (`sessions/prompt-11.txt`, with this folder's paths) and Step 7's tuning prompt (`sessions/prompt-18.txt`, with my words filled in).
- **The course chapters,** read for the brief, not copied: Chapter 10 and Chapter 11 of the course repository (`upstream/main`), including Chapter 11's account of walker-jumpman-clawd's `visual_animation()` priority list, which `rudy.gd`'s selector resembles. No code or art from walker-jumpman-clawd is used.

## The sprite sheet and the rig's parts

Both are made by code from my own Assignment 2 generated frames. No found sheet and no course sprite set is used. The credits files beside them give the source, the model and its terms, where the prompts are logged, and the date checked:
- [game/content/rudy/sheet/ATTRIBUTION.md](game/content/rudy/sheet/ATTRIBUTION.md): the 4 × 4 sheet, from `tools/pack_rudy_sheet.py`;
- [game/content/rudy/rig/ATTRIBUTION.md](game/content/rudy/rig/ATTRIBUTION.md): the slash rig's body, blade and arc, from `tools/cut_slash_rig.py`.

## The motion reference

Openly licensed videos, whose frame counts are compared with the phase table and the run's cell rate (`CHANGE-BRIEF.md`, section 8). They are not committed: only the measurements are, in [evidence/motion-reference/README.md](evidence/motion-reference/README.md), with each file's SHA-256. CC BY and CC BY-SA ask for credit, so they are credited here and in the film.

| Used for | Work | Author | Licence |
|---|---|---|---|
| The swing | "IMG 8252" Hand-and-a-half sword (Bastard sword) exercises, on Wikimedia Commons | Kuroczynski (Wikimedia Commons user), 2023-09-02 | CC BY-SA 4.0 |
| The run, 3.0 and 9.0 m/s | S1 and S3 Videos of "Effect of Running Speed and Leg Prostheses on Mediolateral Foot Placement and Its Variability", PLOS ONE, DOI 10.1371/journal.pone.0115637, on Wikimedia Commons | Arellano C, McDermott W, Kram R, Grabowski A (2015) | CC BY 4.0 |

## Generative models

| Model | Where it ran | Terms | What it made |
|---|---|---|---|
| Gemini app image generation ("Nano Banana"; chat model Gemini 3.8 Flash) | Gemini app, in Assignment 2 | Google Terms of Service and Generative AI Additional Terms; see [../assignment-2/SOURCES.md](../assignment-2/SOURCES.md) | Rudy's frames, from which the sheet and the rig's parts are made. Nothing new was generated in this assignment |
| Claude Opus 5.5 (`claude-opus-5-5`) | Claude Code 2.1.319, in the desktop app, and its `claude -p` sessions | Anthropic's terms for Claude Code on my account | The code, tests, clips, prompts, documents and strip readings listed under "What AI contributed" |

The film's narration and its tools will be credited with the film.

## Tools

| Tool | Version | Used for |
|---|---|---|
| Godot | 4.7.2.stable.official.ed1daf0bf, GL Compatibility | The game, the tests, the previews, and the Movie Maker captures |
| Python | 3, with Pillow, NumPy, SciPy and scikit-image | `tools/pack_rudy_sheet.py`, `tools/cut_slash_rig.py`, the motion reference's counting scripts |
| FFmpeg and ffprobe | as installed on my Mac | Extracting and counting the motion reference's frames |
| Git | as installed | The worktrees for the mutations, and the record |

## What AI contributed

Claude Code, either in our conversation or in a `claude -p` session it prepared and I approved, made:
- **The brief.** It drafted `CHANGE-BRIEF.md` and all of its revisions, including the phase table, the cycle spec, the predictions and the short answers. I chose to keep it that way when the text asked me to write them ("照旧你起草我审", "as before: you draft, I review").
- **The clips.** Sessions keyed every clip as resource text from the brief: the run cycles, the one-key state clips and the rig's slash (sessions 4, 7 and 8). Session 12 moved the library and set each clip's `step`. Tuning round r1 changed one key's transition (session 18b).
- **The slicing.** Session 3 wrote `tools/pack_rudy_sheet.py`, which packs the frames into the sheet. Session 6 wrote `tools/cut_slash_rig.py`, which cuts the rig's parts.
- **The tests:**
  - the pin (sessions 2 and 15), and its re-pin (session 16);
  - the read-back (sessions 4, 5, 7, 8 and 12);
  - the state test (sessions 9 and 14);
  - the edge test (sessions 10 and 13);
  - the previews (session 17).
- **The probes and the mutations.** Claude ran these itself, in the conversation: the probes behind the brief, the wrapper and `CLAUDE.md` (`evidence/`), and the four mutations in their worktrees (`evidence/mutations/`).
- **The state machine.** Sessions 5 and 8 wired `rudy.gd`'s selector to the `AnimationPlayer`, through `RudyLook`.
- **`CLAUDE.md`.** Session 11 drafted it unedited, and Claude reviewed it in the conversation.
- **The strip readings.** Session 18 read r0 and proposed the r1 change. Its resume (18c) compared r1 with the prediction. They are claims, kept apart from my verdicts in `TUNING.md`.
- **The captures.** Claude ran the r0 and r1 captures at my request. The text says I run every capture.
- **The documents.** Claude drafted `TUNING.md` and `TEST-REPORT.md` around my words, and this file, `FRICTIONAL.md`, `README.md` and the credits files. It wrote `tools/redact_transcripts.py`, which makes the committed copies of the transcripts.
- **Checking each session.** After each one, Claude checked the writes against a hash snapshot and reran its tests. It also fixed small errors found in review: line references, a header's derived frames, and the header labels after Revision 6.

## What I did

- **I specified:**
  - the base text, the course's repository file first and then, from 2026-11-13, the full Canvas text ("本次作业都以下面最新的作业要求为准");
  - from the options Claude put to me, the two clips and their routes: the run as a sprite clip from my own Assignment 2 frames, and the sword slash on a cutout rig;
  - that the slash keeps its gameplay timing;
  - openly licensed footage, rather than filming myself, for the motion reference, and its download ("可以下载");
  - that `CLAUDE.md` start empty, as in Assignment 6 ("照 A6 留空").
- **I measured:** nothing myself. Claude counted the motion reference's frames, and I checked the counts against the contact sheets ("核对好了").
- **I judged:**
  - the slash in the running game after it was wired ("看过了 没问题");
  - the run, before the re-pin ("我看过了 没问题");
  - my first verdict on the previews, before Claude read any frame;
  - r1 in the running game at `--time-scale 0.25`, and I kept it;
  - the four human checks and the editor run (`TEST-REPORT.md`).
- **I approved:**
  - every brief revision before it was committed;
  - every session's prompt before it ran;
  - the order of the work from Revision 5 on, which Claude proposed ("好，按这个顺序");
  - the r1 change ("批准，续跑去改");
  - every commit, on my word.
- **I changed:** no file by hand. I decided that Claude run the captures instead of me, against the text, and that Claude correct the run preview's header and the preview labels.
- **I rejected:** none recorded.
- **Where Claude and I disagreed:** on r0, Claude read a near-stop in the sweep where I had seen none (`TUNING.md`, r0).

## People

- **Shuai Zhang (me):** as above.
- **No other collaborators.** No one else has played the game or looked at the work.
