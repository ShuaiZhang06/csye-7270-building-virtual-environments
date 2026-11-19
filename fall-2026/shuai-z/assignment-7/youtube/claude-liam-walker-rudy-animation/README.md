# A Run and a Slash for Walker Rudy. — Assignment 7 film

The required Brutalist Godot explainer for Assignment 7, built with the course-provided **`godot-gamedev`** skill and its **`walker`** modifier:
1. Claude prompt opening, then what was actually built.
2. The game, its two clips, their routes, which loops and which commits.
3. The sheet, its slicing and the frame track, then the run in play and its registration.
4. The four questions, each pointing at a line of the project's own files:
   - **what a clip is** (the slash's Grip track), with the slash in play and why a missing property fails silently;
   - **one authority** (the one `play_clip` call), with the run-slash-run in play;
   - **the two clocks** (the player's physics callback), with the strip;
   - **feel designed in frames** (the phase table beside its keys, the read-back's ticks), with the strip at each phase boundary and tuning round r1.
5. The state machine, with every state and a committed swing in play, then what ends a swing, with a hit in each phase in three takes.
6. What the read-backs proved, the four mutations, and what no headless run can show.
7. Verdict, Your Turn, and the regular spoken outro.

Liam, in for Bear (local Kokoro `am_onyx`). No captions.

Claude Code (Claude Opus 5.5) built the film on 2026-11-16 and 2026-11-17 from the work and records already committed, and drafted this file. On 2026-11-18 shuai-z watched the final export and uploaded it: "看过了，没问题，传到Google drive了" ("I've watched it; there is no problem, and it's uploaded to Google Drive").

**Source shown:** `fall-2026/shuai-z/assignment-7/` at `775c14c` (`775c14c3d3f60d82d12a32264ba565683c9fb0da`). The commit that adds this folder changes no game source.

**Master:** `exports/landscape/claude-liam-walker-rudy-animation.mp4` · 13:49 · 3840×2160 H.264 30 fps, AAC 48 kHz stereo · SHA-256 `3fe1870b064573fd4e8c1f2767bfe0248d886a1efdc34b296df257348397ce8e` (not in git; the repository's `.gitignore` keeps MP4 and WAV out). Gates and the frame review: [`_qc/FILM-REVIEW.md`](_qc/FILM-REVIEW.md). Course media copy, uploaded by shuai-z: [claude-liam-walker-rudy-animation.mp4 on Google Drive](https://drive.google.com/file/d/1LcCJFjidM-ZnhSihGl6oV_YvRUzpEeAC/view?usp=drive_link); it is not published on YouTube or elsewhere. On 2026-11-18 Claude fetched the link without signing in: the page names the file and asks for no access. Claude did not download it, so the SHA-256 above is the local master's; the Drive copy is identified by its file name.

## The assignment's film requirements, and where they are

| Requirement (Assignment 7, §4) | Beats |
| --- | --- |
| Identifies the game, both clips, their routes, which loops and which commits | B00, B02 (crops of the film's own engine capture) |
| The four questions, each pointing at a line of the project's clip, test or brief | what a clip is: B08 (`rudy_animations.tres` 412–419) · one authority: B11 (`rudy.gd` 241) · the two clocks: B13 (`rudy.tscn` 76) · feel in frames: B15 (`CHANGE-BRIEF.md` §2.2; `rudy_animations.tres` 416–419), B16 (`test_rudy_clips.gd` 132) |
| The sheet, its slicing and the frame track that reads it | B03 (`rudy.tscn` 31–38) → B04; B05 (`rudy_animations.tres` 47–60) → B06; B07 |
| The phase table beside the key times, and the frame strip at each phase boundary (fixture captures) | B15, B16 → B17 (both tick offsets); B14; B18 (r0 against r1) |
| The state machine playing each clip in real play, with an interrupt in each phase of the slash | B09, B12, B19 → B20 (re-presses read on swing ticks 1, 5 and 13; a jump on tick 5), B21 → B22 (a hit on swing ticks 1, 5 and 13, three takes) |
| What the read-backs proved, the four mutations (M4 passing, with its reason), what no headless run can show | B10, B23, B24, B25 |
| Agent mistakes caught, the r0 disagreement, what remains uncertain, one next step, human and AI contributions, the sheet's source and licence, the motion reference's credits, the revision shown | BVD1, BVD2, BVD3; B18 (the revision also on every code beat and in B00) |
| Walker opening and summary; Verdict → Your Turn → regular outro | B00, B01 · BVD1–BVD3, BHTF, BOUT |
| Labels: fixtures, reconstructions, scripted input, held frames; no reconstruction as a screenshot | `FIXTURE CAPTURE(S)` on every strip card; on the engine footage, the Movie Maker provenance chip, `SCRIPTED INPUT …` and `CAPTURED BY CLAUDE AT SHUAI-Z'S REQUEST` on every frame, `REPLAY …×`, `FRAME BY FRAME …×`, `ENLARGED …×` and `HELD FINAL FRAME`; "Godot editor reconstruction" on every code beat; `HEADLESS TEST OUTPUT` on the logs |

## The evidence chain

| File | What it is |
| --- | --- |
| [`capture/`](capture) | the film-only driver, the harness diff, the take script and its two checks, and the three run logs (the MP4s and WAVs are not in git) |
| [`CAPTURE.md`](CAPTURE.md) | how the takes were recorded, the void first attempt, the frame/log/pixel checks, and the hashes |
| [`checks/game/`](checks/game) | `gamedev-evidence.json`: 27 files in 4 components, 132 excluded with a reason, 8 excerpts, 8 code → result pairs with hashed media |
| [`COMPONENTS.md`](COMPONENTS.md) · [`SHOTLIST.md`](SHOTLIST.md) · [`RIFF.md`](RIFF.md) | readable views of the same, generated from the sheet and the ledger |
| [`FACTCHECK.md`](FACTCHECK.md) · [`SOURCES.md`](SOURCES.md) · [`PROMPTS.md`](PROMPTS.md) | every spoken or shown number with its source; provenance, art and credits, corrections; every prompt shown |
| [`beat_sheet.json`](beat_sheet.json) · [`tools/`](tools) | the beat sheet, and the scripts that build the sheet, the stills, the media and mix, the ledger and the docs |
| [`stills/`](stills) | every evidence card and figure the film shows |
| [`BUILD-PROMPT.md`](BUILD-PROMPT.md) | the paste-ready rebuild |
| [`_qc/FILM-REVIEW.md`](_qc/FILM-REVIEW.md) | the gates and Claude's review of the master |

```bash
tools/check.sh
```

## Honesty boundary

- Godot editor views are **reconstructions** with verbatim source and line numbers, labelled as such. No live editing session was recorded.
- The gameplay is the real main scene rendered by Movie Maker, with **scripted input** from a film-only driver on an isolated copy, labelled on every frame. Claude ran the takes at shuai-z's request, though the assignment says the student runs every capture, and every frame says so. Replays and frame-by-frame passes are labelled with their speed; enlarged replays say so; held frames are labelled. The frames are 3840 × 2160 but scaled by Movie Maker from a window clamped to the screen, not pixel-native (CAPTURE.md).
- The frame strips are **fixture captures** of the preview scenes, run by Claude at shuai-z's request, labelled on every card. Claude's readings and predictions on them are quoted from `TUNING.md` and called claims; the verdicts are shuai-z's.
- Headless results are shown as recorded logs, labelled, and the film says what they cannot show.
- The human checks in the verdict are shuai-z's, reported from `TUNING.md` and `TEST-REPORT.md`; nobody else has played the game.
- Two things the assignment asks for are not done, and the film says so (BVD2, B18): no tuning revision was driven by shuai-z's own observation in play, and the captures were run by Claude.
