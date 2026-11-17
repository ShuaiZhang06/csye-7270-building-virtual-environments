# ATTRIBUTION — the slash rig's parts

The sprite credits file for the three parts of the cutout rig that the `slash` clip moves. Checked on 2026-11-16. Paths are relative to the assignment folder, `assignment-7/`.

## What they are

Each part sits on the frames' 410 × 386 px canvas, with the same origin, so that at rest the parts register on the frame they were cut from:

| Part | What it holds | SHA-256 |
|---|---|---|
| `slash_body.png` | the frame without the blade and without the translucent arc, with the arc's band over the robe and the shield repaired; the grip and pommel stay here (`CHANGE-BRIEF.md`, Revision 4) | `f7056aed1f779493610a790e68248011f59b7f0675026dc15409088aa6d71826` |
| `slash_blade.png` | the blade and crossguard, from the fist outwards | `fffb95c5f733d4e0c50f142ef9c90ed4d9a00f6195f68fba2970d79eabd77d55` |
| `slash_arc.png` | the translucent arc alone | `816b0964b12d953a950012c20d8b9c366ce34b568afe130edfcd4b1e07f939ca` |

- **How they were made.** `tools/cut_slash_rig.py` cut them from one frame, `game/content/rudy/frames/CHAR-SWORD-SLASH.png` (SHA-256 `65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc`), which stays as it is (commit `de54303b`).
- **What the script checks.** It asserts the source's SHA-256, and that the three parts composited at rest equal the frame outside the repaired band. It measures the grip point.
- **Its review images** are in `evidence/rig-cut/`.
- **The imports.** Each part's `.import` file has the frames' own import settings.
- **What this makes them.** The parts are a derivative of my own art, made by code, and the script is committed as their editable source.

## Source, model and terms

- **The source frame** is Rudy's slash pose from my Assignment 2 generated art. Its original as generated is `../assignment-2/generated/accepted/CHAR-SWORD-SLASH-01.jpg`. It was made into the game frame by `../assignment-2/design/tools/matte_sprites.py`, which kept Gemini's translucent motion trail. That trail is the arc here.
- **Model.** The Gemini app's image generation, which the app reports as Nano Banana. The app does not show the exact image-model version; the chat model was Gemini 3.8 Flash. The frame came from chat `c96980a1d1603d6f`, turn 2 (`../assignment-2/ASSET-LOG.md`, row CHAR-SWORD-SLASH-01).
- **Terms.** Google Terms of Service and the [Generative AI Additional Terms of Service](https://policies.google.com/terms/generative-ai). The page fetched on 2026-10-01 said it was last modified on 2023-08-09. Those terms do not say who owns generated content (`../assignment-2/SOURCES.md`, "Generative models").
- **No other licence is involved.** No third-party art, and no named living artist, brand or copyrighted character in the prompt (Assignment 2's rules).
- **Publication.** The original and the frame have been in this public repository since Assignment 2.

## Where the prompt is logged

- **The prompt, in full,** is in `../assignment-2/generated/logs/2026-10-01-gemini-CHAR-SWORD.md`.
- **Its row** is in `../assignment-2/ASSET-LOG.md`.

Claude Code drafted this file on 2026-11-16 from those records. I review it before it is committed.
