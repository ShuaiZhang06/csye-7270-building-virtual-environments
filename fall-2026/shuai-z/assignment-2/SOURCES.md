# SOURCES — walker-rudy

Credits, tools, generative models and their terms, and who did what. This file is updated as the work goes on; the generation records are in ASSET-LOG.md and the dated record in FRICTIONAL.md.

## Starting point

An empty repository, created on 2026-09-30. There is no starter code and no starter art: not walker-jumpman, and not my Assignment 1 project.

## People

- **Shuai Zhang (me):** design decisions, prompts, generation runs, choosing and rejecting outputs.
- No other collaborators or playtesters so far.

## Tools

| Tool | Version | Used for |
|---|---|---|
| Claude Code (desktop app), model Claude Opus 5.5 | — | Design questions and drafts; the documents; the blockout, check and contact-sheet scripts; the Godot code in `game/` |
| Python 3 with Pillow, NumPy and SciPy | Pillow 10.4.0, NumPy 2.1.3, SciPy 1.15.3 | `design/tools/make_blockouts.py`, `check_against_sheet.py`, `contact_sheet.py`, `matte_sprites.py`, which makes Rudy's game frames from the accepted originals (background removal, scaling, placement), `prepare_env.py`, which makes the Level 1 layers (keying, tiling, scaling, the soil below the ground), `prepare_props.py`, which makes the props and the goblin's frames, and `prepare_sfx.py`, which makes the game's sound effects from the accepted takes (cutting, fades, mono, peak level) |
| Voyager browser extension | — | Exporting the Gemini chats into `generated/logs/` |
| Godot | 4.7.2.stable.official.ed1daf0bf, the standard build | The game, in `game/`, written in GDScript; started on 2026-10-01 as a greybox with code-drawn placeholders |

## Generative models

| Model | Version | Where it ran | Terms | Assets |
|---|---|---|---|---|
| Gemini app image generation, which the app reports as Nano Banana | The exact image-model version is not shown. The chat model was Gemini 3.8 Flash | Gemini app, hosted by Google, on my personal Google account | Google Terms of Service and the [Generative AI Additional Terms of Service](https://policies.google.com/terms/generative-ai). The page fetched on 2026-10-01 says it was last modified 2023-08-09. It forbids using the service to develop machine-learning models, requires following the Generative AI Prohibited Use Policy, and does not say who owns generated content | CHAR-REF-01 to CHAR-REF-07; the default-form poses CHAR-IDLE-01 to CHAR-CELEBRATE-01; the sword form CHAR-SWORD-IDLE-01 to CHAR-SWORD-FALL-01; the Level 1 environment (ENV-SKY-CASTLE, ENV-FIELDS, ENV-GROUND); the props, the goblin and the end card |
| Adobe Firefly, Generate sound effects | The page shows no model name; the takes' Content Credentials name `Adobe Firefly GenSoundFX 2`, Firefly version 1.2 | Firefly web app, hosted by Adobe, on Adobe's free plan | Adobe General Terms of Use and Generative AI User Guidelines; details in ASSET-LOG.md. Outputs may be used commercially unless a beta feature says otherwise; Content Credentials must not be removed to mislead, so the game files keep their link | SFX-JUMP-01 to SFX-JUMP-04 |
| ChatGPT image generation | Chat model GPT-5.6 Sol at high reasoning; the image model was ChatGPT's default, not named in the chat | ChatGPT, hosted by OpenAI, on my account | OpenAI [Terms of Use](https://openai.com/policies/terms-of-use/), effective 2026-01-01, fetched 2026-10-02. As between me and OpenAI, I own the output, and OpenAI assigns me any rights it has in it; output may not be unique. OpenAI may use content to improve its services, and I can opt out of its use for training; details in ASSET-LOG.md | CHAR-SWORD-RUN-B-02 to -04, all rejected |

No music model has been used yet.

## Resemblance to an existing character

Rudy's name and look resemble Rudeus "Rudy" Greyrat from *Mushoku Tensei: Jobless Reincarnation*: light-brown hair, a grey hooded mage robe, and a young mage in a medieval other world. Claude pointed this out on 2026-10-01.

- No prompt names that character or that work.
- From 2026-10-01 the prompts do not name Rudy either; they say "the boy".
- For now, I have not changed his signature features.

## Human / AI contributions

The dated record is FRICTIONAL.md. In short:
- the design decisions are mine;
- Claude drafted the documents and prompts and wrote the scripts;
- the images in the game come from Gemini (three rejected run frames came from ChatGPT), and the sound effects from Adobe Firefly;
- I chose and rejected the outputs.
