# CAPTURE — how the film's evidence was recorded

**Film:** `claude-liam-walker-rudy-animation` · **Project:** walker-rudy, Assignment 7 (`fall-2026/shuai-z/assignment-7/`) · **Recorded:** 2026-11-17 (EST) · **Skill:** `godot-gamedev`, `walker` modifier.

Claude Code (Claude Opus 5.5) drafted this file and made the three takes in it, at shuai-z's request. The assignment says the student runs every capture. On 2026-11-17 shuai-z was asked again before any new capture and chose "你来跑" ("you run it"); after the first attempt failed (below), shuai-z said "现在开始" ("start now"), and the takes used here were recorded then. Every frame strip in the film was also run by Claude at shuai-z's request (`TUNING.md`; `CHANGE-BRIEF.md`, Revision 6).

## The source being demonstrated

| | |
| --- | --- |
| Source revision | `775c14c3d3f60d82d12a32264ba565683c9fb0da`, the tip of `shuai-z/assignment-7`. `git diff 775c14c3 -- fall-2026/shuai-z/assignment-7/game` was empty, and the only untracked path was `youtube/`, this reel |
| Godot | 4.7.2.stable.official.ed1daf0bf, GL Compatibility (OpenGL 4.1 Metal), Apple M3, macOS 15.1 |

## 1 · The game in play: `capture/play-01.mp4` to `play-03.mp4` (B02, B06, B09, B12, B20, B22)

`game/` was copied with `rsync --exclude .godot` to a scratch directory outside the repository and imported there with a separate `HOME`. Three harness-only changes were made to the copy (`capture/game-project.godot.diff`):

1. `window_width_override` / `window_height_override` 1280 × 720 → 3840 × 2160, so Movie Maker writes 3840 × 2160 frames. The viewport is still 1920 × 1080 with `canvas_items` stretch, as in the project.
2. `editor/movie_writer/mjpeg_quality` 1.0, Movie Maker's AVI writer at its highest quality.
3. An autoload, `FilmDriver` (`capture/film_driver.gd`, copied here byte for byte as it ran). The real main scene, `res://app/main.tscn`, boots as F5 runs it. The driver presses the game's input actions with `Input.action_press()`, as `checks.gd` does, and reads state. It never calls Rudy's, `RudyLook`'s or the `AnimationPlayer`'s methods, places nothing, and assigns nothing in the game. Its scheduler runs after Rudy's physics tick (`process_physics_priority` 1000), so a press it makes is read on his next tick; that is how the re-presses and the jump land on chosen swing ticks. Each drawn frame it prints one `frame N …` line: Rudy's place, mode and gear, the clip and its position, the Sprite's cell, whether the rig shows, Grip's angle, whether the hitbox is live, the swing tick, goblin B and the hearts. Each tick it prints a `tick …` line for a press Rudy reads, a mode change, the end of a swing, and a hit.

The takes, each a fresh boot (`capture/takes.sh`):

```bash
HOME="$SCRATCH/home" godot --path game --resolution 3840x2160 --always-on-top --write-movie take$n/play.avi --fixed-fps 30 -- take=$n
ffmpeg -i take$n/play.avi -map 0:v -c:v libx264 -preset slow -crf 14 -pix_fmt yuv420p -r 30 play-0$n.mp4
ffmpeg -i take$n/play.avi -map 0:a -c:a pcm_s16le play-0$n.wav
```

- **take 1** (748 frames, 24.9 s): the title; Enter (read on frame 30); the run (from frame 51), over the first spikes and the first goblin (rise 87 and 128, fall 99 and 139); the sword picked up while running (frame 168, `sword_run` from cell 12); a stop; one slash (frames 198–205, swing ticks 1 to 15, two a frame); a slash with J pressed again, read on swing ticks 1, 5 and 13 (frames 221–229; the swing ends after tick 16 as usual); a slash with a jump read on swing tick 5 (from frame 254; airborne from 257, `sword_rise` 263, landed 277); a turn left (298), `sword_run` (301), a slash while running (315–323), `sword_run` again from cell 12 (324); then goblin B walks into his back: the slash is read on swing tick 0 (frame 718) and the hit lands on swing tick 1, STARTUP (`hurt`, frame 719).
- **take 2** (400 frames): the same route to goblin B without the middle part; the slash from frame 369; the hit on swing tick 5, ACTIVE (frame 371).
- **take 3** (400 frames): the same; the slash from frame 365; the hit on swing tick 13, RECOVERY (frame 371).

A hit with the sword always knocks the sword away, so each phase needs its own take.

**How each take was checked:**
- **A dry run first.** Each take was run headless at `--fixed-fps 30` before the windowed take (`compare.py`). In each windowed log, every `frame` line and every `tick` line equals its dry run's: 748 and 23 for take 1, 400 and 11 for takes 2 and 3.
- **Every frame was drawn.** Movie Maker writes one MJPEG packet per frame. `frozen.py` hashes them: in no take is any packet identical to the one before. A goblin walks on screen in every frame, so a frame the window did not draw would repeat its predecessor.
- **The log's frame numbers are the MP4's, by pixel.** Claude looked at the frames against their log lines: the sword in hand on 168; the rig on 198 (Grip −67.5, swing tick 1) and the arc on 199; the Sprite back on 206; the re-pressed slash on 221–229 and the Sprite on 230; the jump in the swing on 257; Rudy facing right on 297 and left on 298; the rig raised on 718 (Grip −70, swing tick 0) and the hurt pose on 719 (take 1); the rig on 369–370 and hurt on 371 (take 2); the rig on 365 and 370 (Grip +45) and hurt on 371 (take 3).
- The MP4s have 748, 400 and 400 frames (`ffprobe -count_frames`), 3840 × 2160. The WAVs are Movie Maker's 48 kHz stereo mix of the game's own music and effects.
- Each run log ends with the engine's exit report (4 ObjectDB instances leaked, 2 resources in use), as its dry run does.
- Movie Maker renders offline at a fixed step, so this is not evidence of real-time frame rate. Physics ran at the project's 60 ticks a second: frame 0 runs one tick, and frame N ≥ 1 runs ticks 2N−1 and 2N.

**The first attempt, discarded.** The first windowed take 1 (PNG frames, no `--always-on-top`) had a log equal to its dry run, but 357 of its 748 frames repeated the previous image, in stretches (228–394, 426–459, 606–747 and shorter ones). A probe showed why: on macOS, Godot skips drawing while its window is covered by another window or is off the visible desktop (`DisplayServer.window_can_draw()` false), and Movie Maker writes the last drawn image again while the game runs on. Takes 2 and 3 of that attempt were stopped. Nothing from it is used. The takes above ran with `--always-on-top` while shuai-z left the screen alone, and in MJPEG, which wrote a 4K frame in about 0.27 s against about 3.1 s for PNG.

**What the driver's window guard did not do.** The driver was meant to print a `draw` line and end the take when `window_can_draw()` turned false. It tests `"--write-movie" in OS.get_cmdline_args()`, and Godot leaves its own flags out of that list, so the guard never ran: no log has a `draw` line. The takes rest on the packet check above instead. For a re-record, the test should be `OS.has_feature("movie")`, which a probe showed is true under Movie Maker.

**What "4K" means here.** macOS clamps the window to the screen, 3420 × 1948 on this display, and Movie Maker writes each frame at the 3840 × 2160 override, scaling the drawn image. A probe of a test pattern shows the scaling: the frames are not pixel-native 4K. The chips say `4K ENGINE CAPTURE`, not "native".

**On screen:** every gameplay frame carries `GODOT 4.7.2 · MOVIE MAKER · 4K ENGINE CAPTURE · play-0N · frames …`, `SCRIPTED INPUT · a film-only driver on a copy presses Enter, move, jump and slash` and `CAPTURED BY CLAUDE AT SHUAI-Z'S REQUEST`. Replays are labelled with their speed (`REPLAY ¼×`) and play without the game's sound; at 1.0× the game's sound plays at −11 dB under the narration. Replays that show a 16:9 region of the same frames scaled up to 3840 × 2160 (Lanczos) say `ENLARGED 2.5×` or `ENLARGED 2×`; the regions are `STAND` and `APEX` in `tools/make_sheet.py`. Where narration outlasts the footage, the last frame is held and labelled `HELD FINAL FRAME` (2.6 s in B06, 4.0 s in B09, 4.7 s in B12, 1.7 s in B20, 2.1 s in B22). Frame-by-frame passes say `FRAME BY FRAME 1/24×` (each game frame held 0.8 s) or `1/16×` (0.53 s) and name the frames they show.

## 2 · The frame strips: fixture captures (B04, B07, B14, B17, B18, B25)

These are the strips committed with the tuning rounds and the previews (`captures/slash/r0/`, `r1/`, `r1-second-tick/`, `captures/run/r0/`, `r0-sword/`): Movie Maker runs of `game/previews/slash_preview.tscn` and `run_preview.tscn` in a 1280 × 720 window at 30 fps, made by Claude at shuai-z's request on 2026-11-16, with their logs in `logs/`. They are fixtures (Level 1 with the enemies frozen, the real Rudy), not the game in play, and every card that shows them says `FIXTURE CAPTURE(S)`. `tools/make_stills.py` crops them and enlarges the crops with nearest-neighbour, so no pixel is blended. Every reading and measurement on those cards is quoted from `TUNING.md`, `TEST-REPORT.md` or `CHANGE-BRIEF.md`, and the script asserts each quoted phrase is in its file.

## 3 · Recorded logs and committed files (the code beats, B10, B15, B23–B25)

The test and mutation cards print lines read from `logs/` (labelled `HEADLESS TEST OUTPUT` or `HEADLESS LOG`). The code beats are excerpts of committed files at `775c14c3`, cut by line range (`tools/make_sheet.py`) and shown as a labelled Godot editor reconstruction.

| Still | Sources |
| --- | --- |
| `stills/game-card.png` | crops of frames 120 (run, cell 2) and 200 (slash, swing tick 5) of `capture/play-01.mp4`; the script asserts both from `capture/play-01-run.log` |
| the other stills | `tools/make_stills.py` names each source in the card's footer; `FACTCHECK.md` lists them beat by beat |

## Hashes (SHA-256)

```
5d9ad33c37a198b28e3c3324dbc8eed6a8510e2f6acaa126bc4864c867c4239f  capture/play-01.mp4               (not in git)
590058e239da5d8987ae3a923b93983497112338deda1298266dd40e2c6fda11  capture/play-01.wav               (not in git)
6b6c8bbf59fa96ae2f2f9f84d9997c658ddf3d1db30dee57d181891c179ef4fa  capture/play-01-run.log
a8d63ef85a11ebd850cdaadee6c75474e10aaa2b2d1fb5829dfc016d283dfba8  capture/play-02.mp4               (not in git)
e5a94c81c56e9cbd3c51cb3f1f2b70ddda5bd3fd3e3b8471670c271fb1f70819  capture/play-02.wav               (not in git)
8f3bf235f5a3ef99957ef8933a9d8300215a033c08c872b61b57a891d7cd285a  capture/play-02-run.log
a22dff64dd5cc7c19dfcf6735717f9828c0eba747e31135d7fed20df7ce15980  capture/play-03.mp4               (not in git)
04ad0cc4ec3ce71454300d525730d13a873cfc79ff08e8fd28bb12e478a6d85e  capture/play-03.wav               (not in git)
aae5c4808392116e807f2c762be16762936bafc298b3fea99c254c8900796215  capture/play-03-run.log
533a2e39911e32116fb2be9b1d1da961ac2ffebb44d0023296838c2c6bec5847  capture/film_driver.gd
ac0c14c102314c1d15fc9f5f8abd6824708a0aad1fcb665c49253da2594d4117  capture/game-project.godot.diff
a9edc7cc801096a4ba9d6a52dfb3f01a3269daf6c95f20e12f0e836c508893d6  capture/takes.sh
2077cc01226fae71715138167a5a85a79185ac3424c32b5b0231fed38d1dde33  capture/compare.py
d6476681f1659aff0ea106f558c50978ea74caf67f33aac8184fab7b700b7f36  capture/frozen.py
```
