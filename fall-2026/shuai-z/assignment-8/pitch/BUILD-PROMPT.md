# BUILD-PROMPT — rebuild the pitch film

*Claude Code (Claude Opus 5.5) drafted this file on 2026-11-24, from the commands it ran to build the film on 2026-11-23 and 24; I review it.*

These are the commands that made the master. The film has not been rebuilt from a clean clone. A rebuild is expected to match the master in its beats, its length and its gate results, not byte for byte, since the takes and the encoders are run again.

Nothing here needs a paid service, an API key or an upload. The voice and every render run locally.

## What you need

| | Used for the master |
| --- | --- |
| This repository, with the tag `a7` | the game the takes are recorded from |
| The Brutalist toolkit (`git clone https://github.com/nikbearbrown/brutalist.art`), set up with its own `./setup --install` (Remotion, the local Kokoro model files) | checkout `3a6d3979` |
| A Python environment with the toolkit's Manim | Manim 0.18.1 on Python 3.12, in a conda environment at `/opt/anaconda3/envs/brutalist` |
| Python 3 with Pillow and kokoro-onnx, for `tools/` and the voice | Python 3.13.5, Pillow 10.4.0, kokoro-onnx 0.6.1 |
| Godot on the `PATH` as `godot`, only to record the takes | 4.7.2.stable.official.ed1daf0bf |
| FFmpeg | 9.0.2 |
| The EB Garamond font, installed (`tools/chip.py` reads `~/Library/Fonts/EBGaramond-Medium.ttf`; Manim finds "EB Garamond" by name) | EB Garamond Regular, Medium and Italic |
| macOS, for the takes (the window must stay on top while Movie Maker records) | macOS on an Apple M3 |

Below, `R` is this folder and `B` is the toolkit:

```bash
R="$(git rev-parse --show-toplevel)/fall-2026/shuai-z/assignment-8/pitch"
```

```bash
B=/path/to/brutalist.art
```

## The prompt

Paste this into Claude Code, opened in this repository, with the toolkit checked out beside it:

```text
Rebuild the Assignment 8 pitch film in fall-2026/shuai-z/assignment-8/pitch, following its BUILD-PROMPT.md step by step,
and the toolkit's own README and show-tell skill.

Rules:
- Do not change the game (fall-2026/shuai-z/assignment-7/game) or anything at tag a7. The takes come from a copy outside
  the repository.
- Do not edit the narration, scenes.py or the tools to make a gate pass. If a gate fails, stop and report the failure and
  its report file.
- The narration speaks as me, Shuai Zhang. Do not add the instructor's name, persona or credit line, and do not swap in
  the toolkit's house opener or outro.
- No paid service, no API key, no upload, no commit, no push.
- Leave the old renders in place by moving them to _superseded/, never by deleting them.

At the end, report: the master's path, its SHA-256 (from its .verified.json), its length, the gate results
(_qc/REPORT.md, TYPECHECK.md), and every way it differs from README.md's master (length, beats, warnings).
```

## The commands

### 1. Record the three takes (the MP4s are not in git)

Make a copy of the game at `a7` outside the repository, apply the three harness-only changes, and import it once:

```bash
CAP=/path/to/a/scratch/folder
mkdir -p "$CAP/home"
git archive a7 fall-2026/shuai-z/assignment-7/game | tar -x -C "$CAP" --strip-components=3
patch "$CAP/game/project.godot" < "$R/capture/game-project.godot.diff"
cp "$R/capture/film_driver.gd" "$CAP/game/"
HOME="$CAP/home" godot --headless --path "$CAP/game" --import
```

Then run the takes. Leave the screen alone while they record, a few minutes in all: macOS stops drawing a covered window.

```bash
cd "$R/capture" && CAP="$CAP" ./takes.sh
```

`takes.sh` runs each take headless first (the dry run), then in a window with `--write-movie`, at `--fixed-fps 30`. It keeps a take (`capture/take-<take>.mp4`) only if `check_take.py` passes: one video packet per logged frame, the window drawing from the first frame, no repeated frame except where the log says nothing moved, and the same `frame`, `event` and `step` lines as the dry run. `CAPTURE.md` has the expected frame numbers.

### 2. The stills (committed; remake them only after new takes)

```bash
cd "$R"
ffmpeg -v error -y -i capture/take-run.mp4 -vf "select='eq(n\,0)',scale=1920:1080:flags=lanczos" -fps_mode passthrough -frames:v 1 stills/title.png
ffmpeg -v error -y -i capture/take-run.mp4 -vf "select='eq(n\,500)',scale=1920:1080:flags=lanczos" -fps_mode passthrough -frames:v 1 stills/end-card.png
git show a7:fall-2026/shuai-z/assignment-7/game/content/rudy/frames/CHAR-RUN-A.png > stills/rudy-run-a.png
```

### 3. The beat sheet and the voice

```bash
cd "$R"
python3 tools/make_sheet.py
python3 "$B/runtime/scripts/generate_audio_kokoro.py" "$PWD"
python3 tools/finish_audio.py
python3 tools/make_sheet.py
```

- The first `make_sheet.py` writes `beat_sheet.json` and marks every beat's audio as stale.
- Kokoro (`am_onyx`) voices each beat into `mp3/`. The sheet's `metadata.pronounce` sets how "Shuai" and "Zhang" are said.
- `finish_audio.py` pads the outro with one silent second and records what was voiced (`mp3/voiced.json`).
- The second `make_sheet.py` carries each beat's measured length into the sheet.

`make_sheet.py` overwrites the sheet, including the build stamps of the last render. Never run it after step 5 unless you render again.

### 4. The clips and the paperwork

```bash
cd "$R"
python3 tools/cut_clips.py
python3 tools/label_clips.py
python3 tools/make_docs.py
python3 "$B/runtime/qc/factcheck_check.py" "$PWD"
```

- `cut_clips.py` cuts the five clips from the takes, fitted to each beat's narration, and logs the frames it used (`capture/logs/cut_clips.txt`).
- `label_clips.py` burns the label into each clip and puts it in the beat's slot, `media/<beat>.mp4`.
- `make_docs.py` writes SHOTLIST.md and PROMPTS.md, which the toolkit's Gate F needs.
- The fact-check script must report no problem with `FACTCHECK.md`.

### 5. Render and verify

Run the toolkit with its Manim environment first on the `PATH`. With the system Python instead, the layout audit crashes and Gate B reports a false layout warning.

```bash
cd "$B" && PATH=/opt/anaconda3/envs/brutalist/bin:$PATH ./art run "$R" --height 2160
```

```bash
cd "$B" && PATH=/opt/anaconda3/envs/brutalist/bin:$PATH ./art final "$R" --height 2160 --fps 30 --out "$R/exports/landscape"
```

- `art run` renders the Manim scenes and the opener, runs Gates L, SHAPE, A, W, B and V, and builds a review cut.
- `art final` runs Gate T, compiles the master, runs Gate V on it and writes `exports/landscape/walker-rudy-final-pitch.mp4` with its `.verified.json` receipt.
- `art run` renders only the scenes whose `manim/<beat>.mp4` is missing. To render a scene again, first move its old clip into `_superseded/`.

### 6. Check it

```bash
shasum -a 256 "$R/exports/landscape/walker-rudy-final-pitch.mp4"
```

Then compare that with the receipt, read `_qc/REPORT.md` and `TYPECHECK.md`, and watch the whole film. README.md lists the warnings that are expected and why.
