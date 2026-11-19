# BUILD-PROMPT — rebuild this film end to end

Paste into Claude Code with `brutalist.art` and this course repository both available. It rebuilds from the recorded captures; it never re-records unless asked, never edits `assignment-7/game/`, never calls a paid service, never publishes.

```text
Rebuild the godot-gamedev film in fall-2026/shuai-z/assignment-7/youtube/claude-liam-walker-rudy-animation with the walker
modifier, following brutalist.art/skills/make/godot-gamedev/SKILL.md. Do not change assignment-7/game.

1. Confirm `git diff 775c14c3 -- fall-2026/shuai-z/assignment-7/game` is empty. If it is not, stop: the film describes 775c14c3.
2. From the reel folder:
     python3 tools/make_sheet.py          # beat sheet; code excerpts cut from game/ by line range
     python3 tools/make_stills.py         # evidence stills and the figure; copies the figure into brutalist.art public/reels/
3. From brutalist.art:
     python3 runtime/scripts/generate_audio_kokoro.py <REEL>     # Liam, Kokoro am_onyx, free
4. From the reel folder:
     python3 tools/build_reel.py          # durations, cue times, the gameplay and still media, per-beat mix (mix/*.wav)
     python3 tools/make_evidence.py       # checks/game/ ledger (hashes the result media)
     python3 tools/make_docs.py           # SHOTLIST, COMPONENTS, PROMPTS, RIFF
     tools/check.sh                       # the course checker; must PASS
5. From brutalist.art:
     python3 runtime/scripts/remotion_scenes.py <REEL> --force
     ./art final <REEL> --height 2160 --fps 30 --out <REEL>/exports/landscape
   then tools/check.sh again.
6. Visual QC: sample the master and each beat, read the frames (code legibility, labels, chips inside the safe area, the outro card),
   listen across every transition, and log defects in _qc/REPORT.md. Fix causes, re-render.
7. Report the 4K MP4's absolute path, its SHA-256 (the .verified.json receipt), duration, gate results and limitations.
   Do not upload, publish or push.

capture/play-0N.mp4 and .wav are not in git. To re-record them (only if game/ changed, and only after asking shuai-z, since the
assignment says the student runs every capture): follow CAPTURE.md §1 exactly — an isolated copy, the harness-only changes in
capture/game-project.godot.diff and capture/film_driver.gd (with the guard's test changed to OS.has_feature("movie"), as §1
says), headless dry runs at --fixed-fps 30 for take=1, 2 and 3 saved as dry-N.log, then capture/takes.sh, which records each
take always on top in MJPEG and runs frozen.py and compare.py. The screen must be left alone while it runs (about 10 minutes):
on macOS a covered window stops drawing. Check each log's frame numbers against the pixels as CAPTURE.md §1 does, and update
the frame numbers in tools/make_sheet.py and tools/make_stills.py before step 2.
```
