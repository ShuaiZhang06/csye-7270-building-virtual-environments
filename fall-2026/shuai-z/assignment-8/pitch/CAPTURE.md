# CAPTURE — how the film's play was recorded

**Film:** `walker-rudy-final-pitch` (this folder) · **Recorded:** 2026-11-23 (EST) · **Game:** Level 1 of Walker Rudy at tag `a7`.

Claude Code (Claude Opus 5.5) wrote the film driver, the scripts and this file, and ran the takes, at my request ("可以，开始录", "yes, start recording", 2026-11-23). I watched the clips in the finished film on 2026-11-24 and found no problem.

Assignment 8 asks that "Gameplay footage you show is real captured play from your game, and you say which revision it came from. Scripted-input captures and slowed replays are labelled as such." So every clip below comes from the game as it is at `a7`. Each is labelled on screen `Level 1 · tag a7 · scripted input`, and the one sped-up clip also says `2× speed`.

## The source

| | |
| --- | --- |
| Revision | tag `a7`, `76206412267f07569b1488c9a9f4db03efa352a2`. `git diff a7 -- fall-2026/shuai-z/assignment-7/game` was empty on this branch |
| The copy | `git archive a7 fall-2026/shuai-z/assignment-7/game`, unpacked in a scratch folder outside the repository and imported there with its own `HOME` |
| Godot | 4.7.2.stable.official.ed1daf0bf, GL Compatibility (OpenGL 4.1 Metal), Apple M3, macOS |

Three changes were made to the copy, none to the project (`capture/game-project.godot.diff`):
1. the window override 1280 × 720 → 3840 × 2160, so Movie Maker writes 3840 × 2160 frames (the viewport stays 1920 × 1080 with `canvas_items` stretch);
2. Movie Maker's MJPEG quality set to 1.0;
3. an autoload, `FilmDriver` (`capture/film_driver.gd`, adapted from Assignment 7's).

**What the driver does.** The real main scene boots as F5 runs it. The driver presses the game's own input actions (Enter, move, jump, slash, Esc) with `Input.action_press()`, as the game's `checks.gd` does, and reads state. It never calls a game method, places nothing and sets nothing.

**What it logs.** Each drawn frame gets one `frame N` line: Rudy's place, mode, gear and hearts, the level's state, the pause, the title and end card, each goblin, and the waystone. Each physics tick gets an `event` line when something the film names happens.

**How it times things.** Its jumps, the stomp and the slashes are timed from positions it reads.
- The stomp's lead was measured in headless dry runs: at 336 px and below, Rudy cleared goblin A without touching it; from 350 to 400 px he stomped it. The driver uses 375.
- Claude's first estimate (336) was on the wrong side of that range; see `FRICTIONAL.md`.

## The takes

`capture/takes.sh` runs each take twice, each run a fresh boot at `--fixed-fps 30`.
1. **The dry run.** Headless, with nothing drawn: `capture/logs/take-<take>-dry.log`.
2. **The take.** In a window kept on top of all others, with `--write-movie`: `capture/logs/take-<take>-window.log`. macOS does not draw a covered window, and Movie Maker then repeats the last image, which is why the window stays on top.

The take is encoded to `capture/take-<take>.mp4` (video only) only if `capture/check_take.py` passes.

| Take | Frames | What happens, by frame |
| --- | --- | --- |
| `run` | 541 (18.0 s) | title; Enter 45; title gone 56; goblin A stomped 142; sword picked up 175; goblin B slashed 216; waystone lit 256; goblin C slashed 360; teleport circle 425; end card 495 |
| `mech` | 516 (17.2 s) | the same to the waystone (256); goblin C's touch knocks the sword away 363; its next touch costs a heart (3 → 2) 399; a run off the second cliff costs a heart (2 → 1) 451; Rudy gets up at the waystone 469, in control again 489 |
| `pause` | 358 (11.9 s) | Enter 45; Esc, "Paused" 86; Esc, resumed 122; goblin A's touches cost a heart each, 192 and 228; the third takes the last heart 276; the level starts over at the start with full hearts 311, in control again 331 |

**Level 1 at full speed.** In the `run` take, which never stops, Rudy went from Enter (frame 45) to the teleport circle (frame 425) in 759 physics ticks, **12.65 s** (the `run` take's `event` lines: play from tick 90, the circle on tick 849). Both my design document and the brief said "about 30 s at full speed". They now say about 13 s, and the GDD's change table says why.

**How each take was checked** (`capture/logs/check_take.txt`). All three passed every check.

| Check | Result |
| --- | --- |
| The AVI has one video packet per `frame` line | 541, 516 and 358 |
| The driver's window guard (`OS.has_feature("movie")`) | printed only `draw 0 true`: the window could draw from the first frame to the last |
| No MJPEG packet repeats the one before, except where the log says nothing changed | repeats only at `run` frames 506–540 (the end card, fully shown and still) and `pause` frames 87–121 (paused, all still); none in `mech` |
| Every `frame`, `event` and `step` line equals the dry run's | 541, 24 and 20 for `run`; 516, 39 and 20 for `mech`; 358, 28 and 10 for `pause` |

**What Claude looked at.** Claude looked at frames against their log lines, at 960 × 540:
- **`run`:** the title (0); the hearts, title gone (56); Rudy above goblin A (141), then the goblin squashed (142); running with the sword and shield (175); the slash on goblin B (216); the waystone's light (256); Rudy on the circle (425); "Level complete" (500).
- **`mech`:** the slash (215); the waystone (256); the touch (362); Rudy hurt and see-through, with the sword gone (363); the third heart empty (399); Rudy gone below the cliff, one heart left (451); the fade, with him getting up at the waystone (469); standing at the lit waystone (489).
- **`pause`:** "Paused · Press Esc to resume" (100); two hearts (192); one (228); none, Rudy down (276); the fade at the start (311); back at the start with three hearts (331).

That is Claude's reading, not my verdict.

**Recording time.** Movie Maker rendered offline at a fixed step, so these takes say nothing about real-time frame rate. Each was recorded at about 53% of real-time speed (the logs' last lines).

**What "3840 × 2160" means here.** Assignment 7's capture found that macOS clamps the window to the screen and Movie Maker scales each frame to the override, so the frames are not pixel-native 4K. It was not re-measured for these takes, and no label in this film says "native".

**Sound.** Movie Maker also recorded the game's own audio into the AVIs. It is not used: every MP4 and clip is video only, so none of the ElevenLabs sound effects is in the film.

## The clips

`tools/cut_clips.py` cuts each VIDEO beat's clip from its take, fitted to the beat's measured narration. Each beat names a window in its take and which end of it to keep (`anchor`); the script moves the other end until the clip covers the whole narration, and logs the frames it used (`capture/logs/cut_clips.txt`). Re-cut on 2026-11-23 after the voice was recorded:

| Clip | Beat | Take | Frames | Kept end | Speed | Clip | Narration |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `clips/C1.mp4` | B01, what the game is | `run` | 0–303 | start (the title) | 1× | 304 frames, 10.13 s | 10.11 s |
| `clips/C2.mp4` | B02, the goal | `run` | 262–540 | end (the end card) | 1× | 279 frames, 9.30 s | 9.30 s |
| `clips/C3.mp4` | B07, core mechanics | `mech` | 188–515 | end (up at the waystone) | 1× | 328 frames, 10.93 s | 10.92 s |
| `clips/C4.mp4` | B11, Level 1 | `run` | 27–540 | end (the end card) | 2×: every second frame, at 30 fps | 257 frames, 8.57 s | 8.55 s |
| `clips/C5.mp4` | B28, what exists | `pause` | 59–357 | end (control again) | 1× | 299 frames, 9.97 s | 9.96 s |

The first cut (before the voice) was checked frame against frame: eleven clip frames, each clip's first and last and one in the middle of C4, matched the take frames they should be (mean difference 0.00–0.19 on a 0–255 scale, where a neighbouring frame differs by 5–17 if the picture moves). The re-cut uses the same script and filter with new frame numbers.

## Files

- **Committed:**
  - `capture/film_driver.gd`, `capture/game-project.godot.diff`, `capture/takes.sh`, `capture/check_take.py`;
  - `capture/logs/` (the window logs name the scratch folder as `$CAP`, replaced so that no local path is committed);
  - `tools/cut_clips.py`.
- **Not committed:**
  - the takes' MP4s and the clips (the repository ignores `*.mp4`);
  - the AVIs and the game copy, which stay in the scratch folder.

  The film made from them is on Google Drive, with its link and SHA-256 in `README.md`.
