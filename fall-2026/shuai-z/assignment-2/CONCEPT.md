# CONCEPT — walker-rudy

> Draft v2, 2026-09-30. Written in English with Claude Code from my answers to a design intake. The design decisions are mine. Changes from draft v1 are logged in FRICTIONAL.md.

## The game in two sentences

You play Rudy, a cheerful chibi boy with medium-length yellow-blond hair, green eyes and a grey robe with the hood down, who crosses a medieval countryside to reach the teleport circle at the end of each level. He runs, jumps and stomps goblins; with a sword and shield or a magic staff he can also fight and block, until a hit knocks the gear away.

## Core loop

- **Repeat:** cross a short stretch of cliffs, spikes and monsters to the next safe ground.
- **Decide:**
  - Avoid or fight: jump past an enemy, stomp it, or (with gear) cut it down or shoot it.
  - Block a shot from the front, or step out of its path. Blocking does not protect against touching an enemy.
  - When hurt, take a risky detour for a health pack, or stay on the safe line. Hearts carry into the next level, so a heart regained now still counts later. At full health a pack does nothing; golden packs in later levels will raise the maximum.
  - Carry the sword or the staff. The sword defeats a goblin in one hit, but only up close. The staff fires one bolt per press from a distance, and needs two to defeat a goblin. You can hold only one; picking up the other swaps it.
- **Risk:** any hit (an enemy, a shot, spikes) knocks the gear away first, and costs one of three hearts after that. Falling off a cliff is instant death. At zero hearts Rudy restarts from the last checkpoint. A short invulnerability after each hit keeps one mistake from turning into three.

## Design pillars

| Pillar | Experience it protects | A visual or sound choice that honors it |
|---|---|---|
| **P1 — Your gear is your plan** | Picking the sword or the staff changes how you deal with what is ahead | Each form has its own silhouette at game size: a short sword with a shield, or a long staff with a magic barrier. Each attack has its own sound: a light steel swish or a soft magic chime |
| **P2 — Read every threat** | It is always obvious when an enemy is attacking, and from where | Every enemy attack has a clear, readable pose, and its projectile stands out from the painted background. Each shot plays the enemy's ordinary attack sound with no extra warning, because enemies fire slowly enough to react to |
| **P3 — It stings, then you try again** | A mistake costs something, but never makes you want to quit | On a hit, the gear visibly drops away and Rudy flashes while invulnerable. The hurt sound is short, and the music dips instead of stopping |
| **P4 — A journey into another world** | The world feels bigger than the path you are on, and worth crossing | A castle on the far horizon, on a slow parallax layer behind the fields, and a folk theme led by lute and recorder |

## Art direction

Characters are chibi (2–3 heads tall) in clean anime cel shading, with fine, even linework and flat, neutral lighting, so the same sprites work under any level's light. Backgrounds are painterly and detailed, with watercolor and gouache texture, careful natural light and a muted, warm, low-saturation palette; the world should feel grounded and real rather than bright and effects-heavy, and the play space stays free of busy scenes of village life. The split serves the pillars: flat, outlined characters and attacks read at once against the soft painted world (P2), while the painted fields and the distant castle make the world feel larger than the path (P4).

- **Materials:** ripe wheat and meadow grass, weathered fieldstone, old timber, worn wool and linen; a stone castle far away.
- **Light:** a clear autumn afternoon with low, warm sun, long soft shadows and a little haze in the distance.
- **Era and mood:** the late-medieval European countryside at harvest time, where golden wheat meets green meadow; quiet, warm and unhurried.

**Known risk:** Rudy's yellow-blond hair and grey robe could disappear against yellow wheat and grey stone. The silhouette and palette checks in the character sheet must test him against the actual Level 1 background.

## Audio direction

The music should feel like a light, unhurried country adventure with a faraway flavor. It uses a small folk ensemble (plucked lute-like strings, wooden flute or recorder, fiddle, frame drum) at a gently bouncing mid tempo, in a major or modal key, with no vocals. Sound effects are soft and warm rather than harsh: a padded stomp, a light sword swish, a gentle magic chime for the staff, a wooden knock when the shield blocks and a soft hum when the barrier does, a short non-vocal hurt cue, and a bright shimmer at the teleport circle. Every sound event also has a visual cue, so the game still reads with the sound muted.

| Moment | Music |
|---|---|
| Normal play | One loop plays continuously through the level |
| Hurt | Dips briefly under the hurt sound, then returns |
| Death (cliff or zero hearts) | Dips during the respawn and carries on; it does not restart from the top |
| Pause | Drops to a low volume until play resumes |
| Teleport circle reached | Fades out under the arrival shimmer; the level ends in quiet |

## Level 1 — Harvest Fields

A forgiving level of about 30 seconds on a clear autumn afternoon, in the wheat fields outside a village, with a castle far away. On the way are cliffs, spikes, patrolling goblins, and a stationary monster that aims and shoots at Rudy. Both enemies can be stomped. The only gear in this level is the sword and shield: the shield blocks the monster's shots from the front, but the shots cannot be cut down. The level ends at the teleport circle. Later levels (not designed yet) add the staff, golden health packs, and enemies that cannot be stomped.

## Open questions

- **The ranged monster.** Which monster is it, and what does it shoot? It is not an ordinary archer, and it need not be a goblin.
