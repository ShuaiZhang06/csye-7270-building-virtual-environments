# walker-rudy

A 2D side-scroller for CSYE 7270, Assignment 2: *Generate Art, Sound, and Music for Your Game*. By Shuai Zhang.

You play Rudy, a cheerful chibi boy who crosses a medieval countryside to reach the teleport circle at the end of each level. The game on one page: [CONCEPT.md](CONCEPT.md).

| | |
| --- | --- |
| Status | Generating art: Rudy's reference is accepted (CHAR-REF-07); all nine default-form poses are accepted (HURT and RUN-B after one edit each); the sword form is next; see [ASSET-LOG.md](ASSET-LOG.md). No Godot project yet. The design before generation is tagged `design-v1` |
| Started from | An empty repository (not walker-jumpman and not my Assignment 1 project) |
| Engine | Godot 4.7.2.stable.official.ed1daf0bf, installed; the project is not created yet |
| Assistance | Claude Code. The human/AI split is recorded in [FRICTIONAL.md](FRICTIONAL.md) and, later, `SOURCES.md` |

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
