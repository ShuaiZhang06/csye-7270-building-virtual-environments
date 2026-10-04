# walker-rudy

A 2D side-scroller for CSYE 7270, Assignment 2: *Generate Art, Sound, and Music for Your Game*. By Shuai Zhang.

You play Rudy, a cheerful chibi boy who crosses a medieval countryside to reach the teleport circle at the end of each level. The game on one page: [CONCEPT.md](CONCEPT.md).

| | |
| --- | --- |
| Status | Generating art: Rudy's reference is accepted (CHAR-REF-07); the nine default-form and seven sword-form poses are accepted, and their game frames are made (`game/content/rudy/frames/`) and, since step 2a, drawn in the game; the Level 1 sky, fields and ground are generated and made into layers (`game/content/level_1/art/`), in the game since step 2b; so are the spikes (in the game since step 2b), the waystone, the teleport circle, the pickup, the goblin, the hearts and the end card (sprites in `game/content/level_1/art/`, `game/content/goblin/frames/` and `game/ui/art/`, not wired in yet); see [ASSET-LOG.md](ASSET-LOG.md). Building the game in `game/`: the greybox steps 1a (Rudy on a flat ground strip, revised after two playtests), 1b (the layout, falls and respawns, the waystone, the teleport circle and the end card), 1c (hearts, spikes, goblins and the stomp) and 1d (the sword-and-shield pickup and the slash) are built with code-drawn placeholders. The art swap (step 2) is under way: 2a put in Rudy's frames with the 4 px outer outline, and 2b the Level 1 sky, fields and ground, and, after its playtest, the spikes; next, 2c (the other props, the goblin, the hearts and the end card). The design before generation is tagged `design-v1` |
| Started from | An empty repository (not walker-jumpman and not my Assignment 1 project) |
| Engine | Godot 4.7.2.stable.official.ed1daf0bf, the standard build, with GDScript; the project is `game/` |
| Assistance | Claude Code. The human/AI split is recorded in [FRICTIONAL.md](FRICTIONAL.md) and, later, `SOURCES.md` |

## Run the greybox

Open `game/project.godot` in Godot 4.7.2, or run it from the repository root (in a fresh clone, run the import line first):

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
/Applications/Godot.app/Contents/MacOS/Godot --path game
```

Controls so far: A/D or ←/→ to move (on the ground, a tap of the other direction turns Rudy on the spot; hold it to move); Space, W or ↑ to jump; J or X to slash, once Rudy has the sword; Enter on the end card plays the level again; F1 hides the debug line.

Checks, headless: `Godot --headless --path game --fixed-fps 60 res://tests/checks.tscn`. Screenshots for inspection (opens a window): `Godot --path game --resolution 1920x1080 --always-on-top res://tests/capture.tscn -- 1a 1b`, which writes to `evidence/<step>/`.

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
