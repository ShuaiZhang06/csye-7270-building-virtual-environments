# CHANGE-BRIEF — Assignment 3: three 3D assets for walker-rudy

**Revision 1 — 2026-10-13, committed before anything is built.** Later changes are added as new revisions at the end; this revision stays as it is.

walker-rudy is a 2D side-scroller. This assignment adds three simple 3D versions of Level 1 props, shown side by side in a small separate Godot 3D scene (a floor, one light, a camera). They are not connected to the 2D game yet.

## Scale

In the game, Rudy is 160 px tall from his soles to the tip of his cowlick (CHARACTER-SHEET.md). I set **Rudy = 1.2 m**, so **1 m = 133.3 px**. Each size below comes from the prop's body size in the 2D game, divided by 133.3. The 2D game has no depth, so every depth is my choice. For comparison, a goblin (118 px) is 0.89 m tall.

Units: Blender's metric units, unit scale 1.0, so 1 Blender unit = 1 m = 1 Godot unit. Blender is Z-up; the glTF exporter's +Y Up turns that into Godot's Y-up. The front of each asset faces Blender's −Y (what the Front view, numpad 1, shows), which becomes +Z in Godot.

## The three assets

### 1. Waystone (`waystone`)

- **In the game:** the checkpoint in the middle of Level 1, Harvest Fields. Rudy respawns there after losing his last heart. In 2D it is a weathered standing stone with one rune, dark until Rudy reaches it, then glowing pale blue (ENV-WAYSTONE, ENV-WAYSTONE-LIT).
- **Size:** **W 0.70 × D 0.40 × H 0.84 m**. The 2D body is 92.5 × 111.5 px = 0.69 × 0.84 m; it comes up to Rudy's chest (he is 1.2 m).
- **Origin:** the centre of the underside, at Blender's world origin (0, 0, 0). It stands on the floor, so placing it at a point on the ground in Godot puts its base on that point.
- **Look:**
  - stone body: a cube, 0.60 × 0.36 × 0.72 m, base at Z = 0.
  - pointed top: a four-sided cone (a pyramid) 0.12 m tall, on the body. The stone is 0.84 m tall in all.
  - rune: a thin cube, 0.20 × 0.02 × 0.30 m, set into the front face.
  - moss: a flattened cube, 0.70 × 0.40 × 0.06 m, around the foot.
  - 4 shapes. Colours: stone grey `#8C8A80`, moss green `#6E7F3C`, rune pale blue `#99E0FF` (the game's lit-rune glow, `waystone.gd` `GLOW`). The rune is shown lit, as a flat colour, not an emitting light.
- **Triangle budget: 60.** Three cubes (12 triangles each) and one four-sided cone (6) make 42; the budget leaves room for one change.

### 2. Teleport circle (`teleport_circle`)

- **In the game:** the end of Level 1. Rudy steps onto it and the level is complete. In 2D it is a flat circle of gold runes on the ground under a column of gold light (ENV-PORTAL).
- **Size:** **W 2.25 × D 2.25 × H 0.08 m**. The 2D disc is 300 px wide = 2.25 m, almost twice Rudy's height, so he fits on it with room around him. The 2D circle is drawn on the ground; I give it 0.08 m of thickness so it can be seen from the side.
- **Origin:** the centre of the underside, at the world origin. It lies flat on the floor, so its base is the floor.
- **Look:**
  - gold rim disc: a 24-sided cylinder, Ø 2.25 m, 0.04 m tall.
  - dark inner disc: a 24-sided cylinder, Ø 1.95 m, 0.06 m tall. It is 0.02 m taller than the rim disc, so a 0.15 m gold rim shows around it.
  - gold centre disc: a 16-sided cylinder, Ø 0.60 m, 0.08 m tall.
  - three rune marks: thin cubes, 0.20 × 0.08 × 0.02 m, on the dark disc.
  - 6 shapes. Every top face is at a different height (0.04, 0.06, 0.08 m), so no two faces overlap. Colours: gold `#F0A830` (the game's light, `portal.gd` `LIGHT`), pale gold `#FFD76E` for the centre (`portal.gd` `CORE`), dark stone `#4A4440` for the inner disc. No glow or light column.
- **Triangle budget: 300.** A cylinder with n sides has 4n − 4 triangles once its caps are triangulated: 92 + 92 + 60 for the three discs, plus 36 for three cubes, makes 280. Blender's default 32-sided cylinder (124 triangles) would put three discs at 372, over the budget, so the segment counts are set here.

### 3. Spikes (`spikes`)

- **In the game:** a hazard on the path through Level 1. Touching it costs Rudy a heart. In 2D it is a row of five iron spikes in a weathered wooden base (ENV-SPIKES).
- **Size:** **W 0.80 × D 0.30 × H 0.47 m**. The 2D body is 106 × 63 px = 0.80 × 0.47 m, a little under half of Rudy's height, so he jumps over it.
- **Origin:** the centre of the underside, at the world origin, so it sits on the floor.
- **Look:**
  - wooden base: a cube, 0.80 × 0.30 × 0.12 m.
  - five spikes: 8-sided cones, radius 0.07 m, 0.35 m tall, standing on the base with their centres at X = −0.32, −0.16, 0, 0.16 and 0.32 m. Their tips are at 0.47 m.
  - 6 shapes. Colours: wood brown `#7A5838`, iron grey `#5C6168`.
- **Triangle budget: 100.** The cube is 12 triangles; an 8-sided cone is 2 × 8 − 2 = 14, so five are 70. That makes 82.

All three: flat-colour Principled BSDF materials, no textures, no sculpting, no modifiers left unapplied, rotation and scale applied (rotation 0, 0, 0 and scale 1, 1, 1). Each asset is built at the world origin in its own `.blend` file and exported as its own `.glb`.

## Predicted failures and how I will check each

| # | Prediction | How I will check |
| --- | --- | --- |
| 1 | An asset arrives **lying on its side** in Godot, because Blender is Z-up and Godot is Y-up. | The headless check prints each asset's bounding box: its height must be on Godot's Y axis and match the brief. I will also look at it in the Godot scene. |
| 2 | An asset is the **wrong size by a factor** (×2 or ×10). Blender's default cube is 2 m across, not 1 m, so "scale 0.6" gives 1.2 m. Or a scale is left unapplied and Godot's node scale is not 1, 1, 1. | Blender's sidebar Dimensions against the brief, within 0.01 m; Godot's bounding box against both; the node scale printed by the check must be 1, 1, 1. |
| 3 | The **origin is in the middle**, so the asset sinks halfway into the floor or floats. | The bounding box's lowest Y in Godot must be 0 (within 0.005 m). I will also place each asset on the floor in the scene and look from the side. |
| 4 | An asset goes **over its triangle budget**, most likely the teleport circle if Claude uses default 32-sided cylinders. | Blender's Scene Statistics for each file against the budget above; the segment counts in `tools/blender/build_<asset>.py`. |
| 5 | A **colour does not survive the export**. The MCP server's own instructions warn that `material.diffuse_color` only changes the viewport colour, and the exporter reads the shader node's Base Color. | Each asset's colours in the Godot scene, compared with the hex values above. |
| 6 | Claude builds **more detail than asked**: extra shapes, bevels or a subdivision modifier. | `get_scene_info` after each step: the number of objects must match the brief and stay at or under 6, with no modifiers. |
