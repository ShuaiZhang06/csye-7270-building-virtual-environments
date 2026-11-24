# PROJECT-BRIEF — Walker Rudy: all six levels

Shuai Zhang · CSYE 7270, Assignment 8 · draft 3, 2026-11-23; the target role and the font's licence updated 2026-11-24

*Drafted by Claude Code (Claude Opus 5.5) from my answers of 2026-11-20, 2026-11-22 and 2026-11-23, my Assignment 4 GDD and this repository's records; I review it and make every decision. The rule below: past tense only for what exists and can be shown; everything else is "will". "Designed" means it exists only in my GDD.*

**Stack.** Godot 4.7.2 (standard build), GDScript, the GL Compatibility renderer, Claude Code. Export target: **Web** (HTML5 on WebGL 2), which needs the Compatibility renderer the game already uses.

## The game in brief

**What is the game?** *Walker Rudy: The Long Way Home.* The player runs, jumps and stomps through six side-scrolling levels as Rudy, a ten-year-old mage, and fights with a sword and shield up close or a magic staff from range.

**What is the goal?** Each level is won by reaching the teleport circle at its end; the game is won by defeating the archmage Aldric Voss at the end of Level 6 and freeing Rudy's family. Nothing ends the game: losing the last heart starts the level over from its opening. A side goal is to find the four lost villagers, one in each of Levels 2–5, for a golden heart each.

**One picture.** Level 1 as it runs at tag `a7`, captured from the game. It is the only level that runs; every picture of Levels 2–6 is a code-drawn blockout from my GDD, labelled *constructed*.

## The whole game, as designed

My GDD ([GDD.md](GDD.md); v1 was Assignment 4, 2026-10-19) designs six levels. A ten-year-old mage, Rudy, is thrown across the world by a failed ritual and walks home. Only Level 1 is built.

| # | Level | What it adds | Status |
|---|---|---|---|
| 1 | Harvest Fields | run, jump, stomp, spikes, cliffs, the sword; about 13 s at full speed | **Built** |
| 2 | The Ashen Reach | the thorn-back beetle, which cannot be stomped; crumbling ledges; the first health pack; the miller; 2–3 min | Designed |
| 3 | Giant Wood to the dunes | mushrooms and the shield block; swaying vines; quicksand; sand scorpions; the shepherd girl; 3 min | Designed |
| 4 | The port and the crossing | the magic staff; goblin archers; climbing ropes and rigging across two ships; the baker's boy; 3 min | Designed |
| 5 | The border mountains | an avalanche chase; shield guards in the border fortress; the blacksmith; 3–4 min | Designed |
| 6 | Ambervale, after | the boss, Aldric Voss, in three phases; 3 min | Designed |

Around the levels the GDD also designs 14 painted story cards, a 3D world map, a title menu and saving.

## 1. What is it?

Walker Rudy is a 2D platformer about a boy walking home across the world. The final project will make **all six levels of my GDD** playable in order, from the title screen to an end screen after the boss. When it is done, it will be the whole game as designed, without its story cards and world map, **exported to Web**: six levels, the shield block and the magic staff, five new kinds of enemy and a boss in three phases, a title menu that can continue a saved game, and its source at the final tag with a test report a stranger can rerun from a clean clone.

## 2. Why would anyone care?

**What makes it special.** Every rule I claim for it will come with a test the reader can rerun on the same build they play.

**What it gives the player.** Six short levels, each adding one or two new ideas: first shown in a safe place, then mixed with the old ones. Rudy can jump past an enemy, stomp it, or cut it down with the sword, and a hit knocks his gear away before it costs a heart. Later he has to read tells, such as a mushroom's cap swelling before it shoots or an archer drawing its bow, and choose between the sword and shield up close and the staff from range. Level 6 ends in a fight with Aldric Voss in three phases.

**What makes it different.** I have played *Super Mario Bros.* and *New Super Mario Bros.* Walker Rudy borrows their rule that a hit takes your power-up before it takes you. It differs in two ways. First, it has an up-close sword whose swing is committed: no new swing starts until the last one ends. Mario's attacks are mainly the stomp and power-ups such as the fireball. Second, it has no lives: losing the last heart restarts the level, and there is no Game Over screen, while both Mario games count lives down to a Game Over. So: *it gives a player who knows Mario six levels they can learn in a few tries, where fighting up close is a choice beside the stomp and a mistake never ends the game, which Super Mario Bros. and New Super Mario Bros. do not.*

## 3. Who opens it, and what do they do with it?

**Target role:** gameplay programmer (confirmed by me on 2026-11-23, when I approved the film's narration). **Reader:** my instructor and the TAs. They open it as a player, and as a reviewer judging whether the scope fits one person. In the first sixty seconds they will open the README, follow its link to the Web build and reach the title screen. Today that screen says "Press Enter to start" and shows no controls, so the final will add a one-line controls hint. After that they will be playing without reading anything else. Where the build will be hosted is not decided yet. It will be either a private page or the course media storage with a one-line local server, and the README will say which.

## 4. What does it prove about me?

- **Shaders and materials.** The hearts' invulnerable tint shader, which I wrote from my brief (a5). It will be checked again under WebGL 2.
- **Particle effects.** Slash sparks and a dust trail, with configuration and state tests and eight mutations that fail them (a6).
- **Animation and state.** A sprite-sheet run cycle and a cut-out slash rig in an AnimationPlayer, checked by a pinned behaviour test, a state test and an edge test (a7). The block, the staff and climbing will add states, each with its own edge tests.
- **Profiling.** A headless CPU price on an Apple M3 (a6): about 0.05 ms per frame for the game, under 0.01 ms more for each effect. GPU time read 0.0 ms on this Mac, so it was not measured. The final will report the Web build's frame time, measured in a named browser on that machine.
- **Verification habits.** Pinned behaviour before a change, headless checks, human checks I record in my own words, and scoped `claude -p` sessions with allow-lists.

A reviewer could fairly conclude that I can direct an agent to build gameplay in Godot and prove it with tests anyone can rerun. They should not conclude that I wrote all of the code by hand. Claude Code sessions that I scoped and reviewed wrote most of it, and SOURCES.md in each assignment says who did what.

## 5. What is in, what is out, what comes first?

**I am proposing the whole design on purpose,** so that the reviewer can judge its size. If it is too much, the cut order below says what goes first. If it is too little, the first thing to add back is the story cards.

- **In:** all six levels as the GDD designs them, played in order, with Level 1 as built; the beetle, the mushroom, the sand scorpion, the goblin archer, the shield guard and the boss; the shield block, the magic staff and climbing; crumbling ledges, swaying vines, quicksand and the avalanche chase; the four lost villagers and their golden hearts; sword and staff stands, waystones and health packs; a title menu (New journey, Continue) and a pause menu (Resume, Restart level, Title); saving; the Web build; the test report.
- **Out, deliberately:** the 14 painted story cards and the 3D world map. Between levels, the "Level complete" card will show the level's time and whether its villager was found, and Enter will start the next level. All six levels will use Level 1's music.
- **Cut order, if it will not fit:** first, any level whose art is late ships as a playable greybox, labelled as one; then the four villagers and their golden hearts; then whole levels from the end: Level 6, then 5, then 4. Levels 1–3 are the floor.

**First:** Level 2 as a greybox, playable straight after Level 1's end card, with the beetle and the crumbling ledges working before any new art exists. Anyone will know it ran because a headless test will walk Rudy from Level 1 into Level 2 and check the GDD's rules (a stomp on the beetle hurts Rudy; a ledge cracks 0.6 s after he lands, falls at 1.0 s and is back after 3 s), and a captured run will show the same. Levels 3 to 6 follow as greyboxes, in order, before any of them gets new art.

## 6. What could sink it?

**The art for five new levels.** By my GDD's own lists, Levels 2–6 need 15 new background layers (three per level), sprites for five new kinds of enemy and the boss, Rudy's staff and climbing frames, four villagers and their props, all generated under Assignment 2's rules. The GDD already found two weak spots in the planned palettes: Rudy's outline against Level 3's dark canopy has a contrast of only 1.87, and against Level 2's dead wood 2.00. What I will do: make all six levels playable as greyboxes before any new art, so play never waits for art; then add the art one level at a time, in order, running the GDD's contrast check on each generated layer; and follow the cut order above if it runs late. A second risk, the Web export (the templates are about 1.3 GB, and nothing has run on WebGL 2), is checked early by exporting today's Level 1 before Level 2 is finished.

## 7. Why this project?

Mostly to learn. None of the course's skills (Godot and GDScript, shaders, particles, animation and state, testing and profiling) were mine before this semester. What I have of them now was learned here, and each has a tag: a5, a6, a7. The final adds things that are new to me: building levels from a greybox, enemies that decide for themselves, a boss fight, menus, saving, and a Web export. For the game AI I do not know the technique yet. I will choose it in Assignment 9, and my first candidate is a state machine for the sand scorpion (buried, emerging, chasing), because it decides for a character the player does not control and its tell is readable.

## Appendix: is this realistic?

**What exists today?** The table below, each with the tag or commit where it can be seen. The film shows Level 1 as real captured play from tag `a7`.

**What have I started but not finished?** Rudy's shield-block frame was generated in Assignment 2 but is shown nowhere in play. Levels 2–6 exist only as the GDD's text and code-drawn blockouts. No code for them has been started.

**What have I not started?** Everything in "Will exist" below.

**Can one person build this by the final?** I am not sure, and that is why I am proposing all of it: so the reviewer can judge its size before I build it. If it will not fit, I will cut in the order given in question 5, and Levels 1–3 are the floor.

**Where does each asset come from?**

| Asset | Where it will come from | Made, generated, free or bought | Licence |
|---|---|---|---|
| Rudy's frames, default and with the sword (exist) | Gemini app image generation, Assignment 2 | generated | Google Terms of Service and Generative AI Additional Terms |
| Rudy's staff and climbing frames, and the block in play | Gemini app image generation, under Assignment 2's rules | generated | Google Terms of Service and Generative AI Additional Terms |
| Rudy's run cycle and slash rig (exist) | made by code from my own generated frames, Assignment 7 | made | mine; the frames under Google's terms |
| Animations for the block, staff, climbing, the new enemies and Voss | AnimationPlayer clips made the same way as Assignment 7's | made | mine; the frames under Google's terms |
| Level 1's backgrounds, props, goblin, end card and hearts (exist) | Gemini app image generation, Assignment 2 | generated | Google Terms of Service and Generative AI Additional Terms |
| Levels 2–6: 15 background layers, five new enemies, Voss, four villagers, stands, golden heart, health pack, ledges, ropes, avalanche | Gemini app image generation, under Assignment 2's rules | generated | Google Terms of Service and Generative AI Additional Terms |
| Greybox shapes | drawn by code in Godot | made | mine |
| Sound effects (exist): jump; stomp, hurt, portal, slash, pickup | Adobe Firefly (jump); ElevenLabs (the rest), Assignment 2 | generated | Adobe General Terms and Generative AI User Guidelines; ElevenLabs free plan, non-commercial, with "elevenlabs.io" in the title of anything published with them |
| New sound effects for the new enemies, the staff and Voss | the same two services, under Assignment 2's rules | generated | as above |
| Music, all six levels (exists) | Suno, MUS-LOOP-01, Assignment 2 | generated | Suno free plan: personal, non-commercial use; Suno keeps the rights |
| The hearts' tint shader (exists) | my own, Assignment 5 | made | mine |
| Slash sparks and dust trail (exist) | my own, Assignment 6 | made | mine |
| Font | Open Sans SemiBold, Godot's built-in default font, compiled into the engine; the game ships no font file and sets no theme font | free, with the engine | SIL Open Font License 1.1 (Godot 4.7.2's own copyright list, read 2026-11-24; SOURCES.md) |
| 3D models | none: the Assignment 3 props were for the world map, which is out | — | — |

Nothing will be bought. The full terms and generation records are in Assignment 2's SOURCES.md and ASSET-LOG.md.

## Exists today

| What | Where it can be seen |
|---|---|
| Level 1, playable on macOS: title over the opening, three goblins, two spikes, two cliffs, the sword pickup, the waystone, the teleport circle, the "Level complete" card, pause, hearts, music and six sound effects | Built in Assignment 2 (branch `shuai-z/assignment-2`, `d0bf3eaa`); as it is now: tag `a7` (`76206412`) |
| Rudy's shield-block frame, generated but shown nowhere in play | `game/content/rudy/frames/CHAR-SWORD-BLOCK.png` at tag `a7` |
| Three 3D props (waystone, teleport circle, spikes); not used by the 2D game | tag `a3` (`f11998f7`) |
| The hearts' invulnerable tint shader, written by me, with 15 checks at 30, 60 and 144 fps | tag `a5` (`9bd96c5a`) |
| Slash sparks and dust trail, their tests, eight mutations, and the headless CPU price on an Apple M3 | tag `a6` (`8cc03ed6`) |
| Run cycle and slash rig in an AnimationPlayer; pinned test (20 checks), clip read-back (51), states (99), edges (108 at 60 fps, 66 at 30), four mutations, tuning log; fresh-clone check passed on 2026-11-18 | tag `a7` (`76206412`) |
| The game design document: v1, 24 pages, with blockouts of Levels 2–6 drawn by code; v2, the same design in the GDD tool's sections, with the final's scope | v1 submitted on Canvas, 2026-10-19; v2 is [GDD.md](GDD.md) in this folder, at tag `a8` |

What does **not** exist today: Levels 2–6, any new enemy, the boss, the block, staff or climbing in play, the villagers, a menu, any saving, an export preset and any Web build.

## Will exist

1. Level 2, The Ashen Reach: grey goblins, the beetle, crumbling ledges, the first health pack, the miller.
2. Level 3, Giant Wood to the dunes: mushrooms and their spores, swaying vines, quicksand, sand scorpions, the shepherd girl.
3. Level 4, The port and the crossing: the first staff stands, goblin archers, climbing ropes and rigging across two ships, the baker's boy.
4. Level 5, The border mountains: the avalanche chase (the screen scrolls on its own at 480 px/s), shield guards in the fortress, the blacksmith.
5. Level 6, Ambervale, after: a short approach, then Aldric Voss in three phases (24 health; amber volleys; shards and spike lines; the floor crumbling under a sweeping beam).
6. Rudy's new moves: the shield block (hold K or C), the magic staff and its bolt, climbing; each a state in his state machine, with edge tests.
7. Golden hearts from the four villagers: with all four, Rudy has 7 hearts.
8. The six levels played in order; a title menu with New journey, Continue and a controls hint; a pause menu with Resume, Restart level and Title; the "Level complete" card showing the level's time and its villager.
9. Saving to `user://`, under rules written before the code: the levels completed, each level's best time and the villagers found, tested to survive a restart.
10. One enemy driven by my Assignment 9 game-AI technique, with its tests.
11. A Web build (`export_presets.cfg`, the package's SHA-256, played in a browser) with its frame time measured on a named machine and browser; or, if it fails, the exact blocker and a macOS build.
12. A test report a stranger can rerun from a clean clone of the final tag.
