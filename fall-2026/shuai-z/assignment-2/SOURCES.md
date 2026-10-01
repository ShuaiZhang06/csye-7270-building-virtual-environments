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
| Claude Code (desktop app), model Claude Opus 5.5 | — | Design questions and drafts; the documents; the blockout, check and contact-sheet scripts. Later, the Godot code |
| Python 3 with Pillow | Pillow 10.4.0 | `design/tools/make_blockouts.py`, `check_against_sheet.py`, `contact_sheet.py` |
| Voyager browser extension | — | Exporting the Gemini chats into `generated/logs/` |
| Godot | 4.7.2.stable.official.ed1daf0bf | The game (not started yet) |

## Generative models

| Model | Version | Where it ran | Terms | Assets |
|---|---|---|---|---|
| Gemini app image generation, which the app reports as Nano Banana | The exact image-model version is not shown. The chat model was Gemini 3.8 Flash | Gemini app, hosted by Google, on my personal Google account | Google Terms of Service and the [Generative AI Additional Terms of Service](https://policies.google.com/terms/generative-ai). The page fetched on 2026-10-01 says it was last modified 2023-08-09. It forbids using the service to develop machine-learning models, requires following the Generative AI Prohibited Use Policy, and does not say who owns generated content | CHAR-REF-01 to CHAR-REF-07; the default-form poses CHAR-IDLE-01 to CHAR-CELEBRATE-01 |

No sound or music model has been used yet.

## Resemblance to an existing character

Rudy's name and look resemble Rudeus "Rudy" Greyrat from *Mushoku Tensei: Jobless Reincarnation*: light-brown hair, a grey hooded mage robe, and a young mage in a medieval other world. Claude pointed this out on 2026-10-01.

- No prompt names that character or that work.
- From 2026-10-01 the prompts do not name Rudy either; they say "the boy".
- For now, I have not changed his signature features.

## Human / AI contributions

The dated record is FRICTIONAL.md. In short:
- the design decisions are mine;
- Claude drafted the documents and prompts and wrote the scripts;
- the images come from Gemini;
- I chose and rejected the outputs.
