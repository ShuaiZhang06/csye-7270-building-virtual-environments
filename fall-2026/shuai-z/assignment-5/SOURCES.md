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

- **Shuai Zhang (me):** asking for each step; reviewing and approving the change brief; writing the shader from code; deciding when to commit.
- No other collaborators. No one else has looked at the work.

## Tools

| Tool | Version | Used for |
|---|---|---|
| Claude Code (desktop app), model Claude Opus 5.5 | 2.1.302 | Reading the assignment against my project; step 0 (the copy, the `.gitignore` exception, the wrapper, the imports and the baselines); drafting CHANGE-BRIEF.md, including the colour line, the predicted values and the short answers; running the scoped CLAUDE.md session, then checking and reviewing its draft; the guide and the checks for the shader from code; the probes in `evidence/headless-probe/`; drafting this file and FRICTIONAL.md |
| Claude Code (command line, `claude -p`), model `claude-opus-5-5` | 2.1.302 for the run that could not log in, 2.1.310 for the draft | The scoped session that drafted CLAUDE.md (`sessions/prompt-1.txt`, `sessions/session-1.jsonl`) |
| Godot | 4.7.2.stable.official.ed1daf0bf, the standard build | The imports, the headless tests and the probes |
| GNU coreutils `timeout` (Homebrew) | 9.12 | The time limit in the wrapper and the probe runs |
| Python 3 with Pillow | 3.13.5, Pillow 10.4.0 | Reading the heart textures' texels, the `.glb` headers and an Assignment 2 screenshot; computing the brief's predicted values and contrast ratios, with a short script kept outside the repository |
| jq | 1.7.1 | Reading the result event of a `claude -p` transcript |
| Git | 2.51.0 | Version control; `git archive` for the copy, and for the temporary copies in `evidence/headless-probe/import_check.sh` |

`/opt/homebrew/bin/godot` is a two-line shim to the app's binary, so that `godot` is on my PATH. Claude installed it on 2026-10-24; it is outside the repository.

## Textures

Chosen in CHANGE-BRIEF.md, not downloaded yet:

- **Rock 01** (`rock_01`) from Poly Haven, by Rob Tuytel, CC0 (https://polyhaven.com/a/rock_01).
  - Files: the 1k diffuse, `_nor_gl`, `_nor_dx` (calibration only) and roughness PNGs.
  - When the files are added, `godot/assets/textures/rock_01/ATTRIBUTION.md` will record the URLs, the author and role, the licence, the date checked, and the normal-map convention used.

## Colour sources

| Colour | Value | Source |
|---|---|---|
| The hearts' tint, `tint_color` | `Color(0.6, 0.88, 1.0)`, `#99E0FF` | `game/content/level_1/waystone.gd` line 19, `GLOW`, the lit waystone's glow. It is the uniform's default in `game/shaders/invulnerable_tint.gdshader` line 4 |
| The waystone's Stone and the circle's DarkStone, as imported | `#8C8A80`, `#4A4440` | Assignment 3's brief, checked by `godot/tests/check_props.gd` |
| `albedo_tint` in `circle_darkstone.tres` | `#8F857D` | A starting value Claude proposed in the brief, to be set in the sweep |

## Human / AI contributions

| Part | Claude | Me |
|---|---|---|
| Reading the assignment | Read it against my two projects and the course's chapters. Found the existing checks that rule out a new material on Rudy and the props; the check that rules out Use External; the wrapper's three problems; and that the Assignment 4 branch must not be the base | Asked for the step-by-step plan |
| Step 0 | Branched from `a3`; copied both projects; found and fixed the `*.wav` ignore; adapted the wrapper; imported both projects; ran the baselines; installed the `godot` shim | Asked for it; held the commits until the brief was reviewed; asked for the shim |
| CHANGE-BRIEF.md | Drafted all of it: the design (the hearts, the invulnerable window, Rock 01, overrides rather than Use External), the rules, the colour line, the predicted values, the contrast check that moved `tint_strength` from 0.6 to 0.4, and the short answers | Asked for the full draft; reviewed it and found no problems; approved the commit |
| CLAUDE.md | The scoped `claude -p` session drafted it: 82 lines, committed unedited (`dfeca3fb`). Claude, in our conversation, ran that session twice (the first could not log in), checked the draft, and reviewed it with two probes; the reviewed version has 91 lines (`c095e9de`) | Logged the command-line `claude` in; asked for the run and the review; approved both commits |
| The shader from code, `game/shaders/invulnerable_tint.gdshader` | Specified it in the brief: the file, the three uniforms' names, types, hints and defaults, and the colour line. Listed what to prepare and how to check it; wrote `probe_shader.gd` and `import_check.sh`; ran the checks | Wrote it from the brief and committed it on its own (`ae0a3757`) |
| The colour line | Suggested `COLOR.rgb = mix(COLOR.rgb, tint_color.rgb, tint_amount * tint_strength);` in the brief | Typed it into the shader, line 8 |
| Documents | Drafted this file and FRICTIONAL.md from our conversation | Will check them against what I did |
