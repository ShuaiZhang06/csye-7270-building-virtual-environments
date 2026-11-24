# FACTCHECK — Walker Rudy: The Long Way Home. A Final Project Pitch

Every claim the narration makes, with where it comes from. Claude Code (Claude Opus 5.5) checked each row against the files named, on 2026-11-23, at my request; the narration is in `beat_sheet.json` (written by `tools/make_sheet.py`).

Status: checked 2026-11-23 by Claude Code for Shuai Zhang; reviewed by Shuai Zhang: not yet, row by row. I watched the finished film on 2026-11-24 and found no problem.

How to read the verdicts:
- **PASS:** the claim matches its source.
- **CORRECTED:** the narration was changed to match the source.
- **EXEMPT:** an opinion, a definition or a title, nothing to check.

Design claims ("will", "designed") are checked against the design document, not against the game. Their source is GDD.md v2 (2026-11-23), in this folder.

| # | Beat | Claim (as spoken / shown) | Verdict | Source / derivation | Fix |
| --- | --- | --- | --- | --- | --- |
| 1 | BIDEA | One level exists; I am proposing all six | PASS | The game at tag `a7` has one level (`assignment-7/game/content/level_1/`); GDD.md §7 designs six | — |
| 2 | B00 | The design document is version two, dated November the twenty-third | PASS | GDD.md §0 | — |
| 3 | B00 | Read by a synthetic voice from a script Claude Code drafted with me | PASS | `beat_sheet.json` metadata (Kokoro am_onyx; drafted_by) | — |
| 4 | BDEFS | Built, designed, greybox: what each word means in this film | EXEMPT | Definitions | — |
| 5 | B01 | A side-scrolling platformer; as Rudy you run, jump, stomp and fight with a sword | PASS | `a7` `content/rudy/rudy.gd`; take `run` frames 0–303 show each (CAPTURE.md) | — |
| 6 | B01 | This is level one at tag A7, played by a script | PASS | CAPTURE.md: take `run` at `a7`, input pressed by `capture/film_driver.gd` | — |
| 7 | B02 | Each level ends at a teleport circle | PASS | `a7` `app/main.gd` (`_on_portal_reached`); take `run` frame 425 | — |
| 8 | B02 | Beating the archmage Aldric Voss in level six wins the game | PASS | GDD.md §"The game in brief" and S-05 (designed) | — |
| 9 | B02 | Losing your last heart only restarts the level | PASS | `a7` `app/main.gd` (`_die`, `_back_to_the_opening`); take `pause` frames 276–331 | — |
| 10 | B03 | The final will be all six levels, title menu to end screen, a web export with a test report anyone can rerun | PASS | GDD.md §12 (F-list); PROJECT-BRIEF.md question 1 | — |
| 11 | B04 | Four pillars: gear is your plan, read every threat, it stings then you try again, a journey into another world | PASS | GDD.md §1, P1–P4 | — |
| 12 | B05 | Second to second: jump, stomp or fight; over a level: gear and detours; the next region pulls you on | PASS | GDD.md §2 | — |
| 13 | B06 | The player should feel warned in time before every attack, and stung but ready to retry after a mistake | PASS | GDD.md §3, PX-02 and PX-03; wording approved by me on 2026-11-23 | — |
| 14 | B06 | I will check both in playtests, with the sound on and off | PASS | GDD.md §3, PX-02 ("my playtest, muted") and PX-03 | — |
| 15 | B07 | A slash cannot restart until it ends | PASS | `a7` `rudy.gd`: a new swing needs `not is_slashing()` | — |
| 16 | B07 | A hit knocks the sword away before it costs a heart | PASS | `a7` `rudy.gd` `take_hit`; take `mech` frames 363 and 399 | — |
| 17 | B07 | A fall returns Rudy to the last waystone | PASS | `a7` `main.gd` (`_on_waystone_activated`, `_die`); take `mech` frames 451–489 | — |
| 18 | B07 | Block, staff and climbing are designed, not built | PASS | GDD.md §4 (M-table status column) | — |
| 19 | B08 | Gear protects your hearts; waystones keep your place | PASS | `a7` `rudy.gd` `take_hit`; `main.gd` checkpoint | — |
| 20 | B08 | Every enemy shows a tell before it attacks | PASS | GDD.md P2 and S-04 (designed) | — |
| 21 | B08 | One enemy will run on my game AI technique from Assignment nine | PASS | GDD.md Q-05; PROJECT-BRIEF.md (plan) | — |
| 22 | B09 | The block in level three, the staff and ropes in level four, hearts from three to seven | PASS | GDD.md §6 table; S-02 ("3 hearts at the start … up to 7") | — |
| 23 | B10 | Rudy's village is in a farming kingdom across the sea from a grey continent of ash, forest and desert; six regions | PASS | GDD.md §7 and figure 4 | — |
| 24 | B11 | Level one has three goblins, two sets of spikes, two cliffs, the sword and a waystone | PASS | `a7` `content/level_1/level_1.tscn` (GoblinA–C, SpikesA–B, three ground segments, SwordPickup, Waystone) | — |
| 25 | B11 | About thirteen seconds at full speed | CORRECTED | CAPTURE.md: 12.65 s from Enter to the circle. The GDD said "about 30 s"; GDD.md, the brief and this beat now say about 13 s | was "about thirty seconds" |
| 26 | B12 | Levels two to five add a beetle and falling ledges; mushrooms, scorpions and quicksand; archers, ropes and the staff; shield guards and an avalanche | PASS | GDD.md §7, Levels 2–5 | — |
| 27 | B13 | Level six is home; Voss fights in three phases; every attack glows before it lands | PASS | GDD.md S-05 and figure 2 | — |
| 28 | B14 | Fourteen painted story cards between levels in the design; they are out | PASS | GDD.md §8 and §13 | — |
| 29 | B15 | Rudy is ten, a gifted mage only fair with a sword; his frames are generated | PASS | GDD.md §9 and figure 6; Assignment 2 SOURCES.md (Gemini) | — |
| 30 | B15 | Voss, and four lost villagers along the way | PASS | GDD.md §9 | — |
| 31 | B16 | Flat, outlined characters on soft painted backgrounds | PASS | GDD.md §10 | — |
| 32 | B16 | Two planned colours sit close to Rudy's outline (on screen: canopy 1.87, dead wood 2.00) | PASS | GDD.md §10 table; recomputed 2026-11-23: WCAG contrast of `#3A2A24` against `#3F5E3A` is 1.87 and against `#5E5A55` is 2.00 | — |
| 33 | B17 | A folk theme from Suno | PASS | GDD.md §11 (MUS-LOOP, Suno v6 mini; "a small folk ensemble") | — |
| 34 | B17 | Six sound effects from Adobe Firefly and ElevenLabs, each with a visual twin | PASS | GDD.md §11: six built SFX (JUMP, STOMP, HURT, PICKUP, SLASH, PORTAL), each with a visual column; Assignment 2 SOURCES.md line 52 (Firefly for SFX-JUMP, ElevenLabs from SFX-STOMP on) | — |
| 35 | B18 | Musts: levels 1–3, block, menus, saving, web build, test report; should: levels 4–6, staff, climbing, boss; could: villagers, finished art | PASS | GDD.md §12 (F-01–F-19 tags) | — |
| 36 | B18 | The musts are the smallest complete final | PASS | GDD.md §12, "The smallest version of the final is the musts" | — |
| 37 | B19 | Out: the painted story cards, the three-D world map, new music for each region | PASS | GDD.md §13 | — |
| 38 | B20 | Godot 4.7.2, the Compatibility renderer, a web export at sixty frames a second, every level a greybox before its art | PASS | GDD.md §14; `a7` `project.godot` (gl_compatibility) | — |
| 39 | B21 | The risk is art: fifteen backgrounds, sprites for five enemies and the boss | PASS | GDD.md R-01 and §10 ("15 background layers, five new enemies, Voss") | — |
| 40 | B21 | Every level will play as a greybox first; the web export tested early, on level one | PASS | GDD.md R-01 and §14; PROJECT-BRIEF.md question 6 | — |
| 41 | B22 | Open: do seven hearts make the boss too easy; how the staff's barrier differs from the shield; where the web build will be hosted | PASS | GDD.md Q-01, Q-02, Q-04, each with how it will be found out | — |
| 42 | B23 | I have played Super Mario Bros. and New Super Mario Bros. | PASS | My answer of 2026-11-22 (FRICTIONAL.md) | — |
| 43 | B23 | In those games a hit takes your power-up first | PASS | Both games' rules: a hit to Super or Fire Mario shrinks him instead of costing a life | — |
| 44 | B23 | Walker Rudy keeps that, adds a committed sword swing, and has no lives to lose | PASS | `a7` `rudy.gd` (`take_hit`, the swing that cannot restart); GDD.md M-11 (no lives: the level starts over) | — |
| 45 | B24 | It is for my instructor and the teaching assistants; the target role is gameplay programmer | PASS | PROJECT-BRIEF.md question 3; target role approved by me on 2026-11-23 | — |
| 46 | B24 | Within a minute you will follow the read-me's link to the web build and be playing | PASS | PROJECT-BRIEF.md question 3 (plan); GDD.md Q-04 | — |
| 47 | B25 | A shader I wrote, particle effects, animation states, each at its tag with tests anyone can rerun | PASS | Tags `a5`, `a6`, `a7` exist in this repository; each assignment's README and test logs | — |
| 48 | B25 | Claude Code sessions I scoped and reviewed wrote most of the code, as the sources file shows | PASS | Assignments 5–7 SOURCES.md and their "who did what" records | — |
| 49 | B26 | First comes level two as a greybox after level one's end card; a headless test walks Rudy in and checks the ledge timings | PASS | PROJECT-BRIEF.md question 5 (plan) | — |
| 50 | B27 | Mostly to learn; none of these skills before this semester | PASS | My answer of 2026-11-22 (FRICTIONAL.md) | — |
| 51 | B27 | New in the final: greybox levels, enemies that decide for themselves, a boss, menus, saving, a web export | PASS | PROJECT-BRIEF.md question 7; GDD.md §12 | — |
| 52 | B28 | What exists today is level one at tag A7, all the play in this film | PASS | CAPTURE.md: every clip is from the `a7` takes | — |
| 53 | B28 | Rudy's block frame is generated but not in play | PASS | GDD.md figure 6 caption ("Nothing in play shows the block frame yet") | — |
| 54 | B28 | Levels two to six are not started | PASS | `a7` has only `content/level_1/`; PROJECT-BRIEF.md "Exists today" | — |
| 55 | B29 | If it won't fit: late art becomes greybox, then villagers go, then levels six, five and four; one to three are the floor | PASS | PROJECT-BRIEF.md question 5 (cut order); GDD.md §12 | — |
| 56 | B29 | I'm not sure one person can build all of this by the final | EXEMPT | My own judgment (PROJECT-BRIEF.md appendix) | — |
| 57 | B30 | Images from Gemini, sound from Firefly and ElevenLabs, music from Suno, all generated | PASS | Assignment 2 SOURCES.md lines 31–36 and 52 (in-game images from Gemini; three rejected frames from ChatGPT are not in the game) | — |
| 58 | B30 | The shader and effects are mine | PASS | "Mine" in the asset table's sense (made for this game, licence: mine). The `a5` shader was written by hand by me; the `a6` effects were built for my game by Claude Code sessions I directed (Assignment 6 SOURCES.md), and B25 says so | — |
| 59 | B30 | Nothing is bought | PASS | No asset was bought: every asset is made or generated (PROJECT-BRIEF.md asset table). The Gemini app ran on a paid plan (Assignment 2 SOURCES.md line 55), which is a tool subscription, not a bought asset | — |
| 60 | B30 | Every licence is in the sources file | PASS | Assignment 2 SOURCES.md, "Terms" column for each model; this folder's SOURCES.md repeats them, and adds the fonts' and the voice model's (2026-11-24) | — |
| 61 | BOUT | The title, and my name | EXEMPT | Title | — |

**On screen, besides the narration:**
- Every play clip says `Level 1 · tag a7 · scripted input` (B11 adds `2× speed`).
- Every figure says whether it is built, designed, generated, or constructed (drawn by code).
- The status lines were taken from GDD.md's figure captions.
