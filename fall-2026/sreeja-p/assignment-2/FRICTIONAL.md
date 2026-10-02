# FRICTIONAL — Assignment 2

## Entries

<!-- One entry per work session, newest last. Copy the block below. -->

### YYYY-MM-DD — <what I was working on>

- **Date and what I was working on:**
- **I tried / expected:**
- **What happened:**
- **What I did:**
- **What Claude or another person contributed:**
- **What I understand now / still do not understand:**
- **Evidence and next step:**

### 2026-10-01 — choosing the game and writing the design docs before generating

- **Date and what I was working on:** 2026-10-01. I chose this semester's game and wrote the design docs before generating anything.
- **I tried / expected:** I started from my Assignment 1 firefighter game, expecting to swap the firefighter for generated art and add sound and music.
- **What happened:**
  - Claude checked the A1 code. The firefighter is drawn entirely in code (`player.gd`, `_draw()`), and the game has no audio, so all three generated categories (art, sound, music) are new work.
  - I could not push to the class repo directly (no write access), so I forked it.
- **What I did:**
  - Decided the concept: a ninja firefighter named **Extinguisho**, with a yellow helmet, a mostly red heat suit, and ninja touches.
  - Decided his movement and face: kung-fu-style jump and landing poses, and a deadpan, grumpy face that turns comic-book devastated when fire touches him.
  - Decided the sound: exaggerated, funny sound effects and urgent music, because he has limited time to save the victims.
  - Picked the tools: Gemini and ChatGPT for images, Suno for music, Audacity for editing.
  - Picked the name from Claude's list and reviewed the drafts.
- **What Claude or another person contributed:** Claude Code:
  - read the A1 code;
  - drafted CONCEPT, CHARACTER-SHEET, CHANGE-BRIEF, and SOURCES from my notes and the game code;
  - suggested name options;
  - flagged two risks: the red suit and yellow helmet against the fire colors, and face readability at about 32 px;
  - set up the fork and copied the A1 game at commit `b2f7945`.
- **What I understand now / still do not understand:**
  - Claude cannot produce art that counts as generated.
  - Audacity edits audio but does not generate it.
  - The class repo ignores WAV files, so game audio will be OGG.
  - Still open: the final look (three candidates in the character sheet), the palette, the storyboard pictures, and whether the kung-fu stance plays in-game.
- **Evidence and next step:** this push's commits. Next: STORYBOARD.md, committed with the other docs before the first generation.

---

## GitHub pushes

| Date | Commit note |
|---|---|
| 2026-10-01 | Add concept, character sheet, change brief, and sources before generation |
| 2026-10-02 | Add storyboard text: six panels, shots, angles, and motion |
