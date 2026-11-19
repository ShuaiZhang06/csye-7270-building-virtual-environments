# FILM-REVIEW — A Run and a Slash for Walker Rudy.

Review of the actual master, `exports/landscape/claude-liam-walker-rudy-animation.mp4`
(SHA-256 `3fe1870b064573fd4e8c1f2767bfe0248d886a1efdc34b296df257348397ce8e`, 828.8 s, 3840×2160 H.264 30 fps, AAC 48 kHz stereo), by Claude Code (Claude Opus 5.5) on 2026-11-17. Claude drafted this file. On 2026-11-18 shuai-z watched the final export and uploaded it: "看过了，没问题，传到Google drive了" ("I've watched it; there is no problem, and it's uploaded to Google Drive").

## Gates

| Gate | Result |
| --- | --- |
| `tools/check.sh` (the course's `./art godot-gamedev --check`, before render and at handoff) | PASS: 27 source files, 132 exclusions, 4 components, 8 exact excerpts, 8 code → result pairs |
| Gate T (type) | PASS, 31 beats, 0 FAIL (`TYPECHECK.md`) |
| Gate V (frames) | 62 frames sampled, 0 BLOCKER, 0 MAJOR (`REPORT.md`), after one fix (below) |
| Loudness (`loudness_check.py`) | PASS: −24.5 LUFS integrated, true peak −3.0 dBTP |
| Export receipt | `.verified.json`, status `ready`, SHA-256 matches the file |

## Corrections made before the final

1. **Gate V, BVD2.** The first compile was refused: the "Uncertain, and the next step" card filled 52% of the safe area (minimum 55%). The card lacked one item its narration says: "one machine, and no other player". That item was added, with the fact that the gameplay frames are scaled to 4K, not pixel-native (CAPTURE.md), and the card was rendered again.
2. **My frame review, five code panels.** The workbench's code panel does not scroll, and at the sizes first chosen it cut off lines the narration cues. No gate caught it:
   - B05 hid the key lines (times and values);
   - B11 hid line 241, the one `play_clip` call the beat is about;
   - B16 hid line 139;
   - B19 hid 314, 318 and 320;
   - B21 hid 156 and 158.

   Each excerpt now shows a contiguous range that holds every cued line, at the smallest code size (23): B05 47–60, B11 231–241, B16 131–139, B19 307–320 and B21 145–158. Where a range could not hold the beat's first point, a source note and a few words of narration say it sits just above: the mode block in B19 (296–306), and the sword's loss in B21 (139–144). B16's "divides by sixty" cue moved from line 127 to the tick list on line 132 that the check divides (`test_rudy_clips.gd:181`). The five beats were rendered again, and the sheet was checked to equal a fresh `tools/make_sheet.py` run.
3. **Before the first master** (SOURCES.md and CAPTURE.md list them):
   - the first capture attempt was void (frozen frames) and was recorded again;
   - the driver's window guard never ran;
   - "native 4K" was corrected;
   - the game card's frame was wrong;
   - the gameplay holds were cut from up to 21 s to 1.7–4.7 s.

## What I looked at in the master

Frames at 20 / 60 / 90 % of every beat (93 frames), and one frame just after each cue of the five rebuilt code beats (26 frames); `_qc/review/`, reduced to 960 × 540.

- **Code:** readable in every code beat. The highlighted line is inside the panel at each of the 26 cues, and the footer names it (for example 53 → 57 → 59 → 60 → 47 → 48 → 49 in B05; 238 → 239 → 241 → 232 in B11; 307 → 314 → 318 → 320 → 308 in B19).
- **Labels:**
  - "Godot editor reconstruction" on every code beat, and "reconstructed prompt — illustrative, not a transcript" on B00;
  - `FIXTURE CAPTURE(S)` on the strip cards (B04, B07, B14, B17, B18, B25);
  - `HEADLESS TEST OUTPUT` on B10, B23 and B24;
  - on every gameplay frame, the Movie Maker provenance chip (take and frames), `SCRIPTED INPUT …` and `CAPTURED BY CLAUDE AT SHUAI-Z'S REQUEST`;
  - on the replays, `REPLAY …×`, `FRAME BY FRAME …×` and `ENLARGED …×`; `HELD FINAL FRAME` on the five holds.
- **The engine footage shows what the labels and the narration say,** each checked against the take's log by pixel (CAPTURE.md):
  - the run's two cells;
  - `sword_run` from cell 12 on the pickup;
  - the rig on the slash frames;
  - the turn on frame 298;
  - the swing finishing in the air;
  - the hurt pose on the frame after the hit in each of the three takes.
- **The hesitant writer** completes the correction "seconds" → "frames" (B01).
- **The outro card:** the exact title, @NikBearBrown, one mascot, no subline.

## Sound

- **Loudness:** integrated −24.5 LUFS, range 5.8 LU, peak −3.0 dBFS.
- **Narration and game sound:** every beat carries narration. The game's own music and effects play under the 1.0× gameplay at −11 dB; replays and frame-by-frame passes carry narration only.
- **Silences:** the longest below −50 dB is 2.0 s, between beats.

## Limits of this review

- Claude sampled frames rather than watching every frame, and measured the audio rather than listening to it.
- The outro's title wraps after "Walker". The locked outro component sets the size and width, and the title is the exact title, so it was left.
- The gameplay frames are 3840 × 2160, but Movie Maker scaled them from a window clamped to the screen (CAPTURE.md), so they are not pixel-native 4K.
- The full check is shuai-z's, recorded above in their words; they did not list what they looked at.
