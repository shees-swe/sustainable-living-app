# Implementation Plan: Sustainable Living Guide App Foundation

**Branch**: `001-app-foundation` | **Date**: 2026-11-06 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-app-foundation/spec.md`

## Summary

Build the cross-platform, offline-first Flutter foundation: app shell and
feature-based navigation; guest onboarding with three sourced comparison rings;
optional on-device accounts and privacy controls; bundled regional data and
English-first localization; and shared design, motion, and accessibility
foundations. The Home screen exposes all required module destinations, but their
domain workflows and content remain outside this plan. See [research.md](./research.md)
for fixed decisions and source material.

## Technical Context

**Language/Version**: Dart, using the latest stable Flutter SDK available when
implementation begins; pin the selected SDK and dependency versions for
reproducible builds.

**Primary Dependencies**: Flutter; Riverpod; go_router; Drift; vendored Phosphor
icons; fl_chart; Flutter gen-l10n with ARB resources. Phosphor Regular, Bold, and
Fill fonts and the exact codepoints used by the app are vendored under `assets/`
from the MIT-licensed `phosphor_flutter` 2.1.0 package; font family names match
that package. This avoids its incompatibility with Flutter 3.47.9: Flutter 3.44
made `IconData` final, while `phosphor_flutter` 2.1.0 extends it and has no
compatible release. `cryptography_plus` 3.0.0 is pinned for local Argon2id:
its RFC 9106 implementation is pure Dart and supports Android and iOS, and its
pub.dev release was published 2026-03-02. The implementation uses OWASP's
19 MiB, two-iteration, parallelism-one floor. On the available Infinix X678B
(Android 14/API 34), three measured hashes after one warm-up took 1,162 ms,
1,212 ms, and 1,423 ms (median 1,212 ms).

**Storage**: Drift/SQLite for local user records, onboarding answers, preferences,
and password verifiers. Bundled, versioned data files provide regional packs and
shared global/1.5°C comparison references. Regional factors use one canonical,
versioned factor catalog. Each regional pack references canonical factor IDs and
may include region-specific factor values, each with its own source and publication
year; packs never silently duplicate or redefine the catalog. No backend or
network fetch is required.

**Testing**: `flutter analyze`; Dart unit tests for estimate calculations,
factor lookup, region selection, password verification, export, and deletion;
widget tests for onboarding and Home; targeted migration, localization,
accessibility, offline, and navigation tests; release-mode performance profiling
on representative Android and iOS devices.

**Target Platform**: Android API 28 (Android 9) and later; iOS at the minimum
deployment target supported by the pinned stable Flutter SDK.

**Project Type**: Cross-platform mobile application.

**Performance Goals**: Meet the 60 fps release criterion for standard animated
interactions on supported devices. At 60 Hz, profile against a 16.7 ms frame
budget. Complete the guest footprint estimate in under 60 seconds in usability
testing.

**Constraints**: Fully usable offline; no application backend; guest estimate
before any login gate, with region selection first; local-only accounts; hashed
passwords only; no unsourced environmental values; selected data region remains
independent of display language; respect reduced motion; accessible foundation
screens; detailed module internals are deferred to their own plans. Until verified
regional data is integrated in US4, estimate fixtures are labeled demo-only and
must not be presented as production-ready.

**Scale/Scope**: Foundation shell and route destinations for 11 modules plus
About Us, with Gallery and Contact Us secondary; first-run region selection and
footprint estimate; local account, Settings privacy actions, bundled regional
data, localization and shared visual/motion/accessibility systems. No full module
workflows, network services, synchronization, or online account recovery.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Result |
|---|---|---|
| I. Flutter and Dart Cross-Platform Delivery | One Flutter/Dart codebase targets Android 9+ and iOS. | PASS |
| II. Offline-First Simplicity | No backend; foundation data and account flows work offline. | PASS |
| III. Local Data and Bundled Content | Drift stores user data; regional and static data ship bundled. | PASS |
| IV. Feature-First Architecture | Feature folders; Riverpod, go_router, fl_chart, and Phosphor stay consistent. | PASS |
| V. Research-Backed Trust | One canonical versioned factor catalog; displayed values have provenance and dates. | PASS |
| VI. Low-Friction Retention | Guest estimate is available before login and targets under 60 seconds. | PASS |
| VII. Physics-Based Motion | Shared interruptible physics motion, reduced-motion support, and 60 fps gate. | PASS |
| VIII. Global-First Localization | English default; externalized strings; region-selected cited data and currency. | PASS |
| IX. Privacy and Community Safety | Foundation provides local password verifier, user export/delete, privacy screen, and guest browsing. | PASS for Foundation scope — full v1 compliance gated on the Release Gates list. |
| X. Accessibility | Type, contrast, touch targets, and reduced motion are release checks. | PASS |
| XI. Verified Quality Gates | Analysis, calculation tests, onboarding/Home widget tests, and build checks. | PASS |
| XII. Brief Coverage and Deliverables | Foundation provides module destinations, About Us, and secondary destinations. | PASS for Foundation scope — full v1 compliance gated on the Release Gates list. |
| XIII. Clear, Agent-Led Design | Foundation design decisions use the green identity without user design prompts. | PASS |

The Foundation scope does not implement module internals or the deferred v1
requirements below. Constitution-check results for Principles IX and XII are
limited to Foundation scope; the listed release dependencies must be satisfied
before v1 release.

## V1 Release Gates

The following constitution MUST requirements are outside this Foundation
implementation scope, but are explicit dependencies for v1 release. Each must be
implemented in its relevant module plan and verified before release:

- **Community Journal safety (Principle IX)**: The on-device journal/feed includes
  terms, report, and block interfaces.
- **Per-module offline behavior (Principles II and III)**: All 11 module
  workflows and their bundled tips, recipes, certification guides, and articles
  work offline; user records are stored locally through Drift/SQLite.
- **Retention features (Principle VI)**: Routine manual logging takes under 10
  seconds per day and supports one-tap quick-log with sensible defaults; v1
  includes XP, levels, badges, streaks, and streak freezes; offers no more than
  one anchored daily prompt (“After [existing habit], I will [action]”) and a
  short reflection; and ranks rule-based recommendations by the user's largest
  impact category.
- **Cross-module discovery (Principle XII)**: Search, sort, and filter are
  available as specified by the project brief.
- **Delivery package (Principle XII)**: Provide an APK, test data, demo-video-
  friendly flows, and project documentation that does not include source code.

The initial launch region set is also a release decision: include only regions
with both cited electricity grid factors and a cited regional average. Do not
assume or invent the region list during Foundation implementation.

## Project Structure

### Documentation (this feature)

```text
specs/001-app-foundation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── foundation-ui.md
│   ├── regional-data-pack.schema.json
│   └── foundation-references.schema.json
└── tasks.md                         # Created by /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── accessibility/
│   ├── data/
│   │   ├── database/
│   │   └── regions/
│   ├── localization/
│   │   └── app_en.arb
│   ├── motion/
│   └── theme/
└── features/
    ├── onboarding/
    ├── home/
    ├── account/
    ├── settings/
    ├── about/
    ├── gallery/
    ├── contact/
    ├── carbon_footprint_tracker/
    ├── eco_friendly_product_suggestions/
    ├── sustainable_living_challenges/
    ├── certifications_guide/
    ├── waste_reduction_tracker/
    ├── recipes_meal_planning/
    ├── energy_conservation_tips/
    ├── eco_travel_suggestions/
    ├── community_journal/
    ├── progress_dashboard/
    └── educational_content/
assets/
└── data/
    ├── regions/
    └── foundation-references.json
test/
├── core/
│   ├── data/
│   ├── localization/
│   └── motion/
└── features/
    ├── onboarding/
    ├── home/
    ├── account/
    └── settings/
```

**Structure Decision**: Use one Flutter application with a small `app/` shell and
shared `core/` foundations. Keep every module in its own `lib/features/` folder;
foundation work creates reachable module destinations without implementing the
module's domain behavior. Keep tests grouped by shared foundation and feature.
Static regional packs and common comparison references are bundled assets. Packs
reference IDs in the one canonical factor catalog; any region-specific factor
value carried by a pack includes its own provenance and does not silently copy
the catalog.
