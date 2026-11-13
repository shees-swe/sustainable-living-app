# Climate Instrument Design System

## Overview

Climate Instrument treats the app as a clear, dependable instrument for
understanding personal sustainability data. The interface is light-only,
precise, and calm through alignment, whitespace, and direct language—not
decoration or soft colors. Apply this design contract to every existing screen
and state without changing navigation or adding product features.

Color values and measurements below are the canonical tokens. Text/background
contrast ratios were computed using the WCAG relative-luminance formula and
rounded to two decimals. Every listed text pair passes WCAG AA for normal
text (4.5:1) and large text (3:1). Semantic colors are reserved for their
specified meaning; never use emerald as the brand.

```yaml
design:
  name: Climate Instrument
  color:
    surface:
      primary: "#FFFFFF"
      secondary: "#F3F4F6"
    text:
      primary: "#111827"
      secondary: "#4B5563"
      onBrand: "#FFFFFF"
    brand:
      cobalt: "#0057D9"
    semantic:
      positiveSaved: "#007A52"
      emissions: "#8A4B08"
      warning: "#B42318"
    divider: "#7B8492"
  typography:
    family:
      sans: "IBM Plex Sans"
      mono: "IBM Plex Mono"
    weights:
      regular: 400
      medium: 500
      semibold: 600
      bold: 700
    roles:
      headings: "sans"
      body: "sans"
      numbers: "mono"
      units: "mono"
      tableFigures: "mono"
    allowRuntimeFetching: false
  spacing:
    base: 8
    scale: [8, 16, 24, 32, 40, 48]
  shape:
    radiusSmall: 4
    radiusLarge: 8
  elevation:
    level: 0
    shadows: false
  components:
    dividerWidth: 1
    layout: ["lists", "tables"]
  motion:
    stateChange: "instant"
    optionalFadeMilliseconds: 120
    numberChange: "count-or-tick"
    simulation: "SpringSimulation / animateWith"
    bounce: false
    overshoot: false
    reducedMotion: "respect-existing-preference"
```

## Colors

Pure white and cool light grey form the surfaces; near-black ink carries
content. Electric cobalt is the sole brand color. Saturated emerald marks
saved states and positive deltas only. Amber/red identify emissions and
warnings only. Status and chart meanings must remain clear without relying on
color alone. No cream, sage, or dark theme is allowed.

### WCAG text/background contrast

Ratios cover every text color used on every surface assigned to text, plus
white text on cobalt controls. Ratios were computed from the token hex values
using WCAG 2.x relative luminance and contrast ratio formula.

| Text color | Background | Ratio | WCAG AA normal text |
|---|---|---:|---|
| Primary ink `#111827` | White `#FFFFFF` | 17.74:1 | Pass |
| Primary ink `#111827` | Cool grey `#F3F4F6` | 16.12:1 | Pass |
| Secondary ink `#4B5563` | White `#FFFFFF` | 7.56:1 | Pass |
| Secondary ink `#4B5563` | Cool grey `#F3F4F6` | 6.87:1 | Pass |
| Cobalt `#0057D9` | White `#FFFFFF` | 6.24:1 | Pass |
| Cobalt `#0057D9` | Cool grey `#F3F4F6` | 5.67:1 | Pass |
| Positive emerald `#007A52` | White `#FFFFFF` | 5.38:1 | Pass |
| Positive emerald `#007A52` | Cool grey `#F3F4F6` | 4.89:1 | Pass |
| Emissions amber `#8A4B08` | White `#FFFFFF` | 6.79:1 | Pass |
| Emissions amber `#8A4B08` | Cool grey `#F3F4F6` | 6.17:1 | Pass |
| Warning red `#B42318` | White `#FFFFFF` | 6.57:1 | Pass |
| Warning red `#B42318` | Cool grey `#F3F4F6` | 5.97:1 | Pass |
| White text `#FFFFFF` | Cobalt `#0057D9` | 6.24:1 | Pass |

The divider `#7B8492` is non-text visual separation rather than a text color;
its contrast is 3.78:1 against white and 3.43:1 against cool grey, above the
3:1 non-text contrast threshold. Do not reduce opacity or place it on an
untokenized surface.

## Typography

Use IBM Plex Sans for every heading, label, and body passage. Use IBM Plex
Mono for every number, unit, and table figure—including values embedded within
otherwise sans-serif content. Keep tabular figures aligned and do not use
weight or size alone to communicate meaning.

Bundle only the required font families and weights as local app assets through
`google_fonts`. Disable runtime fetching; a cold, offline launch must render
all text with the selected fonts. Preserve the system's Very Large text
behavior, wrapping rather than clipping or overlapping content.

## Elevation

Elevation is zero. Do not use drop shadows, floating cards, gradients, or
layered surfaces to suggest hierarchy. Use whitespace, alignment, typography,
and visible hairline dividers instead. This keeps information comparable and
supports a tool-like rather than decorative feel.

## Shapes

Use corner radii from 4 px to 8 px only. Prefer square-edged rows and
rectangular table regions; reserve the small radius for controls and restrained
grouping. Use the 8 px spacing grid, with 8 px and 16 px as the primary
increments and their multiples for larger separations.

## Components

- **Lists and tables** are the primary composition. Keep row labels and values
  aligned; use thin dividers to distinguish adjacent records.
- **Actions and selection** use cobalt as the brand cue, with adequate
  contrast and accessible touch targets. Avoid introducing a route or new
  action during visual restyling.
- **Saved/positive feedback** may use saturated emerald; do not use it for
  navigation, headings, or generic decoration.
- **Emission values and warnings** may use amber/red, paired with clear text
  labels and existing source/context disclosures.
- **Estimate result** uses one budget-share bar against the cited
  2.5 t CO2e/person/year-by-2030 benchmark, only when existing values have
  equivalent units. Describe the share as a lower bound. Provide horizontal
  bars for supported existing categories, the estimate rate and unit, and an
  included/excluded coverage statement. Do not display comparison rings,
  three-reference percentage comparisons, unsupported category values, or EPA
  equivalency cards. This result-screen decision closes T066 Step 3.
- **Loading and empty states** retain direct, warm copy; do not substitute
  decorative cards or make claims not supported by existing data.

## Motion

State changes are immediate. Use an optional fade of approximately 120 ms only
where it aids continuity. Numbers count or tick to their final value. Use
`SpringSimulation` / `animateWith` for applicable animation and gestures, tuned
without bounce or overshoot; preserve interruptibility, velocity handoff,
momentum projection, and 1:1 drag response where applicable. Animation must
not block input. When reduced motion is enabled, skip nonessential motion and
present final state without stranding the user.

Use `skeletonizer` for existing loading states. A motion/performance package
such as `motor` is not part of the default design: consider it only if the
measured profile traces establish a concrete gap that it can address.

## Do's and Don'ts

### Do

- Apply the same tokens to every existing screen and state.
- Use concise, respectful copy for warmth and honest empty states.
- Preserve visible units, sources, estimate assumptions, and limitations.
- Test contrast, touch targets, reduced motion, and every screen at Very Large
  text.
- Measure before optimizing, and compare before/after traces under identical
  device and profile conditions.
- Keep existing routes, data, factors, offline behavior, and Back navigation.

### Don't

- Add cream, serif display typography, sage, a dark palette, or green branding.
- Use glow, gradients, shadows, bounce, overshoot, or unnecessary animation.
- Compare values with different units, periods, or boundaries as if equivalent.
- Show comparison rings, EPA-style equivalencies, or unsubstantiated numeric
  claims.
- Fetch fonts at runtime or rely on connectivity to render text.
- Add features, routes, data, or emission factors as part of this visual pass.
