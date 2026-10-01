# Generation prompts — v1 (starting prompts)

> 2026-09-30, updated 2026-10-01. Starting prompts, drafted by Claude Code from CHARACTER-SHEET.md, STORYBOARD.md and CHANGE-BRIEF.md. **None of these has been used yet.** Use them only after the `design-v1` commit. The asset log records the exact prompt actually used for each output, including any change made on the way.

## How to use them

1. **Rudy's reference comes first.** Generate CHAR-REF (two or three candidates), then judge each against the character sheet at game size (160 px tall): height in heads, the cowlick, hair color, the robe with the hood down, the outline. Keep one and log the rest as rejected.
2. **Every pose is an edit of the reference.** Attach CHAR-REF and describe only the change of pose. Consistency comes from the reference image, not from repeating the text.
3. **Enemies and props match Rudy's style.** Attach CHAR-REF as a style reference, and say that it shows a different character.
4. **Save every output under its ID and a number**, such as `CHAR-REF-01.png`, in `_raw/`. That is a local working folder of full-size downloads, kept out of git. Then:
   - an accepted output is copied unchanged to `generated/accepted/`;
   - a rejected output goes in `generated/rejected/` as a small thumbnail or on a contact sheet, as the assignment asks;
   - the edited, game-ready version goes into the Godot project.

   All three are committed.
5. **Record for each output:** the model name and version exactly as the tool shows them, the date, the exact prompt, the attached images, and the size or aspect ratio. Hosted chat tools do not expose a seed, so write "seed: not available".
6. If an image comes back with a visible watermark, note it in the asset log, and check the tool's terms before cropping it out.
7. Never add the name of an artist, a studio, a game or a franchise to any prompt.
8. The bold outer outline is added in-engine at game size, so the generated outline only has to be fine and even.

## Shared style blocks

These are already written out in full inside each prompt below. They are listed here so that every prompt can be checked against the same wording.

**Sprite style** (characters, enemies, props, hazards):

```text
Style: a 2D game sprite in anime style. Clean cel shading with exactly two tones per color (a flat base and one flat shadow), a fine dark-brown outline of even weight, and flat, neutral front lighting: no rim light, no glow, no cast shadow, no gradients. One figure, centered, with empty margin around it. Background: one plain, flat, solid steel-blue color (#4F7CAA) filling the whole image, with no floor, no shadow, no other objects and no text.
```

**Background style** (the parallax layers):

```text
Style: a painterly, hand-painted 2D game background, like a high-quality TV anime background: detailed watercolor and gouache textures, soft natural light, a muted natural palette with low saturation and warm earthy tones, atmospheric depth, subtle film grain. A grounded, believable late-medieval European countryside in autumn, on a clear afternoon. No characters, no animals, no text.
```

## Rudy

### CHAR-REF — turnaround reference (new image)

```text
A character turnaround sheet of one boy, Rudy, shown four times side by side at exactly the same height and scale, standing in a relaxed neutral pose with his arms at his sides: front view, three-quarter view, side view facing right, and back view.
Rudy is a cheerful boy drawn in chibi proportions, exactly 2.5 heads tall (his head is 40% of his height). Medium-length blond hair with a light-brown tint (browner than golden blond), parted in the middle with curtain bangs framing his face, covering his ears and ending at the nape, drawn with visible strands and texture rather than a flat fill; one cowlick curling up from the crown. Large green eyes and a small, friendly smile. A plain knee-length slate-grey mage robe with long sleeves and a large hood; the hood is down, lying across his shoulders and upper back. A brown leather belt and brown leather boots. No hat, no jewelry, no emblem, no weapon.
Style: a 2D game sprite in anime style. Clean cel shading with exactly two tones per color (a flat base and one flat shadow), a fine dark-brown outline of even weight, and flat, neutral front lighting: no rim light, no glow, no cast shadow, no gradients. Background: one plain, flat, solid steel-blue color (#4F7CAA) filling the whole image, with no floor, no shadow, no other objects and no text.
Wide image, 16:9.
```

### Pose edits (attach CHAR-REF)

Paste this template and replace `[POSE]` with one line from the table:

```text
Use the attached image as the exact character reference: the same boy, Rudy, with the same proportions (2.5 heads tall), face, center-parted light-brown-blond hair with its strands and cowlick, green eyes, grey robe with the large hood down, brown belt and boots, colors and dark-brown outline. Draw only one figure: Rudy in side view facing right, [POSE]. Keep the same cel-shaded style, flat neutral lighting and the same plain, solid steel-blue background (#4F7CAA). Change nothing except the pose. Square image.
```

| ID | `[POSE]` |
|---|---|
| CHAR-IDLE | standing relaxed, with his weight slightly forward and a cheerful look |
| CHAR-RUN-A | running, contact pose: the front foot just touching the ground, the back leg stretched out behind him, body leaning forward, arms swinging opposite to the legs |
| CHAR-RUN-B | running, passing pose: the supporting leg straight under his body, the other knee bent and lifted as it passes, body leaning forward |
| CHAR-RISE | jumping upward: knees tucked, arms raised, hair and robe pulled downward by the upward motion |
| CHAR-FALL | falling: legs stretched down, ready to land, arms out for balance, hair and robe lifted by the fall |
| CHAR-HURT | hurt: recoiling from a hit coming from the right, leaning back, eyes squeezed shut, arms flung out |
| CHAR-DEFEAT | defeated: sitting on the ground with his legs out, dizzy, eyes shut, a small sad smile |
| CHAR-RESPAWN | getting back up: one knee on the ground, pushing himself up with a determined smile |
| CHAR-CELEBRATE | celebrating: a small hop with one fist raised high and a big happy smile |

### Sword form

**CHAR-SWORD-IDLE** (attach CHAR-REF). This image becomes the reference for the sword form.

```text
Use the attached image as the exact character reference: the same boy, Rudy, with the same proportions, face, hair and cowlick, eyes, grey robe with the large hood down, belt, boots, colors and outline. Draw only one figure: Rudy in side view facing right, in a ready stance, holding a short, plain, straight steel sword in one hand with the blade pointing forward and down, and a small round wooden shield with a plain iron rim and no emblem on the other arm. Keep the same cel-shaded style, flat neutral lighting and the same plain, solid steel-blue background (#4F7CAA). Square image.
```

**Slash and block** (attach CHAR-SWORD-IDLE). Paste this template and replace `[POSE]`:

```text
Use the attached image as the exact reference for the character, the sword and the shield. Draw only one figure: Rudy in side view facing right, [POSE]. Keep the same style, colors, outline, lighting and the same plain, solid steel-blue background (#4F7CAA). Change nothing except the pose. Square image.
```

| ID | `[POSE]` |
|---|---|
| CHAR-SWORD-SLASH | mid-slash, swinging the sword in a wide horizontal arc in front of him, body twisted into the swing, the shield pulled in close |
| CHAR-SWORD-BLOCK | blocking: the shield raised in front of him toward the right, body braced, knees bent, the sword held back |

**Sword-form movement**: CHAR-SWORD-RUN-A, -RUN-B, -RISE and -FALL. Attach the default pose first and CHAR-SWORD-IDLE second.

```text
Keep exactly the pose, body and background of the first attached image. Add the sword and shield exactly as they look in the second attached image, held naturally for this pose. Change nothing else.
```

## Environment

### ENV-SKY-CASTLE — far parallax layer (new image)

```text
A wide panoramic far background for a side-scrolling game, seen at eye level. A clear autumn afternoon sky with a few soft clouds and low, warm sunlight. Low, hazy blue-green hills along the lower third. A grey stone castle, small and far away on a hill in the right third, softened by haze. Nothing in the foreground: the lowest part of the image is distant hills only, so that a field layer can sit in front of it.
Style: a painterly, hand-painted 2D game background, like a high-quality TV anime background: detailed watercolor and gouache textures, soft natural light, a muted natural palette with low saturation and warm earthy tones, atmospheric depth, subtle film grain. A grounded, believable late-medieval European countryside in autumn. No characters, no animals, no text.
The widest aspect ratio available (21:9 if possible, otherwise 16:9), at the largest size.
```

### ENV-FIELDS — middle layer (new image)

```text
A middle-ground layer for a side-scrolling game, seen straight from the side at eye level: rolling golden-yellow wheat fields meeting a green meadow, with a few small trees and a low wooden fence far behind. No buildings, no people, no busy village scenes. Even detail across the whole width, so that it can repeat horizontally. The fields fill only the lower half of the image; above them the image is one flat, solid pale blue (#CFE0E6) with no clouds and no detail, so that it can be cut away.
Style: a painterly, hand-painted 2D game background, like a high-quality TV anime background: detailed watercolor and gouache textures, soft natural light, a muted natural palette with low saturation and warm earthy tones, subtle film grain. Late-medieval European countryside in autumn, clear afternoon. No characters, no animals, no text.
The widest aspect ratio available, at the largest size.
```

### ENV-GROUND — ground strip (new image), then the cliff edge (edit)

```text
A side-view ground strip for a 2D platformer: packed earth with a band of short grass and a few wheat stalks along the top, and warm brown soil with small stones below. A straight, level, crisp top edge, and detail spread evenly so that it can repeat from left to right. Painterly hand-painted texture with watercolor and gouache, a muted warm earthy palette, soft natural light. The strip is isolated on one plain, flat, solid steel-blue background (#4F7CAA), with nothing else in the image and no text. Wide image, 16:9.
```

Cliff edge (attach the chosen ENV-GROUND):

```text
The same ground strip, exactly as attached, but ending on the right in a rough, crumbling cliff edge that drops straight down. Keep the same style, colors and plain steel-blue background. Change nothing else.
```

### ENV-SPIKES (new image)

```text
A short row of five sharp iron spikes set in a weathered wooden base, seen from the side, clearly dangerous.
Style: a 2D game sprite in anime style. Clean cel shading with exactly two tones per color, a fine dark-brown outline of even weight, flat, neutral front lighting, no glow, no cast shadow, no gradients. Centered, with empty margin. Background: one plain, flat, solid steel-blue color (#4F7CAA), with no floor, no other objects and no text. Square image.
```

### ENV-WAYSTONE — dark (new image), then lit (edit)

```text
A waist-high, weathered standing stone used as a checkpoint, seen from the side, with one simple invented rune carved into its face; the rune is dark. A little moss at its base.
Style: a 2D game sprite in anime style. Clean cel shading with exactly two tones per color, a fine dark-brown outline of even weight, flat, neutral front lighting, no glow, no cast shadow, no gradients. Centered, with empty margin. Background: one plain, flat, solid steel-blue color (#4F7CAA), with no floor, no other objects and no text. Square image.
```

Lit (attach the chosen dark stone):

```text
The same stone, exactly as attached, but the carved rune now glows soft white-blue and gives off a faint glow. Change nothing else.
```

### ENV-PORTAL (new image)

```text
A magic teleport circle drawn on the ground, seen from a low side angle so that it looks like a flat ellipse: rings of simple invented runes and plain geometric lines glowing a soft gold-white, with faint motes of light rising from it. No stars, no letters, no real-world symbols.
Style: a 2D game sprite in anime style, with clean cel shading and a fine dark-brown outline where there are solid edges; the circle itself may glow. Centered, with empty margin. Background: one plain, flat, solid steel-blue color (#4F7CAA), with nothing else in the image and no text. Wide image, 16:9.
```

### ENV-ENDCARD — the "Level complete" card (new image)

```text
A high, elevated view looking down over a late-medieval European countryside in autumn: a dirt road winds from the bottom left of the image, between golden wheat fields and green meadows, all the way to a grey stone castle small on the far horizon. Near the start of the road, a faint, softly glowing magic circle lies on the ground. No characters, no animals, no text. Leave calm sky at the top for a title to sit on.
Style: a painterly, hand-painted 2D game background, like a high-quality TV anime background: detailed watercolor and gouache textures, soft natural light, a muted natural palette with low saturation and warm earthy tones, atmospheric depth, subtle film grain. A clear autumn afternoon.
16:9, at the largest size.
```

## Props, enemies and UI

### PROP-SWORDSHIELD (attach CHAR-SWORD-IDLE)

```text
Draw only the sword and shield from the attached image, unchanged in shape and color, as a floating game pickup: the short straight sword crossed over the small round wooden shield, with a faint warm glow around them. No character. Same cel-shaded style and dark-brown outline, on the same plain, solid steel-blue background (#4F7CAA). Square image.
```

### ENEMY-GOBLIN (attach CHAR-REF as a style reference)

```text
Match the art style of the attached image exactly (the same cel shading, outline weight, flat lighting and plain steel-blue background), but draw a different character: a small goblin enemy in the same chibi proportions, 2 heads tall and a little shorter than the boy in the reference. Grey-green skin, long pointed ears, a big nose, a mischievous grin, a ragged brown cloth tunic, bare feet, no weapon. One figure, side view facing right, mid-walk. Square image.
```

Second walk frame (attach the chosen goblin):

```text
The same goblin, exactly as attached, in the other walking pose, with the other leg forward. Change nothing else.
```

Squashed (attach the chosen goblin):

```text
The same goblin, exactly as attached, squashed flat by a stomp from above, dizzy. Change nothing else.
```

### ENEMY-MUSHROOM (attach CHAR-REF as a style reference)

The mushroom must not resemble any existing game's mushroom: it has no feet, and its cap is not red with white spots.

```text
Match the art style of the attached image exactly (the same cel shading, outline weight, flat lighting and plain steel-blue background), but draw a different character: a stationary mushroom monster rooted in the ground, with no legs and no feet. A squat, lumpy, pale stem with two small dark eyes and a round mouth, under a wide, drooping, rust-orange autumn cap with a few darker ochre speckles. Grumpy rather than cute, about two-thirds as tall as the boy in the reference. One figure, side view facing right. Square image.
```

Attack (attach the chosen mushroom):

```text
The same mushroom monster, exactly as attached, attacking: the cap squeezes down and the mouth opens wide, puffing one ball of violet spores toward the right. Change nothing else.
```

Squashed (attach the chosen mushroom):

```text
The same mushroom monster, exactly as attached, squashed flat by a stomp from above, its cap crumpled. Change nothing else.
```

### FX-SPORE (new image)

```text
A single small, round ball of dusky violet spores, slightly brighter at the core, with a soft, dusty edge: a projectile for a 2D game. Clean cel shading with a fine dark-brown outline; it may glow softly. Centered, with empty margin, on one plain, flat, solid steel-blue background (#4F7CAA), with nothing else in the image. Square image.
```

### UI-HEART (new image)

```text
Two small heart icons for a game's health display, side by side: a full heart in warm red, and an empty heart drawn as an outline only. Clean cel shading with exactly two tones, a fine dark-brown outline, flat lighting. On one plain, flat, solid steel-blue background (#4F7CAA), with nothing else and no text. Wide image.
```
