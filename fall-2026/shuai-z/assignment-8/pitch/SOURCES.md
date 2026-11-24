# SOURCES — the Assignment 8 pitch film

*Claude Code (Claude Opus 5.5) drafted this file on 2026-11-24, at my request, from this folder's records and the earlier assignments' SOURCES files; I review it.*

What I used, what I made, what Claude contributed, and every asset's source and licence. The dated record of who decided what is `FRICTIONAL.md`.

## Who did what

**Me (Shuai Zhang).**
- **The game and its design.** Walker Rudy's design decisions are mine: v1 of the GDD (Assignment 4) and the game I built with Claude Code in Assignments 2 to 7.
- **The project and its scope.** I chose the project, and then changed its scope to all six levels, "让教授决定内容是否合适" ("let the professor decide whether the content is right", 2026-11-23).
- **The answers the pitch rests on:**
  - the comparable games I have played (*Super Mario Bros.* and *New Super Mario Bros.*);
  - why I picked this project (mostly to learn), and that none of the course's skills were mine before this semester;
  - who the reader is;
  - the Web export target.
- **Each go-ahead**, dated in `FRICTIONAL.md`:
  - putting the GDD in this folder;
  - shortening the beat sheet;
  - recording Level 1;
  - the pictures;
  - the voice, which also approved the player-experience goals (B06) and the target role, gameplay programmer (B24), as drafted;
  - skipping the speech-to-text check of the voice;
  - rendering.
- **The finished film.** I watched it on 2026-11-24, found no problem, and uploaded it to Google Drive.

**Claude Code (Claude Opus 5.5, in the Claude desktop app), at my request.**
- **Drafted these documents:**
  - `PROJECT-BRIEF.md` (drafts 1 to 3, from my answers);
  - `GDD.md` v2, which puts my v1 into the GDD tool's sections. It drafted the IDs, the must/should/could tags, the cut order and the save rules; the GDD's "Changes from version 1" table says which of those I have not confirmed yet;
  - the beat sheet and its narration (`tools/make_sheet.py`);
  - `FACTCHECK.md`, `CAPTURE.md`, `FRICTIONAL.md` (from our conversation), `README.md`, `BUILD-PROMPT.md` and this file.
- **Wrote the code:**
  - the film driver (`capture/film_driver.gd`, adapted from Assignment 7's), the take script and its check;
  - every script in `tools/`;
  - the 28 Manim scenes in `scenes.py`, which start from the toolkit's drawing kit, pasted in as the show-tell skill asks.
- **Ran the work:** the takes, the voice, every render and every gate. It looked at the takes' frames against their logs, and at each beat's middle frame in the master. Those readings are Claude's, not my verdict.
- **Checked these licences on 2026-11-24:**
  - the default font of the game;
  - the film's font;
  - the voice model's.

**Kokoro**, a local text-to-speech model, voiced the narration with its `am_onyx` voice. The voice speaks as me. It is not a clone of anyone, and it is not the instructor's Liam persona.

Nobody else worked on the film. Nobody has playtested the game.

## What the film shows

| Picture | Beats | Where it comes from | Made or generated |
| --- | --- | --- | --- |
| Level 1 in play | B01, B02, B07, B11, B28 | Godot Movie Maker takes of the game at tag `a7`, with scripted input from a film-only driver on a copy outside the repository (`CAPTURE.md`); labelled on screen | captured from my game. The art in it is generated (see below) |
| The title screen and the "Level complete" card | B00, B26 | frames 0 and 500 of the `run` take (`stills/title.png`, `stills/end-card.png`) | captured from my game |
| Rudy's running frame | B24 | `CHAR-RUN-A.png` from the game at tag `a7` (`stills/rudy-run-a.png`) | generated (Gemini app, Assignment 2), cut out by code |
| Rudy's frames; the Level 1 cast | B15, B16 | `figures/rudy.jpg`, `figures/cast.jpg`: Assignment 2's generated images, laid out with labels | generated, and labelled so on screen |
| The world map; the boss's three phases | B10, B13 | `figures/world-map.png`, `figures/boss-phases.jpg` | drawn by code (`tools/make_figures.py`, Assignment 4, written by Claude Code), labelled "constructed" on screen |
| The six levels | B12 | `figures/levels.jpg`: Level 1 as an in-game screenshot; Levels 2–6 as blockouts drawn by code | screenshot from my game, plus drawn by code; labelled |
| Level 1 screenshots | B30 | `figures/level-1.jpg`: in-game screenshots from the Assignment 2 slice | screenshots from my game; the art in them is generated |
| Every other picture | the other beats | drawings made for this film by `scenes.py`, plus the terms card and the outro | drawn by code |
| The opening | BIDEA | the toolkit's Remotion scene `BrutalistHesitantWriter`, with my text | drawn by code |

`figures/` also holds `game-flow.png`, a diagram drawn by code that GDD.md shows and the film does not. The seven figures were copied from my Assignment 4 GDD.

Nothing in the film was generated for it: no image, clip or sound came from a generative model for this film. The film has no music and no sound effects. Its only sound is the narration; the game's own audio was muted in every clip.

## Every asset, with its licence

The terms of the generative models are quoted from Assignment 2's `SOURCES.md`. That file and `ASSET-LOG.md` have the full records, with dates.

| Asset | In the film | In the game | Source | Licence or terms |
| --- | --- | --- | --- | --- |
| Rudy's frames; Level 1's backgrounds, props, goblin, end card and hearts | yes, in the play and the figures | yes | Gemini app image generation, Assignment 2: generated | Google Terms of Service and the Generative AI Additional Terms of Service. They forbid using the service to develop machine-learning models, require following the Generative AI Prohibited Use Policy, and do not say who owns generated content |
| SFX-JUMP | no (muted) | yes | Adobe Firefly, Generate sound effects, Assignment 2: generated | Adobe General Terms of Use and Generative AI User Guidelines. The game files keep their Content Credentials |
| SFX-STOMP, HURT, PORTAL, SLASH, PICKUP | no (muted) | yes | ElevenLabs sound effects, free plan, Assignment 2: generated | ElevenLabs Terms of Service: I keep the rights in my output, for non-commercial use only. Anything published with these sounds must have "elevenlabs.io" or "11.ai" in its title. This film contains none of them, so its title does not carry that |
| MUS-LOOP-01 | no (muted) | yes | Suno v6 mini, free plan, Assignment 2: generated | Suno Terms of Service: free-plan output is for personal, non-commercial use only, and Suno keeps the rights in it; no attribution is required |
| The hearts' invulnerable tint shader | part of the game captured in the play | yes | written by me, Assignment 5 (tag `a5`) | mine |
| Slash sparks and dust trail | part of the game captured in the play | yes | built for my game by Claude Code sessions I directed, Assignment 6 (tag `a6`) | mine |
| Rudy's run cycle and slash rig | part of the game captured in the play | yes | made by code from my generated frames, Assignment 7 (tag `a7`) | mine; the frames under Google's terms |
| The game's on-screen text ("Press Enter to start", "Paused") | yes, in the play | yes | Godot's built-in default font, Open Sans SemiBold, compiled into the engine. The game ships no font file and sets no theme font | SIL Open Font License 1.1, © 2020 The Open Sans Project Authors. Read from Godot 4.7.2's own copyright list (`Engine.get_copyright_info()`) on 2026-11-24 |
| Godot Engine | yes, in the play | yes | 4.7.2.stable.official | MIT licence |
| The film's type | yes | no | EB Garamond (Regular, Medium, Italic), installed on my Mac | SIL Open Font License 1.1, © 2017 The EB Garamond Project Authors. Read from the font file's own name table on 2026-11-24 |
| The voice | yes | no | Kokoro-82M through kokoro-onnx, voice `am_onyx`, run locally. The model files come from kokoro-onnx's `model-files-v1.0` release | Kokoro-82M: Apache 2.0 (its Hugging Face model card); kokoro-onnx: MIT (its GitHub repository). Both read on 2026-11-24 |

**Generated, and labelled so.**
- **On screen:**
  - B15 and B16 label their figures "generated (Gemini app, Assignment 2)";
  - B30 labels its screenshots "generated art, in the game at a7";
  - B00 labels the title screen "the game's title screen, tag a7".
- **In the narration:** B15 says Rudy's frames are generated, and B30 says the images, sound and music are all generated and where each comes from.
- **One small picture has no label of its own.** In B24, Rudy's running frame stands for the game inside a drawn browser window. It is the same generated frame that B15 labels.
- **No rejected output.** The film shows none. Three rejected run frames from ChatGPT (Assignment 2) are in neither the game nor the film.

**Nothing was bought.** The Gemini app ran on a paid plan, which is a subscription to the tool, not a bought asset (Assignment 2's `SOURCES.md`).

**Rudy's look** resembles an existing character. Assignment 2's `SOURCES.md` ("Resemblance to an existing character") records this and what the prompts do about it. No prompt, file or frame of the film names that character.

## Tools used to make the film

| Tool | Version | Used for | Licence |
| --- | --- | --- | --- |
| Claude Code (desktop app), model Claude Opus 5.5 | — | the drafts, the code, the takes, the renders and the checks (above) | Anthropic's terms |
| Brutalist toolkit (`brutalist.art`), show-tell skill | checkout `3a6d3979` (2026-11-07) | the beat-sheet contract, the drawing kit, the Kokoro wrapper, the opener, the compiler and every quality gate | course-provided. The checkout has no licence file, and it is used as Assignment 8 directs |
| Manim Community | 0.18.1, on Python 3.12 | the 28 scenes in `scenes.py` | MIT |
| Remotion | 4.0.535, the toolkit's install | the opening (BIDEA) | Remotion License: free for individuals |
| Kokoro-82M through kokoro-onnx | kokoro-onnx 0.6.1; model `kokoro-v1.0.onnx` | the narration | as above |
| Godot, Movie Maker | 4.7.2.stable.official.ed1daf0bf | the takes | MIT |
| FFmpeg | 9.0.2 | cutting, labelling and encoding the clips; the toolkit's compiler | — |
| Python 3 with Pillow | Python 3.13.5, Pillow 10.4.0 | `tools/` (the label chip is drawn with Pillow) | — |

No paid service, API key, stock media or media account was used for the film. Claude uploaded and published nothing. The upload to Google Drive was mine.
