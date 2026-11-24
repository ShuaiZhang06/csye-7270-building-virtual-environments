# Walker Rudy: The Long Way Home. A Final Project Pitch

Assignment 8, CSYE 7270, Fall 2026.

| | |
| --- | --- |
| **Name** | Shuai Zhang (`shuai-z`) |
| **Working title** | *Walker Rudy: The Long Way Home* |
| **Target role** | gameplay programmer |
| **Reader** | my instructor and the TAs |
| **Runtime** | the film runs 5:19 (318.87 s). The game runs in Godot 4.7.2 on the GL Compatibility renderer; the final project targets a Web export (WebGL 2), with a macOS build as the fallback |
| **Film** | [walker-rudy-final-pitch.mp4 on Google Drive](https://drive.google.com/file/d/1ZATR-kOvprs9Zttz_HHB3hBglIPDERTC/view?usp=drive_link) |
| **Filename** | `walker-rudy-final-pitch.mp4` |
| **SHA-256** | `48a964f4a59f2b9bf3ab03b10ff15a79ab4ec39a9cadb4969c215554101af1dd` |
| **Format** | 3840 × 2160, H.264 High, 30 fps; AAC 48 kHz stereo; 172,758,098 bytes; −24.1 LUFS integrated |
| **Narration** | a synthetic voice (Kokoro `am_onyx`, run locally) speaking as me, from a script Claude Code drafted with me. No instructor name, persona or credit line |

*Claude Code (Claude Opus 5.5) drafted this file on 2026-11-24, at my request; I review it.*

On 2026-11-24 I watched the whole film and found no problem ("看完了，没问题", "I've watched it; no problem"). I uploaded it to Google Drive myself. It is not posted anywhere else.

The same day, Claude opened the Drive link without signing in. The page names the file and asks for no access. Claude did not download it, so the checksum above is that of the local master I uploaded; the Drive copy is identified by its file name. The toolkit's own receipt (`exports/landscape/walker-rudy-final-pitch.verified.json`, not in git) records the same SHA-256, and Claude recomputed it from the file on 2026-11-24.

## What the film pitches

My final project: **all six levels of my game design document**, from a title menu to an end screen after the boss, exported to Web. I am proposing the whole design on purpose, so that the reviewer can judge its size. The cut order says what goes first if it is too much, and Levels 1–3 are the floor.

Only Level 1 exists today, at tag `a7`. Every shot of play in the film is real captured play of that level. Everything else is shown as a figure from the GDD or a drawing made for the film, and is labelled.

## Where each part of the assignment is in the film

| Part (Assignment 8) | Beats | Starts at |
| --- | --- | --- |
| Opening: what the film is, the GDD it follows, three terms (built, designed, greybox) | BIDEA, B00, BDEFS | 0:00 |
| The game in brief, with one picture (Level 1 in play) | B01, B02 | 0:28 |
| Question 1: what exists when it is done | B03 | 0:48 |
| The GDD, section by section (all sixteen) | B04–B22. Section 7 takes four beats (B10 the world map, B11 Level 1 in play, B12 Levels 2–5, B13 Level 6); art is B16, sound B17 | 0:56 |
| Question 2: why anyone would care, with real comparable games | B23 | 3:47 |
| Question 3: who opens it, the target role, the first sixty seconds | B24 | 3:59 |
| Question 4: what it proves | B25 | 4:09 |
| Question 5: in, out and first | B18 (in), B19 (out), B26 (first, and how anyone would know it ran) | 3:00, 3:11, 4:21 |
| Question 6: what could sink it | B21 | 3:27 |
| Question 7: why this project | B27 | 4:30 |
| Appendix: exists, started, not started; can one person build it; every asset's source and licence | B28, B29, B30 | 4:41 |
| Outro: the title and my name | BOUT | 5:13 |

The questions do not run in their own order. Questions 5 and 6 are answered inside the GDD's feature-list, out-of-scope and risk sections, so each is said once.

## What the labels on screen mean

- **Play.** Every clip says `Level 1 · tag a7 · scripted input`. B11 also says `2× speed`, because it plays every second frame. The input was pressed by a film-only driver, not by a person; `CAPTURE.md` says how.
- **Figures.** Each figure from the GDD says what it is: built, designed, generated, or constructed (drawn by code).
- **Drawings.** The other beats are simple drawings made for this film in `scenes.py`. They show ideas that have no game picture yet.
- **Nothing is shown as done that is not.** Only Level 1 at `a7` and the Assignment 5–7 work at `a5`, `a6` and `a7` are called built. Everything else is called designed or planned, and the narration says "will" for it. [`FACTCHECK.md`](FACTCHECK.md) checks every claim against its source.

## The toolkit's quality gates

The film was built with the course's Brutalist toolkit (`brutalist.art` at `3a6d3979`), show-tell format, at 3840 × 2160. All of the toolkit's gates passed on the master:

| Gate | What it checks | Report |
| --- | --- | --- |
| F | FACTCHECK, SHOTLIST and PROMPTS exist before rendering; the toolkit's fact-check script is clean | [`FACTCHECK.md`](FACTCHECK.md), [`SHOTLIST.md`](SHOTLIST.md), [`PROMPTS.md`](PROMPTS.md) |
| L, SHAPE, A, W | beat-mix lint, chart shapes, static pre-flight, WCAG contrast and margins on the scenes | [`layout_audit.md`](layout_audit.md) (see the note below) |
| B | the layout audit of the rendered drawings | as above |
| V | every beat's frames in the compiled film: safe area, edge bleed, underfill, contrast | [`_qc/REPORT.md`](_qc/REPORT.md), [`_qc/contact_sheet.png`](_qc/contact_sheet.png): 68 frames, no BLOCKER or MAJOR |
| T | type size, overflow, contrast and overlap on each beat's middle frame | [`TYPECHECK.md`](TYPECHECK.md): PASS, no FAIL |

[`STATUS.md`](STATUS.md) shows that all 34 picture slots are filled, and how.

Read these results with their limits:

- **Declarations.** Some beats declare what the gates should measure, each with a written reason in `beat_sheet.json` (`qc`). The declarations are claims a reviewer can check.
  - **Play clips:** `full_bleed` (they fill the frame), and `contrast_regions` on the label chip, since the game's own art has mixed colours.
  - **Figures:** `contrast_regions` on their status lines, and `typography_regions` around the film's own type. The small text inside the GDD images (palette codes, frame names, the game's on-screen text) is content, not this film's type.
  - **Some drawings:** `sparse_by_design`, where a beat is meant to be mostly empty.
- **Gate T skipped the five play-clip beats** (B01, B02, B07, B11, B28: "no video"). Their only type is the label chip: EB Garamond at 96 px on the 2160-line frame, over twice Gate T's 41 px floor. Gate V checked the chip's contrast.
- **The layout audit report** comes from the last render round. It covers only the scenes re-rendered in that round. The earlier rounds' reports, which covered the other scenes, were overwritten by the toolkit.
- **Expected warnings.** The cold open is the hesitant writer instead of the toolkit's house opener. The outro is a Manim scene instead of `ClaudeTitleOutro`, which prints the instructor's handle and cannot be changed. So the compiler prints two skin warnings, and the toolkit's separate `bookend_check.py` fails the outro. Assignment 8 forbids the instructor's credit line, so these are left as they are. `FRICTIONAL.md` ("The pictures") has the details.
- **Frame rates.** The toolkit renders Manim at 24 fps, so in the 30 fps master the drawings repeat one frame in four. The play clips keep every frame.
- **The voice** was not checked against a speech-to-text transcript. I chose to skip that step; the pronunciation was checked phoneme by phoneme, and I listened to the finished film.

## Files

| File | What it is |
| --- | --- |
| [`GDD.md`](GDD.md), [`figures/`](figures) | the game design document the film is built from (v2, 2026-11-23), in the GDD tool's sixteen sections plus art and sound |
| [`PROJECT-BRIEF.md`](PROJECT-BRIEF.md) | the game in brief, the seven answers, the appendix with its asset table, **Exists today** and **Will exist** |
| [`beat_sheet.json`](beat_sheet.json) | the narration and the visual plan, 34 beats. It carries the final build's stamps |
| [`BUILD-PROMPT.md`](BUILD-PROMPT.md) | the prompt and the commands that rebuild the film |
| [`SOURCES.md`](SOURCES.md) | what I used, what I made, what Claude contributed, and every asset's licence |
| [`FRICTIONAL.md`](FRICTIONAL.md) | dated entries as I worked |
| [`CAPTURE.md`](CAPTURE.md), [`capture/`](capture) | how Level 1 was recorded: the film driver, the take script, its checks and the logs |
| [`scenes.py`](scenes.py), [`stills/`](stills) | the Manim scenes (the drawings, the figure frames, the terms card, the outro), and three stills they use |
| [`tools/`](tools) | the scripts that write the beat sheet and the docs, cut and label the clips, and finish the audio |
| the gate reports | listed in the table above |

The film itself, the takes, the clips, the audio and the toolkit's intermediate renders are not in git. The repository ignores every `.mp4`, and this folder's `.gitignore` lists the rest. No conversation transcript is included.

## How to rebuild the film

[`BUILD-PROMPT.md`](BUILD-PROMPT.md) has the paste-ready prompt and every command. In short:
1. record the three takes of Level 1 from tag `a7`;
2. write the sheet, voice it locally with Kokoro, and write the sheet again with the measured lengths;
3. cut and label the clips, and write the docs;
4. run `./art run` and `./art final` from the toolkit.

It needs no paid service, no API key and no upload.

## Submission

- **GitHub:** this folder, `fall-2026/shuai-z/assignment-8/pitch/`, at tag `a8`.
- **Canvas:** `Zhang_Shuai_CSYE7270_FinalProjectPitch.zip`, with the folder link, the tag and the final commit hash.
