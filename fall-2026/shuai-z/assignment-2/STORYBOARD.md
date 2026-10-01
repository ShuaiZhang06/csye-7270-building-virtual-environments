# STORYBOARD — walker-rudy

> Draft v1, 2026-09-30. Panels follow the assignment's template. Frame shape: 16:9 throughout. Gameplay panels show what the game camera shows, a 1920×1080 view that follows Rudy; design views are moments outside normal play, or shots that set how a moment should feel. Pictures are blockout thumbnails in `design/storyboard/`, drawn by code that Claude wrote (`design/tools/make_blockouts.py`). They are not generative-model outputs; I chose this route instead of hand sketches.

| Panel | Moment | View | Angle | Motion | Type |
|---|---|---|---|---|---|
| 1 | First sight: the title screen | wide | high | camera pans right | design view |
| 2 | Core action: over the spikes, onto a goblin | medium | eye level | jump arc, stomp bounce, camera follows | gameplay |
| 3 | Success: the sword and shield | close-up | low | — | design view |
| 4 | Failure: a spore from behind | medium | eye level | spore path, knockback, gear flying off, camera shake | gameplay |
| 5 | Recovery: back at the waystone | medium | eye level | fall arrow, fade, respawn | gameplay |
| 6 | The end: the teleport circle | wide | eye level | run-in arrow, rising light, camera zooms out | gameplay, then transition |

Requirements check:
- **Three views:** wide (1, 6), medium (2, 4, 5), close-up (3).
- **Three angles:** high (1), eye level (2, 4, 5, 6), low (3).
- **Motion:** shown on panels 1, 2, 4, 5 and 6.

## Panel 1 — First sight: the title screen

![sketch](design/storyboard/01-first-sight.png)

- **Shot:** wide · high angle · design view (title screen) · motion: the camera pans slowly right along the path toward the castle
- **Player action:** presses Enter on the title screen; the camera settles on the start of the path and play begins
- **See:** the whole valley from above: golden wheat meeting green meadow, the path running right, the castle small on the far horizon; Rudy tiny at the start of the path; the game title
- **Hear:** the theme starts softly (music: playing)
- **Assets:** ENV-SKY-CASTLE, ENV-FIELDS, CHAR-IDLE, UI-TITLE, MUS-LOOP
- **Design reason (P4 — A journey into another world):** the first thing the player feels is a warm, wide world with somewhere far to go

## Panel 2 — Core action: over the spikes, onto a goblin

![sketch](design/storyboard/02-core-action.png)

- **Shot:** medium · eye level · gameplay view · motion: an arc arrow for Rudy's jump over the spikes, landing on the goblin's head; a short bounce arrow after the stomp; the camera follows Rudy sideways
- **Player action:** runs right, jumps the spikes and lands on a patrolling goblin; the goblin is squashed and vanishes, and Rudy bounces up a little
- **See:** the run, rising and falling poses; the goblin walking, then squashed; the spikes clearly visible on the ground
- **Hear:** the jump sound on takeoff (SFX-JUMP) and the stomp sound on contact (SFX-STOMP); music: playing
- **Assets:** CHAR-RUN-A, CHAR-RUN-B, CHAR-RISE, CHAR-FALL, ENEMY-GOBLIN, ENV-SPIKES, ENV-GROUND, ENV-FIELDS, SFX-JUMP, SFX-STOMP, MUS-LOOP
- **Design reason (P2 — Read every threat):** the spikes and the goblin's path are readable before the jump, so the player plans the move instead of guessing

## Panel 3 — Success: the sword and shield

![sketch](design/storyboard/03-success.png)

- **Shot:** close-up · low angle · design view (how the pickup should feel; in play it happens in the medium gameplay shot) · motion: none
- **Player action:** touches the sword-and-shield pickup; Rudy switches to the sword form and the pickup disappears
- **See:** Rudy's hand closing on the sword hilt, the round shield on his other arm, a grin; the pickup's glow fading
- **Hear:** the pickup sound (SFX-PICKUP); music: playing
- **Assets:** PROP-SWORDSHIELD, CHAR-SWORD-IDLE, SFX-PICKUP, MUS-LOOP
- **Design reason (P1 — Your gear is your plan):** the player sees at once that Rudy's shape and his options have changed

## Panel 4 — Failure: a spore from behind

![sketch](design/storyboard/04-failure.png)

- **Shot:** medium · eye level · gameplay view · motion: the spore's path from the mushroom to Rudy's back; a knockback arrow; the sword and shield flying off and fading; a small camera shake on impact
- **Player action:** walks right with the shield raised toward a goblin. The mushroom monster behind him fires, and the spore hits his back, where the shield does not cover him. The game knocks the gear away (no heart is lost), Rudy flashes while invulnerable, and control returns after a short knockback.
- **See:** the mushroom in its attack pose and the spore in flight; Rudy's block pose, then his hurt pose as the gear flies off; the hearts still at 3
- **Hear:** the mushroom's attack sound (SFX-SPORE), then the hurt sound (SFX-HURT); music: dips briefly, then returns
- **Assets:** ENEMY-MUSHROOM, FX-SPORE, ENEMY-GOBLIN, CHAR-SWORD-BLOCK, CHAR-HURT, UI-HEART, SFX-SPORE, SFX-HURT, MUS-LOOP
- **Design reason (P3 — It stings, then you try again; also P2):** the player sees exactly what hit him and from where, and the cost (the gear) is visible but not crushing

## Panel 5 — Recovery: back at the waystone

![sketch](design/storyboard/05-recovery.png)

- **Shot:** medium · eye level · gameplay view · motion: a fall arrow down a cliff gap; a fade; Rudy reappearing at the waystone, flashing
- **Player action:** misjudges a jump over a cliff and falls; it is instant death. After a short fade Rudy reappears at the last waystone with 3 hearts.
- **See:** the falling pose dropping out of the frame; the fade; the lit waystone; the respawn pose, flashing while invulnerable; the hearts refilled to 3
- **Hear:** the fall sound (SFX-FALL); music: dips during the respawn and carries on, without restarting
- **Assets:** CHAR-FALL, CHAR-RESPAWN, ENV-WAYSTONE, ENV-GROUND, UI-HEART, SFX-FALL, MUS-LOOP
- **Design reason (P3 — It stings, then you try again):** failure is quick and the way back is short, so the player wants one more try

## Panel 6 — The end: the teleport circle

![sketch](design/storyboard/06-teleport-circle.png)

- **Shot:** wide · eye level · gameplay view, ending in a transition · motion: Rudy runs into the circle (arrow); light rises from the circle; the camera zooms out slowly
- **Player action:** steps onto the teleport circle; input stops, Rudy celebrates, and the screen fades to "Level complete"
- **See:** the celebrate pose, the glowing circle with rising light, the castle still on the horizon
- **Hear:** the arrival shimmer (SFX-PORTAL); music: fades out under it, then quiet on the end card
- **Assets:** CHAR-CELEBRATE, ENV-PORTAL, ENV-SKY-CASTLE, ENV-FIELDS, SFX-PORTAL, MUS-LOOP
- **Design reason (P4 — A journey into another world):** reaching the circle feels like arriving and setting off again, with the castle still ahead
