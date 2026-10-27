# SOURCES — Assignment 5, walker-rudy's shaders and materials

Credits, tools, versions, and who did what. The dated record is [FRICTIONAL.md](FRICTIONAL.md). This file is updated as the work goes on.

## Starting point

- **My Assignment 2 game**, `game/`:
  - a copy of [`../assignment-2/game/`](../assignment-2/game/) as committed at tag `a3`, copied unchanged (commit `84658acf`);
  - its art, sound and music, with their models and terms, are credited in [../assignment-2/SOURCES.md](../assignment-2/SOURCES.md) and [../assignment-2/ASSET-LOG.md](../assignment-2/ASSET-LOG.md).
- **My Assignment 3 props scene**, `godot/`:
  - a copy of [`../assignment-3/godot/`](../assignment-3/godot/) as committed at `a3`, copied unchanged in the same commit;
  - its props and colours are credited in [../assignment-3/SOURCES.md](../assignment-3/SOURCES.md).
- **The course's test wrapper**, `scripts/run-test.sh`:
  - from the assignment's "Build It" section, changed in four places for this folder's two projects (commit `cca08046`);
  - the changes are listed at the top of the script.

## People

- **Shuai Zhang (me):** asking for each step; reviewing and approving the change brief; deciding when to commit.
- No other collaborators. No one else has looked at the work.

## Tools

| Tool | Version | Used for |
|---|---|---|
| Claude Code (desktop app), model Claude Opus 5.5 | 2.1.302 | Reading the assignment against my project; step 0 (the copy, the `.gitignore` exception, the wrapper, the imports and the baselines); drafting CHANGE-BRIEF.md, including the colour line, the predicted values and the short answers; drafting this file and FRICTIONAL.md |
| Godot | 4.7.2.stable.official.ed1daf0bf, the standard build | The imports and the headless baselines |
| GNU coreutils `timeout` (Homebrew) | 9.12 | The wrapper's time limit |
| Python 3 with Pillow | 3.13.5, Pillow 10.4.0 | Reading the heart textures' texels, the `.glb` headers and an Assignment 2 screenshot; computing the brief's predicted values and contrast ratios, with a short script kept outside the repository |
| jq | 1.7.1 | Reading the result event of a `claude -p` transcript |
| Git | 2.51.0 | Version control; `git archive` for the copy |

`/opt/homebrew/bin/godot` is a two-line shim to the app's binary, so that `godot` is on my PATH. Claude installed it on 2026-10-24; it is outside the repository.

## Textures

Chosen in CHANGE-BRIEF.md, not downloaded yet:

- **Rock 01** (`rock_01`) from Poly Haven, by Rob Tuytel, CC0 (https://polyhaven.com/a/rock_01).
  - Files: the 1k diffuse, `_nor_gl`, `_nor_dx` (calibration only) and roughness PNGs.
  - When the files are added, `godot/assets/textures/rock_01/ATTRIBUTION.md` will record the URLs, the author and role, the licence, the date checked, and the normal-map convention used.

## Colour sources

| Colour | Value | Source |
|---|---|---|
| The hearts' tint, `tint_color` | `Color(0.6, 0.88, 1.0)`, `#99E0FF` | `game/content/level_1/waystone.gd` line 19, `GLOW`, the lit waystone's glow |
| The waystone's Stone and the circle's DarkStone, as imported | `#8C8A80`, `#4A4440` | Assignment 3's brief, checked by `godot/tests/check_props.gd` |
| `albedo_tint` in `circle_darkstone.tres` | `#8F857D` | A starting value Claude proposed in the brief, to be set in the sweep |

## Human / AI contributions

| Part | Claude | Me |
|---|---|---|
| Reading the assignment | Read it against my two projects and the course's chapters. Found the existing checks that rule out a new material on Rudy and the props; the check that rules out Use External; the wrapper's three problems; and that the Assignment 4 branch must not be the base | Asked for the step-by-step plan |
| Step 0 | Branched from `a3`; copied both projects; found and fixed the `*.wav` ignore; adapted the wrapper; imported both projects; ran the baselines; installed the `godot` shim | Asked for it; held the commits until the brief was reviewed; asked for the shim |
| CHANGE-BRIEF.md | Drafted all of it: the design (the hearts, the invulnerable window, Rock 01, overrides rather than Use External), the rules, the colour line, the predicted values, the contrast check that moved `tint_strength` from 0.6 to 0.4, and the short answers | Asked for the full draft; reviewed it and found no problems; approved the commit |
| The colour line | Suggested `COLOR.rgb = mix(COLOR.rgb, tint_color.rgb, tint_amount * tint_strength);` | Will type it into the shader myself |
| Documents | Drafted this file and FRICTIONAL.md from our conversation | Will check them against what I did |
