# SOURCES — claude-liam-walker-rudy-animation

Claude Code (Claude Opus 5.5) built this film and drafted this file, on 2026-11-16 and 2026-11-17, at the request of the Assignment 7 session working for shuai-z, which asked for the film the assignment's "4. Ship It" section requires. shuai-z chose to have Claude run the film's captures ("你来跑", "you run it", 2026-11-17; CAPTURE.md).

## What the film shows

| Evidence | Source | Identity |
| --- | --- | --- |
| Godot source, every code excerpt | `assignment-7/game/` at `775c14c3d3f60d82d12a32264ba565683c9fb0da` | per-file SHA-256 in `checks/game/gamedev-evidence.json` |
| The game in play | `capture/play-01.mp4` to `play-03.mp4`, Godot Movie Maker takes of the real main scene on an isolated copy with a film-only input driver (`capture/film_driver.gd`) | CAPTURE.md §1, with hashes |
| The frame strips | `captures/slash/r0/`, `r1/`, `r1-second-tick/` and `captures/run/r0/`, `r0-sword/` in the assignment folder: Movie Maker runs of the preview scenes, committed with the tuning rounds (`c70c8367`, `66103310`) | CAPTURE.md §2; `TUNING.md` |
| The sheet and its cells | `game/content/rudy/sheet/rudy_sheet.png` (SHA-256 `4eba0d1e…`, checked by `tools/make_stills.py`) and `rudy_look.gd` 46–51 | `game/content/rudy/sheet/ATTRIBUTION.md` |
| Headless results and mutations | the committed logs in `logs/` | `TEST-REPORT.md` |
| The phase table, the predictions, the readings and verdicts | `CHANGE-BRIEF.md` (Revisions 1–6), `TUNING.md`, `TEST-REPORT.md`, `FRICTIONAL.md` | read and quoted by `tools/make_stills.py`, which asserts each quoted phrase is in its file |
| Who did what, the mistakes caught, what is uncertain | `FRICTIONAL.md`, `TUNING.md`, `TEST-REPORT.md`, `SOURCES.md`, `CLAUDE.md` in the assignment folder | FACTCHECK.md |

Every still is composed by `tools/make_stills.py` from these files; it only crops, scales, places and labels. Strip crops are enlarged with nearest-neighbour. The enlarged replays in the gameplay beats are 16:9 regions of the same Movie Maker frames scaled with Lanczos, labelled `ENLARGED` on screen.

## The art and the motion reference

- **Rudy's frames, the sheet and the rig parts** are shuai-z's own Assignment 2 art, generated with the Gemini app's image generation under Google's Terms of Service and Generative AI Additional Terms (`../../../assignment-2/SOURCES.md`). The sheet is packed and the rig cut from those frames by code, with no new image generated (`game/content/rudy/sheet/ATTRIBUTION.md`, `game/content/rudy/rig/ATTRIBUTION.md`). The film names no other work.
- **The motion reference** (`evidence/motion-reference/README.md`): "IMG 8252" Hand-and-a-half sword (Bastard sword) exercises, by Kuroczynski, CC BY-SA 4.0; and S1 and S3 Videos of Arellano, McDermott, Kram and Grabowski (2015), PLOS ONE, DOI 10.1371/journal.pone.0115637, CC BY 4.0. The film credits them in BVD3 and shows no frame of them.

## Corrections made while building (DOUBLE-CHECK LAW)

- **The first capture attempt was void.** Its take 1 log matched the dry run, but 357 of 748 frames repeated the previous image: on macOS Godot stops drawing a covered window, and Movie Maker writes the last image again. It was discarded; the takes used were recorded always on top, in MJPEG, with a packet check that no frame repeats (CAPTURE.md §1).
- **The driver's window guard never ran**: it looked for `--write-movie` in `OS.get_cmdline_args()`, which Godot leaves out. The takes rest on the packet check; CAPTURE.md gives the fix for a re-record.
- **"Native 4K" was wrong.** The window is clamped to the screen and Movie Maker scales the frames to 3840 × 2160; the chip now says `4K ENGINE CAPTURE`.
- **The first film driver's presses landed a tick late** (re-presses on swing ticks 4 and 12, and the hit before the slash): a probe showed a press is read on the next physics tick, and the driver now schedules presses after Rudy's tick. The hits land on swing ticks 1, 5 and 13.
- **The game card said cell 2 on a frame that shows cell 1** (frame 118). It now uses frame 120, and the script asserts the cell from the run log.
- **Gameplay holds.** The first build held the last frame for up to 21 s, because the narration outlasted the footage. Labelled slower replays and frame-by-frame passes of the same frames were added instead of retiming anything; the holds are now 1.7–4.7 s, labelled.
- **Narration, checked against the records:** B10 now says the wrapper fails on the missing-node warning; BVD2 states Claude's reading of the hitbox opening while the blade is still above his head as Claude's; BVD1 names Claude's reading of a rule from another file (measured frame counts) as this assignment's own, as `FRICTIONAL.md` records it.
- **Stills:** a garbled cell label, a walk line too thin to see, a warning running past the card's edge, overlapping labels on the boundary strip, an unwrapped Chinese quotation on the tuning card (now wrapped with a CJK font), a clipped "STARTUP · dead" and wrong line references on the phase-table figure (the key times are at `rudy_animations.tres` 416, 428, 440, 452).
- **Code-panel notes** clipped in the first pilot render; every note was shortened.
- **After the first master** (`_qc/FILM-REVIEW.md`):
  - Gate V refused the first compile, because BVD2's card filled 52% of the safe area. The card gained the item its narration already says (one machine, no other player), and the scaled-4K fact.
  - Claude's frame review found five code panels cutting off cued lines: the workbench does not scroll. Each excerpt now shows a range that holds every cued line, at the smallest code size. B19 and B21 name, in a note and in the narration, the lines just above what is shown. The beats were rendered again.

## Tools used to make the film

| Tool | Version | Use |
| --- | --- | --- |
| Brutalist toolkit (`brutalist.art`), skill `godot-gamedev` + `walker` | checkout `a99b5323`; Remotion 4.0.535 as installed (the toolkit reported 4.0.544 as latest; it was not upgraded) | beat-sheet contract, Remotion scenes, Kokoro wrapper, compiler, gates, `./art godot-gamedev --check` |
| Kokoro-82M via kokoro-onnx, voice `am_onyx` ("Liam, in for Bear") | the toolkit's local model | all narration, free and local |
| Godot | 4.7.2.stable.official.ed1daf0bf | the Movie Maker takes on an isolated copy |
| FFmpeg, Python 3 with Pillow and NumPy | FFmpeg 9.0.2, Python 3.13.5, Pillow 10.4.0, NumPy 2.1.3 | encoding, the stills, the per-beat mix |
| Fonts | the toolkit's Inter and PT Mono; macOS Hiragino Sans GB for Chinese quotations | the stills |

The adapted tools in `tools/` started as copies of the Assignment 6 film's (`assignment-6/youtube/claude-liam-walker-rudy-particles/tools/`). No paid service, image generator or stock media was used. Nothing was uploaded or published by Claude.
