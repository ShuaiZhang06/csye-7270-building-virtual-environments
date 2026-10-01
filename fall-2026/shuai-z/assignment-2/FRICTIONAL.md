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
