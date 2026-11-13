# Field Notes Design System

## Overview

Field Notes gives the sustainability app a warm, editorial character while
keeping information clear, practical, and honest. A paper-toned canvas, ink
typography, compact badges, and outlined panels organize content without
changing the app's routes, data, persistence, or workflows.

The design is light-only. Use the shared tokens in
`lib/core/theme/design_tokens.dart` and the reusable components in
`lib/core/widgets/design_components.dart`; avoid one-off colors, spacing, and
surface treatments.

## Color

| Role | Token | Value |
|---|---|---|
| Page canvas | `canvas` | `#F7F2E8` |
| Primary surface | `surface` | `#FFFEFA` |
| Muted surface | `surfaceMuted` | `#EDE8DD` |
| Raised surface | `surfaceRaised` | `#E4DED1` |
| Blue information surface | `surfaceBlue` | `#DEEAF3` |
| Coral attention surface | `surfaceCoral` | `#F2DFD7` |
| Sun highlight surface | `surfaceSun` | `#F3E4BE` |
| Primary ink | `ink` | `#182A38` |
| Secondary ink | `inkMuted` | `#4F6069` |
| Primary blue | `blue` | `#315D86` |
| Dark blue ink | `blueInk` | `#17344C` |
| Coral accent | `coral` | `#954A30` |
| Sun accent | `sun` | `#A05218` |
| Positive state | `positive` | `#28624C` |
| Warning | `warning` | `#A83035` |
| Subtle divider | `dividerSubtle` | `#D7D1C4` |

Use blue for primary actions and informational emphasis, coral for attention
and errors, sun for emissions and highlights, and green only for positive or
saved states. Pair status colors with text or icon labels; color alone must
not carry meaning. Keep text and controls on the palette's tested combinations:
the theme tests verify AA contrast for the semantic text colors on the canvas,
primary, and muted surfaces, and white on the primary blue.

## Typography

Use the bundled IBM Plex Sans family for headings, labels, and body text.
Use IBM Plex Mono for numbers, units, and aligned figures through the
`ClimateTypography` theme extension. Font assets are bundled locally and
runtime fetching is disabled.

Text should wrap rather than clip. Preserve the app's Very Large text support;
do not make layouts depend on fixed text heights or a single line of copy.

## Layout and shape

Use the shared 4–64 px spacing scale, with 8, 16, and 24 px as common
increments. Panels have 22 px corners; controls use 14 px corners, small
elements 8 px, and pills are fully rounded. Keep touch targets at least 48 px.

`AppPanel` is the standard grouped surface: a light fill, subtle outline, and
no shadow. Use whitespace and typography to establish hierarchy, with thin
subtle dividers for related list rows. Avoid gradients, heavy elevation, and
decorative containers that compete with the content.

`AppIconBadge` presents a small, non-interactive icon on a tinted square.
`AppSectionHeading` gives repeated content sections consistent hierarchy.
Keep existing list, filter, form, chart, and navigation behavior intact.

## Content and data

- Preserve existing wording, navigation, calculations, saved data, filters,
  disclosures, and offline behavior during visual changes.
- Keep units, sources, factor dates, assumptions, and limitations visible
  wherever they already appear.
- The estimate result may show a budget-share bar only when units and periods
  match the cited benchmark. Describe the share as a lower bound, retain the
  source and accounting boundary, and do not add unsupported comparisons or
  equivalency claims.
- Keep demo data explicitly labeled. Empty and unavailable states should state
  what is unavailable without implying that a feature or data source exists.
- Do not add product features, routes, emission factors, or new sustainability
  claims as part of a visual redesign.

## Accessibility and motion

Preserve semantic labels, live announcements for status changes, and
accessibility-aware progress indicators. Text scaling must not hide actions or
make controls unreachable. Color-coded states also need a textual indication.

Respect the existing reduced-motion preference. Nonessential transitions
should be brief and interruptible; when motion is reduced, show the final state
without animation. Do not add looping or decorative motion.

## Validation

Use `AppTheme.light` and its theme extension rather than screen-specific theme
overrides. Keep the tests for palette contrast, bundled fonts, touch-target
sizes, reduced motion, and Very Large text passing as screens evolve.
