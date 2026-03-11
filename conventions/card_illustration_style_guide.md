# Card illustration style guide

Style reference for the card illustrations on the Neotoma site. The canonical examples are the three images in the **who-is-it-for** section.

## Reference assets

| Card | Asset | Background |
|------|-------|------------|
| AI-native operators | `frontend/src/assets/images/icp/icp-option-b-operators.{svg,png}` | `#eef4fc` |
| AI infrastructure engineers | `frontend/src/assets/images/icp/icp-option-b-infra.{svg,png}` | `#f8f1d5` |
| Agentic systems builders | `frontend/src/assets/images/icp/icp-option-b-builders.{svg,png}` | `#ebf5ec` |

## Style characteristics

### 1. Solid flat background

The entire canvas is filled with a single solid color. No gradients, no radial lighting, no vignettes, no noise textures. The background must be pixel-identical to the card's `cardBg` value so the image edge disappears into the card.

### 2. Extremely muted, near-monochrome palette

Each illustration uses only **2-3 tones from a single hue family**, all highly desaturated:

- A **light fill** for shape interiors (close to the background color but slightly more saturated).
- A **medium stroke** for outlines (the same hue, noticeably darker).
- An occasional **subtle accent** for small details (dot eyes, icon fills), still within the same hue range.

There are no bright or saturated colors anywhere. The overall impression is quiet and washed-out, almost like a pencil sketch that has been lightly tinted.

Examples from the reference images:

- **Operators (blue family):** background `#eef4fc`, fills in pale blue-grey/sage, strokes in muted grey-green, accent sage-green for icons.
- **Infra (warm family):** background `#f8f1d5`, fills in pale sage-green, strokes in muted teal-grey, accent dusty blue-green for the pipeline ribbon.
- **Builders (green family):** background `#ebf5ec`, fills in pale grey-white, strokes in muted grey, accent emerald-teal dots for eyes.

### 3. Uniform line-art outlines

All shapes have a consistent medium-weight outline stroke. There is no variation in stroke width within a single illustration. Corners are generously rounded (large border-radius). The line work feels hand-drawn-adjacent but geometrically clean.

### 4. Flat fills only

Shape interiors use a single flat color. No interior gradients, no shadows, no highlights, no bevel, no emboss, no glow. Depth is communicated solely through overlapping and layering of flat shapes.

### 5. Symbolic icons inside rounded containers

Individual concepts are represented as **simple symbolic icons placed inside rounded-square containers**:

- Operators: browser windows containing a speech bubble, code brackets `</>`, and an envelope.
- Infra: rounded squares containing a funnel, a gear, and a rocket.
- Builders: rounded-square robot heads with dot eyes and a small ear gear.

The icons are stylized and minimal, not realistic. They use the same stroke-and-fill treatment as everything else.

### 6. Two-tier composition (top row converges to bottom element)

All three reference images share the same compositional structure:

1. **Top tier:** 2-3 objects arranged in a horizontal row (the inputs/sources).
2. **Bottom tier:** a single wider element (the shared output/state).
3. **Dashed connector lines** run from each top-tier object down to the bottom-tier element, converging into a shared junction point.

The connectors use a heavy dashed stroke (roughly 6-8px dash, 4-6px gap at the illustration's native scale). The junction point uses a small filled triangle (arrowhead) pointing at the bottom element.

### 7. No text or labels

The illustrations contain no readable words. Everything is communicated through shape and symbol.

### 8. Generous whitespace

The subject matter occupies roughly the center 60-70% of the canvas. There is significant padding on all sides, giving the illustration a spacious, airy feel.

### 9. Bot/agent heads (when representing agents)

The builders image shows agents as simplified robot heads:

- Rounded-square head shape with a lighter face panel.
- Two small circle eyes (filled with the accent tone, e.g. teal-green).
- A small gear or cog detail on one side of the head (suggesting mechanical/AI nature).
- No body, no limbs. Just the head icon.
- Same flat-fill + outline treatment as every other element.

### 10. Arrow connectors between sequential elements

When showing a sequence (e.g. the infra pipeline), small solid-filled arrow triangles connect elements left-to-right. These arrows use the medium stroke color and are small relative to the containers.

## Asset format

| Property | Value |
|----------|-------|
| Native canvas | 220x220 |
| Display size | `size-[280px]` (Tailwind, scales up) |
| Packaging | SVG wrapper (`<svg viewBox="0 0 220 220">`) containing a full-canvas background `<rect>` and an embedded raster `<image href="data:image/png;base64,..."/>` |
| Source raster | PNG at ~1024x1024 (high resolution for retina) |

## Checklist for new illustrations in this style

1. Canvas filled with a single flat solid color matching the card `cardBg`.
2. Only 2-3 tones from one hue family; all highly desaturated.
3. Uniform-weight rounded outlines on all shapes.
4. Flat fills only; no gradients, shadows, or lighting.
5. Symbolic icons inside rounded containers (not literal screenshots or schemas).
6. Two-tier composition: top row of sources converging via dashed lines to a bottom shared element.
7. No text or labels anywhere in the image.
8. Generous padding; subject centered in ~60-70% of canvas.
9. Agent/bot depicted as a head icon only (rounded square, dot eyes, ear gear), not a full-body character.
10. Quiet, washed-out, almost monochrome feel overall.
