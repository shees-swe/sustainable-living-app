# Sustainable Living — Verdant Design System

## Overview

The app uses a warm, calm palette and clear, touch-friendly mobile layouts.
The Flowstep design is the source of truth for this visual system: cream page
surfaces, verdant actions and selected states, rounded cards with a restrained
shadow, and persistent bottom navigation. Existing routes, local data, labels,
and behaviors remain authoritative; visual redesigns must not replace real app
data with sample values.

## Color

| Role | Token | Value |
|---|---|---|
| Page background | `surfacePrimary` | `#FBF8F0` |
| Card surface | `surfaceCard` | `#FFFEFA` |
| Soft sage surface | `surfaceSecondary` | `#EDF2E7` |
| Primary text | `textPrimary` | `#1F2D24` |
| Supporting text | `textSecondary` | `#536158` |
| Verdant actions and selection | `verdant` | `#2F6B4F` |
| Positive / saved | `positiveSaved` | `#2F6B4F` |
| Emissions | `emissions` | `#85510C` |
| Warning | `warning` | `#A8322C` |
| Dividers and outlines | `divider` | `#8A978B` |

Use the cream surface for the page canvas, card surface for elevated content,
and sage for quiet emphasis or selected row backgrounds. Verdant is reserved
for primary actions, selected navigation, and positive states. Keep warning
and emissions meanings distinct and pair color with clear text or icons.
Normal text and important controls must retain WCAG AA contrast.

## Typography

Use the bundled IBM Plex Sans family for headings, labels, and body text.
Use bundled IBM Plex Mono for aligned numeric metrics and units. Do not fetch
fonts at runtime; all font weights are local assets. Preserve text scaling and
allow long labels to wrap rather than clip.

## Spacing and shape

Use an 8 px spacing rhythm, primarily 8, 16, 24, and 32 px. Cards use a
16–20 px radius with comfortable internal padding; fields, buttons, and
segmented controls use a 12 px radius. Keep touch targets at least 48 px high
where practical.

## Elevation and components

Use rounded, subtly bordered cards with a soft, low-opacity shadow to create
gentle hierarchy. Avoid gradients and high-contrast decorative effects.
Primary actions use verdant; secondary actions use outlined or sage surfaces.
Search and filtering remain directly accessible above their results.

The shared bottom navigation contains Home, Modules, Journal, and Settings.
Home and Modules lead to the app’s existing module hub, with the selected
destination reflected in the navigation. Journal and Settings continue to
use their existing app routes. The onboarding flow remains focused and does
not show bottom navigation.

## Behavior and accessibility

Keep all existing routes, data repositories, persistence, search and filter
state, controls, error and empty states, and accessibility labels. Do not
introduce mock values in place of persisted or calculated data. Preserve
keyboard and screen-reader access, reduced-motion preferences, and large text
behavior. Avoid adding product features as part of a visual change.
