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

### 2026-10-02 — storyboard sketches in ChatGPT

- **Date and what I was working on:** 2026-10-02. Generating the six storyboard panel sketches.
- **I tried / expected:** one rough pencil sketch per panel from ChatGPT (Plus, Instant mode), using a base style prompt and then one prompt per panel. I expected each image to match its panel's shot, angle, and action.
- **What happened:**
  - **Panel 1** matched except the character's size (large in the foreground, not "small at the far left").
  - **Panel 3, attempt 1:** he carried the person in his arms. That contradicts my game, where a rescued survivor rides as a head in the bag on his back. My prompt never mentioned the bag.
  - **Rescue strip:** when I pasted the three rescue prompts in one message, ChatGPT returned one wide strip of three square frames, not three 16:9 images.
  - **Panel 6:** the bag holds two people and a dog instead of one person and one dog.
  - **Order:** I generated panel 1 before the storyboard text was committed. The text was written 2026-10-01; the image was saved at 10:20 and the storyboard committed at 10:22 on 2026-10-02. Panels 2–6 came after the commit.
- **What I did:**
  - Rejected the arms-carry rescue because it doesn't match the game.
  - Decided the rescue is funnier if he doesn't care: he grabs the survivor and recklessly tosses them into his bag.
  - Then split the rescue into three beats with different faces: 3a grab (serious), 3b throw (couldn't care less, yawning), 3c in the bag (serious again).
  - Moved the person inside the window for 3a.
  - Kept the strip only as a reference and regenerated each beat as its own 16:9 image, one message each.
  - Accepted panel 6 with the bag mismatch noted.
- **What Claude or another person contributed:** Claude Code:
  - wrote the base and panel prompts and the revised prompts from my changes;
  - pointed out from the code that rescue uses the bag;
  - flagged the strip's frame shape and the panel 6 mismatch;
  - resized and filed the images;
  - recorded the prompts and the asset log.
  
  ChatGPT generated every sketch. The rescue redesign and every accept or reject decision were mine.
- **What I understand now / still do not understand:**
  - One message gives one image, so each frame needs its own message saying "single 16:9 image."
  - A prompt has to describe the game's actual mechanic, or the model fills in a default.
  - Still open: the three rescue beats could become the three frames of the in-game rescue animation (pose 9), which the character sheet needs to reflect.
  - **Still open: the ninja-ness doesn't come through strongly enough.** Looking at the six panels together, he reads mostly as a regular firefighter. The ninja signals are only the face wrap, the headband tails, the stance in panel 2, and the kick in panel 6; the rest is standard firefighter gear. My concept depends on "every move is a kata", so the ninja side has to be pushed harder when I design the character's look. I have not decided how yet.
- **Evidence and next step:**
  - Prompts are verbatim in STORYBOARD.md, "Revision 2026-10-02"; asset log rows SB-01 … SB-06 are in SOURCES.md; rejected thumbnails are in `walker-ninja-firefighter-joe/rejected/`.
  - Next: generate the character's three candidate looks and pick one.

---

## GitHub pushes

| Date | Commit note |
|---|---|
| 2026-10-01 | Add concept, character sheet, change brief, and sources before generation |
| 2026-10-02 | Add storyboard text: six panels, shots, angles, and motion |
| 2026-10-02 | Add storyboard sketches, prompt log, and rejected thumbnails |
