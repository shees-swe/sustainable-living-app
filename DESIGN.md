# Verdant Design System

## Overview

Verdant is the human-centric, calm, and polished design foundation for the Sustainable Living app. Moving away from stark clinical palettes, Verdant uses organic deep-forest greens, warm cream background surfaces, rich amber highlights, and soft card corners to evoke nature, sustainability, and trust.

The interface remains accessible, legible, and honest:
- All honesty lines, disclosures, and regional limitations remain completely visible and clear.
- High contrast compliant with WCAG AA.
- Preserves all functional routing, data models, and offline operations.

```yaml
design:
  name: Verdant
  color:
    primary:
      forestGreen: "#1B5E20"
      forestDeep: "#0D3B0F"
      forestLight: "#E8F5E9"
    accent:
      amber: "#E65100"
      amberLight: "#FFF3E0"
    surface:
      cream: "#FAFAF5"
      cardSurface: "#FFFFFF"
      cardBorder: "#E8E8E0"
      tagBackground: "#F1F8E9"
    text:
      primary: "#1A1C1E"
      secondary: "#5C5F63"
      hero: "#FFFFFF"
    semantic:
      positiveSaved: "#2E7D32"
      emissions: "#E65100"
      warning: "#C62828"
  typography:
    family:
      sans: "IBM Plex Sans"
      mono: "IBM Plex Mono"
    weights:
      regular: 400
      medium: 500
      semibold: 600
      bold: 700
  shape:
    radiusSmall: 8
    radiusMedium: 16
    radiusLarge: 24
  components:
    heroGradient: "LinearGradient(forestGreen -> forestDeep)"
    sectionCard: "Rounded rectangle with subtle border and cardSurface"
```

## Colors & Hierarchy

- **Forest Green (`#1B5E20`) & Forest Deep (`#0D3B0F`)**: Core identity colors used for navigation app bars, hero headers, primary buttons, and major progress bars.
- **Warm Cream (`#FAFAF5`)**: Soft, easy-on-the-eyes background color for scaffolds and viewports.
- **Card Surface (`#FFFFFF`) & Card Border (`#E8E8E0`)**: Structured sections framed in rounded, bordered cards to present information with clean separation.
- **Amber Accent (`#E65100` / `#FFF3E0`)**: Highlights important notes, warnings, emissions metrics, and callouts without alarming users.
- **Forest Light (`#E8F5E9`)**: Soft background for secondary chips, tags, and progress tracks.

## Typography

- **IBM Plex Sans**: Body, labels, headers, and UI copy (bundled offline asset).
- **IBM Plex Mono**: Numbers, units, dates, and metrics for precision and tabular alignment (bundled offline asset).

## Components & Layout

- **Hero Header**: Linear gradient header across screens providing identity and high visual hierarchy.
- **Section Cards**: Grouped inputs, details, tips, and lists in unified rounded containers (`BorderRadius.circular(16)`).
- **Metric Badges & Tags**: Rounded pills with subtle alpha tints (`#F1F8E9`) for categories and metadata.
- **Honesty Disclosures**: Specially tinted banners for demo-region limitations, missing factors, and local-only data warnings.
