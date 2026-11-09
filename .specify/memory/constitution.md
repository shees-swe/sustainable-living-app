<!--
Sync Impact Report: 1.1.0 -> 2.0.0
Modified principles:
  V. Research-Backed Trust (regional factor requirements generalized)
  VIII. Pakistan-First Localization -> VIII. Global-First Localization
Added principles: none
Added sections: none
Removed sections: none
Deferred items: none
-->
# Sustainable Living Guide App Constitution

## Core Principles

### I. Flutter and Dart Cross-Platform Delivery
The mobile app MUST use Flutter and Dart as a single codebase for Android and iOS.
Android support MUST include Android 9 and later. Native Java or Kotlin code MUST
NOT be introduced unless Flutter cannot meet a specific brief requirement; any such
exception MUST identify the unmet requirement and why Flutter cannot satisfy it.

### II. Offline-First Simplicity
Version 1 MUST have no backend and MUST work fully offline for trackers, tips,
recipes, and educational content. The Community Forum module MUST ship in version 1
as an on-device journal/feed, not a network service. Implementations MUST use the
fewest moving parts that satisfy the brief and MUST NOT introduce infrastructure or
abstractions without a demonstrated requirement.

### III. Local Data and Bundled Content
User data, including carbon logs, waste logs, challenge progress, and XP, MUST be
stored locally in SQLite through Drift. Static tips, recipes, certification guides,
and articles MUST ship as bundled local data files and MUST NOT require server
fetches. Local storage and bundled content MUST support the offline behavior in
Principle II.

### IV. Feature-First Architecture
The app MUST use a feature-folder structure with one folder per module, Riverpod for
state management, go_router for navigation, fl_chart for charts, and Phosphor for
icons. These choices MUST remain consistent across the app. Architecture MUST stay
feature-separated and MUST NOT add clean-architecture layers or other ceremony
without a concrete need.

### V. Research-Backed Trust
Every emission factor MUST live in one versioned factor table that records its
source and publication year. Energy, food, and regional electricity grid factors
MUST use citable sources appropriate to the user's selected country or region,
including relevant DEFRA/DESNZ data and Poore and Nemecek (2018) where applicable.
Each calculated result MUST show the factor used and its source. All informational
content and sustainability claims MUST carry a source and date; unsupported impact
numbers MUST NOT be shown. User-facing claims MUST explain assumptions and
uncertainty rather than imply unsupported precision.

### VI. Low-Friction Retention
Routine manual logging MUST take under 10 seconds per day and provide one-tap
quick-log actions with sensible defaults. A guest MUST be able to complete a
60-second onboarding estimate before encountering a login requirement. Version 1
MUST include XP, levels, badges, streaks, and streak freezes. It MUST offer no more
than one anchored daily prompt, using the form “After [existing habit], I will
[action],” and a short reflection. Rule-based recommendations MUST be ranked by
the user's own largest impact category. These limits reduce logging burden while
supporting sustained, user-directed progress.

### VII. Physics-Based Motion
Motion MUST use interruptible spring physics, velocity handoff, momentum
projection, and 1:1 drag response where applicable. Translucent materials MAY be
used when they improve clarity. Animations MUST NOT be linear or block user input.
Full reduced-motion support and 60 fps motion performance are release criteria;
observable jank is a defect.

### VIII. Global-First Localization
English MUST be the default content language, and all user-facing strings MUST be
externalized for localization. Regional data MUST be selected according to the
user's chosen country or region through cited regional data packs. Packs MUST
provide relevant electricity grid factors, transport modes, recipes, and currency
for their region. Localized content and factors MUST meet the source and date
requirements in Principle V. The app MUST NOT privilege one country's language,
units, or examples as a universal requirement.

### IX. Privacy and Community Safety
Passwords, if authentication is required by the brief, MUST be hashed and MUST
NEVER be stored in plaintext. Users MUST be able to export and delete all their
data from within the app, and a privacy policy screen MUST be available in version
1. Authentication MUST be limited to flows that the brief requires; browsing
content MUST NOT require login. The on-device journal/feed MUST include terms,
report, and block interfaces from version 1. Data collection and retention MUST be
limited to what the app needs, with consent for any sharing or external integration.

### X. Accessibility
The app MUST provide a legible type scale, sufficient color contrast, properly
sized touch targets, and reduced-motion support. Accessibility MUST be explicitly
checked and pass before release; it is a release gate, not an optional polish task.

### XI. Verified Quality Gates
Each feature MUST build and run successfully before work proceeds to the next
feature. `flutter analyze` MUST complete cleanly. Each tracker MUST have at least
one unit or widget test covering its calculation logic, including carbon factors,
totals, and XP where applicable. Changes MUST include relevant regression,
integration, accessibility, and user-flow checks; unverified behavior MUST NOT be
released.

### XII. Brief Coverage and Deliverables
The delivered app MUST include all 11 functional modules specified by the project
brief, plus Home, About Us, Image Gallery, and Contact Us. Search, sort, and filter
MUST be available as specified by the brief. Every required module MUST be
reachable from Home; Gallery and Contact Us MUST remain secondary rather than
primary Home destinations. Delivery planning MUST include an APK, test data,
demo-video-friendly user flows, and project documentation that does not include
source code.

### XIII. Clear, Agent-Led Design
The implementation agent MUST make routine UI decisions without requiring the
user to choose among visual alternatives. The interface MUST be clean, legible,
accessible, and straightforward to navigate, with a green visual identity that
does not rely on a generic template. Design MUST comply with the motion and
accessibility requirements in Principles VII and X.

## Sustainability & Product Constraints
The app MUST support informed, practical sustainable choices without guilt,
greenwashing, inflated claims, or misleading analytics. Recommendations and impact
summaries MUST be explainable, reversible, and aligned with user intent. Product
decisions MUST prioritize user value and measurable environmental impact over
feature count or novelty.

## Delivery & Review Workflow
Every change MUST be reviewed for brief compliance, tests, accessibility, data
handling, and sustainability claims. Documentation and user-facing configuration
MUST be updated alongside related changes. Required quality gates MUST NOT be
bypassed. Release readiness MUST be supported by evidence that the feature builds,
runs, and behaves as specified.

## Governance
This Constitution governs product, engineering, and design decisions for the
Sustainable Living Guide App. Amendments require a documented rationale, a summary
of affected principles, and review by the responsible maintainers before adoption.

Versions follow semantic versioning. A MAJOR increment marks backward-incompatible
governance or principle changes. A MINOR increment marks a new principle, section,
or material expansion of requirements. A PATCH increment marks clarifications,
wording changes, or other non-semantic corrections. Each adopted amendment MUST
update the version and last-amended date.

Compliance MUST be reviewed during change review, release planning, and
architecture decisions. Contributors MUST verify alignment with this Constitution
before release. Unresolved conflicts MUST be documented and escalated to the
responsible maintainers.

**Version**: 2.0.0 | **Ratified**: 2026-11-06 | **Last Amended**: 2026-11-06
