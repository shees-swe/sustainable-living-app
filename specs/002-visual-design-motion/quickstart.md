# Quickstart: Climate Instrument Validation

This is the implementation-phase validation guide. Do not interpret a
successful local/widget run as satisfying the on-device profile or visual
review gates.

## Prerequisites

- Flutter SDK matching the project's Dart `^3.13.7` constraint.
- Existing project dependencies installed.
- Physical Infinix X678B connected over USB; wireless debugging off and no
  duplicate adb-tls entry for the same device.
- Bundled font files present before verifying an offline launch.
- Before performance work, no visual/theme/screen changes have been applied.

## Phase 1: Baseline performance, before screen work

Enhance the integration-test harness to capture the required traces and
per-frame build/raster timings. In PowerShell, run each fixed scenario on the
connected Infinix in profile mode:

```powershell
flutter devices
flutter drive `
  --driver=test_driver/foundation_motion_test_test.dart `
  --target=integration_test/foundation_motion_test.dart `
  --profile `
  -d <device-id>
```

Run 3–5 repeats for each documented scenario, with at least 600 steady-state
frames per repeat. Scenarios cover onboarding through estimate result; Home
scrolling and all 11 module destinations; account registration/sign-in;
Settings/regional picker and privacy flows; and About Us, Gallery, and Contact
Us. Record exact actions and state so follow-up traces are comparable.

**Expected**: Impeller is verified active on-device. If it is inactive or its
status cannot be verified, stop and resolve the setup before interpreting the
results or starting screen work. A report under
`specs/002-visual-design-motion/evidence/` records the device, profile mode,
refresh rate, existing font setup, Impeller verification, repeat/frame counts,
and p50/p90/p95/p99 for build duration, raster duration, and total span
separately. Report per-thread p95 versus 16.67 ms. Do not optimize before the
report exists.
If the device or measurement harness is unavailable, stop and report the
blocker rather than substituting debug timings or a different device.

## Phase 2–4: Design, screens, and motion checks

### Phase 2 token foundation evidence

- The focused test `flutter test test/core/theme/app_theme_test.dart` passed
  all 6 tests. It checks every documented text/surface contrast pair against
  WCAG AA, verifies the sans and mono typography roles and shared theme
  tokens, and loads all eight IBM Plex TTF assets from `rootBundle` with
  `GoogleFonts.config.allowRuntimeFetching` set to `false`.
- `flutter analyze` completed with no issues.
- Offline font resolution was verified at the cold test-binding/theme
  initialization path: all required local TTF assets load and Google Fonts
  runtime fetching remains disabled. No device launch was performed in this
  phase.
- Bundled files: `assets/fonts/IBMPlexSans-Regular.ttf`,
  `assets/fonts/IBMPlexSans-Medium.ttf`,
  `assets/fonts/IBMPlexSans-SemiBold.ttf`,
  `assets/fonts/IBMPlexSans-Bold.ttf`,
  `assets/fonts/IBMPlexMono-Regular.ttf`,
  `assets/fonts/IBMPlexMono-Medium.ttf`,
  `assets/fonts/IBMPlexMono-SemiBold.ttf`,
  `assets/fonts/IBMPlexMono-Bold.ttf`, and `assets/fonts/OFL.txt`.

Run the full foundation suite and static analysis at each phase and at each
screen-batch checkpoint:

```powershell
flutter test
flutter analyze
```

**Expected**: All 104 foundation tests pass and analysis reports no issues.
The routed screens remain unchanged, and the Android system Back regression
checks from module, Settings, and estimate result still return to the expected
destination.

Run focused accessibility and motion tests:

```powershell
flutter test `
  test/accessibility/foundation_accessibility_test.dart `
  test/core/accessibility/reduced_motion_test.dart `
  test/core/motion/motion_spec_test.dart
```

Also run the existing onboarding/result and router tests plus new focused
widget checks for the result, font roles, and design tokens, using the
repository's standard test conventions.

**Expected**: Every existing screen and current state remains legible at Very
Large text with no clipping or overlap; contrast pairs meet `DESIGN.md`;
reduced motion presents settled values and does not strand or block
interactions. Result has no comparison rings or former three-reference
percentages; it has only the supported lower-bound benchmark, category bars,
rate/unit, and estimate coverage.

### Phase 3 Batch 3 validation

- Focused account, Settings, region picker, privacy policy, and privacy action
  widget tests passed, including their 200% text-scale layout checks.
- `test/app/router_test.dart` passed its About, Gallery, and Contact 200%
  text-scale coverage and system Back checks. The Home and module-destination
  tests also passed after moving their shared text-layout assertions to
  `test/support/text_layout_expectations.dart`.
- `flutter analyze` completed with no issues.
- Batch 3 did not run the full suite or any device tests. The Very Large text
  review is recorded in
  `specs/002-visual-design-motion/evidence/very-large-text-review.md`.

### Phase 4 result-screen validation

- `flutter test test/features/onboarding`: passed (28 tests), including the
  lower-bound budget share, share-bar cap, category total reconciliation,
  data-derived included/excluded coverage, demo labels, no-comparison checks,
  and the demo region-picker regression.
- `flutter test test/accessibility/foundation_accessibility_test.dart`: passed
  (5 tests), including the 200% onboarding accessibility check.
- `flutter analyze`: no issues.
- The result screen displays a budget bar only when the cited benchmark and
  estimate use compatible annual per-person CO2e units. No full-suite or
  device run was performed in this phase.

### Phase 5 motion pass (Part A)

- Centralized state-change duration (`0 ms`) and optional fade duration
  (`120 ms`) in `lib/core/motion/motion_spec.dart`. App route transitions use a
  linear 120 ms fade; `MediaQuery.disableAnimations` selects `NoTransitionPage`.
- Increased spring damping to an overdamped setting and tested monotonic
  settling without overshoot. Reduced-motion durations resolve to zero.
- Added `NumericTick` for the estimate total, using linear 120 ms interpolation
  and the shared IBM Plex Mono styles; it reaches its exact destination and
  displays it immediately when reduced motion is enabled.
- Added `AppSkeleton` to the estimate result loading state. Its solid-color
  effect and disabled switch animation are static, with a single accessible
  loading label. Existing success and error states are unchanged.
- `flutter test test/core/motion/motion_spec_test.dart
  test/core/motion/numeric_tick_test.dart
  test/core/accessibility/reduced_motion_test.dart test/app/router_test.dart`:
  passed (24 tests), including actions remaining responsive during a number
  tick and route transitions collapsing under reduced motion.
- `flutter test test/features/onboarding`: passed (28 tests).
- `flutter test test/accessibility/foundation_accessibility_test.dart`: passed
  (6 tests), including the result-loading placeholder's accessible status
  semantics.
- `flutter analyze`: no issues. The full suite was not run.
- Part B profile remeasurement is intentionally scheduled after the Part A
  commit; T041–T042 remain pending until measurement evidence is available.

## Final profile comparison

Repeat the Phase 1 profile command with identical device, renderer, refresh
rate, scenario, and repeat/frame thresholds. Store raw traces and final report
beside the baseline report.

**Expected**: Before/after distributions are comparable and reported
separately. Any fix has a concrete baseline finding. Each per-thread p95 is at
or below 16.67 ms, or the remaining failure is explicitly recorded and blocks
release readiness.

## Scope reminders

- Do not add features, routes, navigation changes, data, or emission factors.
- Preserve offline behavior, existing source/provenance disclosures, and
  reduced-motion behavior.
- EPA-style equivalency cards remain deferred.
