# walker-rudy

A 2D side-scroller for CSYE 7270, Assignment 2: *Generate Art, Sound, and Music for Your Game*. By Shuai Zhang.

You play Rudy, a cheerful chibi boy who crosses a medieval countryside to reach the teleport circle at the end of each level. The game on one page: [CONCEPT.md](CONCEPT.md).

| | |
| --- | --- |
| Status | The art is generated and in the game: Rudy's reference (CHAR-REF-07), his nine default-form and seven sword-form poses, the Level 1 sky, fields and ground, the spikes, the waystone, the teleport circle, the pickup, the goblin, the hearts and the end card; see [ASSET-LOG.md](ASSET-LOG.md). The game in `game/` was built as a greybox with code-drawn placeholders in steps 1a–1d (Rudy on flat ground; the layout, falls and the checkpoints; hearts, spikes, goblins and the stomp; the sword form), and the art went in during steps 2a (Rudy, with the 4 px outer outline), 2b (the layers, the ground and the spikes), 2c (the other props, the goblin, the hearts and the end card) and 2d (the title over the opening). Step 3 put in the audio: the six generated sound effects and the music loop on their own buses, with the music's dips under a hit, the pause and a death, its fade on the teleport circle, Esc to pause and M/N to mute. Next, step 4 (the mushroom, a "should") and step 5 (the checks and my playtests). The design before generation is tagged `design-v1` |
| Started from | An empty repository (not walker-jumpman and not my Assignment 1 project) |
| Engine | Godot 4.7.2.stable.official.ed1daf0bf, the standard build, with GDScript; the project is `game/` |
| Assistance | Claude Code. The human/AI split is recorded in [FRICTIONAL.md](FRICTIONAL.md) and, later, `SOURCES.md` |

## Run the greybox

Open `game/project.godot` in Godot 4.7.2, or run it from the repository root (in a fresh clone, run the import line first):

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
/Applications/Godot.app/Contents/MacOS/Godot --path game
```

Controls so far: A/D or ←/→ to move (on the ground, a tap of the other direction turns Rudy on the spot; hold it to move); Space, W or ↑ to jump; J or X to slash, once Rudy has the sword; Enter on the title starts play, and on the end card plays the level again; Esc pauses and resumes play; M mutes the music and N the sound effects; F1 hides the debug line.

Checks, headless: `Godot --headless --path game --fixed-fps 60 res://tests/checks.tscn`. Screenshots for inspection (opens a window): `Godot --path game --resolution 1920x1080 --always-on-top res://tests/capture.tscn -- 1a 1b`, which writes to `evidence/<step>/`. Step 3's audio is recorded with Godot's movie maker: add `--write-movie <file>.avi` and name step `3`, then `python3 design/tools/plot_mix.py <file>.avi` measures the mix and draws `evidence/3/3-mix.png`.

## Design documents

- [CONCEPT.md](CONCEPT.md): the game on one page (draft)
- [STORYBOARD.md](STORYBOARD.md): seven panels of the play experience (draft; blockout pictures in `design/storyboard/`)
- [CHARACTER-SHEET.md](CHARACTER-SHEET.md): the contract for Rudy's generated frames (draft; blockout images in `design/character/`)
- [CHANGE-BRIEF.md](CHANGE-BRIEF.md): the asset list, event-to-sound map, music behavior and predicted failures (draft)
- [design/generation-prompts.md](design/generation-prompts.md): starting prompts, not used yet
- [design/tools/make_blockouts.py](design/tools/make_blockouts.py): draws the blockouts (code written by Claude; not a generative model)
- [ASSET-LOG.md](ASSET-LOG.md): every generation kept or seriously considered, with its prompt, outcome and reason
- [SOURCES.md](SOURCES.md): starting point, tools, generative models and their terms, and who did what
- [FRICTIONAL.md](FRICTIONAL.md): a dated log of the design decisions
