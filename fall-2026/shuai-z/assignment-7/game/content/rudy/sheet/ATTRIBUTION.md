# ATTRIBUTION — `rudy_sheet.png`

The sprite credits file for Rudy's sheet, which the run cycle (`run`, `sword_run`) and the one-key state clips read. Checked on 2026-11-16. Paths are relative to the assignment folder, `assignment-7/`.

## What it is

- **The sheet.** `rudy_sheet.png`, 1640 × 1544 px RGBA, a 4 × 4 grid of 410 × 386 px cells with no padding. The cell order is that of `game/content/rudy/frames/frames.json` (`CHANGE-BRIEF.md`, section 2.1). Its SHA-256 is `4eba0d1ed8d0ce8e63ca554a9a8fc2c560208f4eac59aeeba38ed9520a432ff7`.
- **How it was made.** `tools/pack_rudy_sheet.py` packed Rudy's 16 game frames, `game/content/rudy/frames/CHAR-*.png`, with no scaling and no edits (commit `0736d0fa`). The script asserts that each cell equals its source PNG pixel for pixel, and a self-test damages copies to show that the check fails.
- **The import.** `rudy_sheet.png.import` has the frames' own import settings, with mipmaps on.

## Source

- **Rudy's frames are my own generated art from Assignment 2.** Not a found sheet, and not the course sprite set.
- **The originals as generated** are `../assignment-2/generated/accepted/CHAR-*.jpg`, 16 of them. For example `CHAR-RUN-A-01.jpg`, `CHAR-RUN-B-02.jpg`, `CHAR-SWORD-RUN-A-01.jpg` and `CHAR-SWORD-RUN-B-01.jpg` are the four run cells.
- **The game frames** were made from those originals by `../assignment-2/design/tools/matte_sprites.py`. It keyed out the background, scaled each frame and placed it on the shared canvas, as each row of `../assignment-2/ASSET-LOG.md` says.
- **Publication.** The originals, the frames and the tools have been committed in this public repository since Assignment 2, on the `shuai-z/assignment-2` branch. The frames appear in the films of Assignments 2, 5 and 6.

## Model and terms

- **Model.** The Gemini app's image generation, which the app reports as Nano Banana. The app does not show the exact image-model version; the chat model was Gemini 3.8 Flash. All 16 frames came from two chats, `87c157d4397cf98b` (the default form) and `c96980a1d1603d6f` (the sword form) (`../assignment-2/ASSET-LOG.md`).
- **Terms.** Google Terms of Service and the [Generative AI Additional Terms of Service](https://policies.google.com/terms/generative-ai). The page fetched on 2026-10-01 said it was last modified on 2023-08-09. Those terms do not say who owns generated content (`../assignment-2/SOURCES.md`, "Generative models").
- **No other licence is involved.** No third-party art, and no named living artist, brand or copyrighted character in any prompt (Assignment 2's rules).

## Where the prompts are logged

- **The prompts, in full,** are in `../assignment-2/generated/logs/`:
  - `2026-10-01-gemini-CHAR-POSES.md` and `2026-10-01-gemini-CHAR-POSES-round2.md`: the default form, including the edits that made `CHAR-HURT-02` and `CHAR-RUN-B-02`;
  - `2026-10-01-gemini-CHAR-SWORD.md`: the sword form.
- **Each frame's prompt and edits** are in its row of `../assignment-2/ASSET-LOG.md`.

Claude Code drafted this file on 2026-11-16 from those records. I review it before it is committed.
