# FRICTIONAL — walker-rudy

A dated log of the design as it happened: what I wanted, what I asked for, what came back, and what I decided.

**How this file is written.** Claude Code drafts each entry from our Claude Code conversation, and I check it against what I actually said and decided. My reasons are translated from the Chinese chat. Where I gave no reason, the entry says so instead of inventing one. Each entry says when it was written.

**Tools and roles so far.** Claude Opus 5.5 in Claude Code (desktop app) asked the design questions and drafted the documents in English. I made the design decisions. No image, sound or music model has been used yet.

---

## 2026-09-29 — Choosing the game

*Written on 2026-09-30, from the conversation.*

- **Wanted:** to make the game I actually want this semester: a 2D side-scroller started from scratch, not a continuation of walker-link (Assignment 1).
- **My idea, as I first wrote it (translated):** reach the finish by getting past every obstacle on the way. By default the hero can run, jump, attack and defend. One pickup gives a sword and shield (melee attack and defense); another gives a magic staff (ranged attack and defense). Obstacles include, but are not limited to, cliffs, spikes and small monsters that attack. Three hearts; touching a monster or getting hurt costs one. Some monsters only move; others stay in place and shoot at the hero. Health packs restore hearts. The hero is a blond boy whose hair is neither long nor short. The style is a medieval other-world fantasy.
- **Asked:** Claude whether this was enough for CONCEPT.md, what I should clarify or add, and how Walker's `/gdd` works.
- **Got:**
  - The mechanics were enough, but CONCEPT also needs pillars, the decision the player makes each time, and art and audio direction. Claude listed 12 questions and offered four candidate pillars.
  - A rights warning: a blond boy with a sword and shield in a medieval setting is close to Link from *The Legend of Zelda*, and my Assignment 1 hero was Link-styled. Prompts must never name him or his game, and Rudy's design must be clearly different.
  - `/gdd` is a specification, not an installed command, in Walker `10fedb8` (the same commit as upstream on 2026-09-29). The usable part is the Zelda prompt, `walker/prompts/zelda-gdd.md`.
- **Decided:** to answer Claude's questions directly instead of running the Zelda prompt.
- **Human / Claude / model:** the idea is mine. The question list, the candidate pillars and the rights warning are Claude's. No generative model was used.
- **Still unresolved:** all 12 questions.

## 2026-09-30 — Answering the questions; CONCEPT draft v1

*Written on 2026-09-30.*

- **Wanted:** rules that make the loop clear, and a look of grounded fantasy. That means a lived-in medieval world with painterly backgrounds and natural, warm, restrained colors, not a high-saturation, effects-heavy other world. My words for it: rustic, lived-in, immersive.
- **Decided (my answers):**
  - **Default form:** I changed my first idea. Without gear Rudy no longer attacks or defends: he dodges by moving or stomps enemies. Claude had asked what the sword and shield would add if the default form could already attack and defend. Later enemies cannot be stomped, and stomping them hurts.
  - **Gear:** the sword-and-shield and the staff are mutually exclusive, and picking up the other swaps them. A hit knocks the gear away first. The staff has no cooldown and attacks "at a fixed rate, like a basic attack".
  - **Blocking:** hold to block, front only. It stops projectiles, but touching a goblin still knocks the gear away. You can move while blocking. Both forms block the same way; only the shield looks different.
  - **Damage:** spikes cost a heart and cliffs kill instantly. There is invulnerability after a hit. At zero hearts you go back to the checkpoint.
  - **Enemies:** ordinary goblins that patrol back and forth and can be stomped, and a stationary enemy that aims at me. Its shots can be blocked but not shot down.
  - **Scope:** I asked whether one level is enough for this assignment; Claude said yes, since the assignment asks only for a small playable scene. Level 1 lasts about 30 seconds, has cliffs, spikes and the two enemy types, and ends at a teleport circle.
  - **Decisions in the loop:** without gear the only goal is to reach the end; with either gear you can defeat enemies. A risky detour for a health pack can be worth it. When attacked, you can block, dodge or fight.
  - **Tone:** a light adventure with forgiving difficulty.
  - **Art:**
    - Anime-style flat (cel) shading.
    - Painterly, detailed backgrounds that feel like oil or watercolor.
    - Careful light: morning sun, sunset, rain, candlelight.
    - Muted, warm, natural colors.
  - **Rudy (still unnamed):** chibi, 2–3 heads tall, a cowlick, green eyes, a grey robe with the hood down, cheerful, no modern object.
  - **Level 1 scene:** a village in autumn with golden fields, by day.
  - **Audio:** I could not describe it beyond "a medieval other-world, exotic feel".
  - **Pillars:** I agreed with Claude's four candidates, with two changes. Enemies need no flash or charge-up sound before firing ("they don't attack often, so they don't need a warning every time"). The distant-castle parallax was dropped for now; I gave no reason.
- **My reference prompt** (to be logged in the asset log when generation starts):

  ```text
  anime style, high-quality TV anime key visual, cinematic composition,
  painterly hand-painted background, detailed watercolor and gouache textures,
  grounded medieval fantasy world, rustic European countryside,
  soft natural lighting, warm golden hour light, atmospheric depth,
  muted natural color palette, low saturation, earthy tones,
  lived-in environment, everyday life details, fine linework,
  expressive character acting, gentle rim light, subtle film grain
  ```

- **Asked:** Claude to turn my answers into CONCEPT.md, in English.
- **Got:** CONCEPT.md draft v1. Claude also:
  - Wrote the audio direction itself: a folk ensemble with no vocals. The music dips on a hurt, keeps going through a respawn, drops in volume on pause, and fades out at the teleport circle.
  - Gave character sprites neutral lighting, so the same sprites work in every level.
  - Flagged a readability risk: blond hair and a grey robe against golden fields and grey stone.
  - Made assumptions:
    - a hit while carrying gear costs the gear, not a heart;
    - the staff fires continuously while the button is held;
    - the shooter is a goblin archer;
    - one sword hit defeats a goblin, while the staff needs two bolts.
  - Left five open questions: health packs, the sword's advantage, the staff form's shield, whether the archer can be stomped, and wheat or rice.
- **Human / Claude / model:** the rules, the look and the character are mine. The English text, the audio direction, the neutral-lighting rule and the assumptions are Claude's. No generative model was used.
- **Trace:** CONCEPT.md draft v1 was never committed; draft v2 replaced it.

## 2026-09-30 — Reviewing draft v1; CONCEPT draft v2

*Written on 2026-09-30.*

- **Wanted:** to correct what draft v1 got wrong and settle its open questions.
- **Decided:**
  - **Names:** the boy is Rudy, and the project is `walker-rudy`.
  - **Level 1 gear:** only the sword and shield; the staff waits for a later level.
  - **P2:** enemy shots get no special color either. It only has to be obvious that an enemy is attacking.
  - **P4:** back to the distant castle. I removed the everyday village details from the background, because fighting monsters in front of them felt odd to me.
  - **Staff:** one press, one attack. Claude had misread "a fixed rate, like a basic attack" as firing while the button is held.
  - **Ranged enemy:** a monster, not an ordinary archer, and not necessarily a goblin. It can be stomped.
  - **Health:** current hearts carry into the next level. A pack does nothing at full health. A golden pack that raises the maximum comes later.
  - **Sword vs. staff:** the sword defeats a goblin in one hit; the staff needs two.
  - **Staff-form defense:** a magic barrier.
  - **Fields:** wheat, not rice.
  - **Rudy's hair:** not pure gold, more yellow.
  - **Background:** yellow wheat meeting green.
- **Kept as Claude wrote them** (I did not change these in this review): the audio direction; neutral lighting for character sprites; a hit while carrying gear costs the gear, not a heart.
- **Got:** CONCEPT.md draft v2. Its only open question is which monster shoots, and what it shoots.
- **Next:** STORYBOARD.md and CHARACTER-SHEET.md, based on the assignment's templates, then CHANGE-BRIEF.md. Once all four are done, that commit is tagged `design-v1`, before the first generation.
- **Human / Claude / model:** every decision above is mine; Claude revised the text. No generative model was used.
- **Still unresolved:**
  - the ranged monster;
  - Rudy's on-screen size and the game's resolution;
  - his exact palette;
  - who draws the storyboard and character-sheet pictures.

## 2026-09-30 — Storyboard, character sheet and slice decisions

*Written on 2026-09-30.*

- **Wanted:** to settle what the storyboard and character sheet need, so the last three design documents could be drafted, and a plan that fits the deadline.
- **Decided:**
  - **GitHub:** the public repository is created only when everything is finished. The local repository was created today (commit `6095d0f`).
  - **Checkpoint:** a waystone, as Claude suggested.
  - **Respawn:** hearts refill to 3.
  - **Health packs:** none in Level 1.
  - **Ranged monster:** the mushroom monster, chosen from Claude's three options (a scarecrow, a mushroom, a gargoyle).
  - **Deadline:** the evening of 2026-10-04.
  - **Everything else as Claude suggested:**
    - the six-panel storyboard plan;
    - 1920×1080, with Rudy 160 px tall;
    - the 13 poses;
    - a short straight sword and a round wooden shield with an iron rim;
    - a dark outline.
  - **Pictures:** I said I would make the storyboard and character-sheet pictures with an image model, and asked Claude for starting prompts.
- **Got:**
  - Claude pointed out that the assignment wants these documents committed before the first generation, so generated pictures inside them would break that order. I have not decided yet how the first pictures will be made.
  - Draft v1 of STORYBOARD.md, CHARACTER-SHEET.md and CHANGE-BRIEF.md.
  - `design/generation-prompts.md` (prompts v1, not used yet).
  - CONCEPT.md draft v3, which names the mushroom monster.
  - Claude's additions in these drafts:
    - an asset-ID scheme;
    - a 64 × 136 px collision capsule;
    - a six-color palette with a planned contrast check: hair against wheat 1.21, outline against wheat 7.10;
    - a brown belt and brown boots;
    - the rule that the background changes before Rudy does if the contrast check fails;
    - the assumption that Rudy respawns without gear;
    - must/should/could priorities with a cut order, where the mushroom is "should";
    - the event-to-sound map;
    - music dB values and the mute keys (M and N);
    - the build order.
- **Human / Claude / model:** the decisions above are mine; the drafts and prompts are Claude's. No generative model was used.
- **Still unresolved:**
  - how the first pictures are made;
  - my review of the three drafts and the prompts.

## 2026-09-30 — Pictures drawn by code; the robe stays grey

*Written on 2026-09-30.*

- **Wanted:** pictures for the storyboard and character sheet that keep the design-before-generation order without my drawing them by hand, and a Rudy who stays clearly visible against the wheat.
- **Decided:**
  - **Route B:** Claude draws simple blockouts with code, not with an image model. Generation starts only after the `design-v1` tag.
  - **The robe stays grey.** An outline is fine; it just has to stand out.
  - **Everything else** in the three drafts and the prompts: no changes.
- **Asked:** Claude to draw the blockouts.
- **Got:**
  - `design/tools/make_blockouts.py`, which draws 11 images:
    - the six storyboard panels;
    - the turnaround and the 13 poses;
    - the silhouette test, the collision overlay and the palette check.
  - Claude's own calls in this step:
    - the robe went one step darker, to slate grey `#5A606B` (contrast against the wheat 2.38 → 3.29);
    - the outline became a 4 px outer outline added in-engine, the same on every frame, instead of relying on the line the image model draws;
    - the shields are drawn larger so they read in the silhouette;
    - in the collision overlay, airborne poses share the idle frame.
  - Claude looked at its own first render and fixed:
    - arms covering the face in the rising and celebrating poses;
    - the robe going through the ground in the sitting pose;
    - a shield too small to read;
    - overlapping labels;
    - airborne poses placed wrongly against the capsule.
- **Human / Claude / model:** the decisions above are mine. The code, the images and the darker grey are Claude's and still need my look. No generative model was used.
- **Still unresolved:** my look at the 11 pictures before the `design-v1` tag.

## 2026-10-01 — What the blockouts are for; Rudy's hair and hood; the first sight

*Written on 2026-10-01.*

- **Asked:** whether the code-drawn pictures exist only to satisfy "design before generation", and why `_raw/` stays out of git when the assignment wants generated images in git.
- **Got:**
  - The blockouts are also the storyboard and character-sheet pictures themselves, and the contract that generated frames are judged against. They are compared again in the test report and the film.
  - Claude's earlier `_raw/` instruction was incomplete. Corrected: only full-size working downloads stay local. Accepted originals (`generated/accepted/`), rejected thumbnails (`generated/rejected/`) and the game's edited assets are committed.
- **Wanted:** Rudy closer to how I picture him, a first sight that is the game itself, and a smaller mushroom.
- **Decided:**
  - **Hood:** bigger.
  - **Hair:** a bit browner, parted in the middle, drawn with strands and texture rather than a flat fill.
  - **First sight:** the opening of the 2D game itself, not a 45° overview. Pressing Enter starts play seamlessly on the same screen.
  - **Mushroom monster:** smaller.
- **Got (Claude's calls in this step):**
  - Hair `#C2954E`: contrast against the wheat 1.21 → 1.42, and 1.03 against the meadow.
  - The hood is drawn draped over the shoulders and upper back.
  - The mushroom is about two-thirds of Rudy's height.
  - Panel 1 had been the only high angle. To keep three angles, panel 4 now uses a Dutch angle: on impact the camera shakes and rolls about 6°, then levels, and the HUD stays level. This needs my approval.
  - The theme starts under the title and keeps playing into play without restarting.
- **Human / Claude / model:** the decisions above are mine. The colors, the shapes, the Dutch angle and the text are Claude's. No generative model was used.
- **Still unresolved:**
  - whether I accept the Dutch angle on panel 4;
  - my look at the redrawn pictures;
  - the `design-v1` tag.

## 2026-10-01 — No Dutch angle; a seventh panel instead

*Written on 2026-10-01.*

- **Decided:**
  - No tilted camera on panel 4.
  - Instead, a seventh panel: the "Level complete" end card as a high, wide view of the road to the castle. I chose this from Claude's two options (a Dutch angle on panel 4, or a high-angle end card).
- **Got:**
  - Panel 4 is back to eye level, with the camera shake only.
  - Panel 7 is drawn and added to STORYBOARD.md, CHANGE-BRIEF.md (ENV-ENDCARD, "could"), CONCEPT.md and the prompts.
  - The storyboard's three angles are now eye level (1, 2, 4, 5, 6), low (3) and high (7).
  - Claude's calls:
    - the end card is silent and has no motion;
    - Enter on the card plays Level 1 again (an assumption, still to confirm);
    - ENV-ENDCARD is "could", and is cut together with UI-TITLE.
- **Human / Claude / model:** the choice is mine; the drawing and the text are Claude's. No generative model was used.
- **Still unresolved:**
  - my look at panels 4 and 7;
  - the `design-v1` tag.

## 2026-10-01 — design-v1: the design before the first generation

*Written on 2026-10-01.*

- **Decided:** I confirmed panels 4 and 7, and Claude's two open calls: Enter on the end card plays Level 1 again, and ENV-ENDCARD is "could". The drafts are now design v1.
- **Got:** this commit, tagged `design-v1`. It contains:
  - CONCEPT.md, STORYBOARD.md (seven panels), CHARACTER-SHEET.md and CHANGE-BRIEF.md;
  - the 12 blockout images;
  - `design/generation-prompts.md` (prompts v1);
  - this log.
- **Human / Claude / model:** no image, sound or music model was used before this tag.
- **Next:** generate CHAR-REF first, and judge it against the character sheet at 160 px.
