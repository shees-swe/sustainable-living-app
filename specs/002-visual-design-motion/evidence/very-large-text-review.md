# Very Large Text Review — Batch 1

## Scope

Review target: `lib/features/onboarding/presentation/onboarding_screen.dart`

## Review check

- Confirmed the region-selection section remains readable at 200% text scaling.
- Confirmed the demo-region flow still reveals the annual electricity and travel inputs without clipping or overlap.
- Confirmed the calculate action remains visible and tappable under large text conditions.
- Confirmed the onboarding copy stays within the available width and does not overlap adjacent control labels.

## Validation evidence

The focused onboarding widget test `test/features/onboarding/presentation/onboarding_screen_test.dart` includes a Very Large text scenario with `TextScaler.linear(2.0)` and asserts that the region selection and estimate input fields remain visible and that no exception is thrown while layout resolves.

## Result

Pass: the onboarding and region-selection batch retains a stable layout at Very Large text, with no clipping, overlap, or unusable controls introduced during the Climate Instrument styling pass.

## Batch 2 — Home and All Module Destinations

### Scope

Review targets: `lib/features/home/presentation/home_screen.dart`,
`lib/features/home/presentation/foundation_module_screen.dart`, and the 11
existing module destination routes that delegate to the shared foundation
screen.

### Review check

- Confirmed every Home module row and About Us remains visible and operable at
  200% text scaling.
- Confirmed all 11 module destination routes display their existing title and
  availability copy at 200% text scaling.
- Confirmed Home and module AppBar titles wrap to two lines with a toolbar
  height derived from the text scale, preventing content overlap.
- Confirmed no layout exceptions or overflow were reported in either large
  text test.
- Confirmed Home entries and all module routes remain present; module
  navigation semantics remain tappable.

### Validation evidence

- `flutter test test/features/home`: passed (8 tests across both focused
  files).
- `flutter test test/features/home/module_destination_test.dart`: passed
  (4 tests) when run directly.
- `flutter test test/app/router_test.dart`: passed (5 tests), including system
  Back from a module destination and Settings.
- `flutter analyze`: passed with no issues.

### Result

Pass: Home and all 11 module destinations use the shared Climate Instrument
list-row and hairline-divider treatment and remain readable at Very Large text.

## Batch 3 — Account, Settings, Privacy, and Secondary Destinations

### Scope

Review targets: `lib/features/account/presentation/account_screen.dart`,
`lib/features/settings/presentation/settings_screen.dart`,
`lib/features/settings/presentation/region_picker.dart`,
`lib/features/settings/presentation/privacy_policy_screen.dart`,
`lib/features/about/presentation/about_screen.dart`,
`lib/features/gallery/presentation/gallery_screen.dart`, and
`lib/features/contact/presentation/contact_screen.dart`.

### Review check

- Confirmed Account form labels, fields, actions, and feedback remain visible
  and non-overlapping at 200% text scaling.
- Confirmed Settings controls and region choices remain readable and
  operable at 200% text scaling.
- Confirmed the long-form privacy policy remains scrollable and readable at
  200% text scaling, including its later sections; numeric glyphs use the
  shared mono number style.
- Confirmed the privacy deletion dialog remains readable at 200% text scaling.
- Confirmed About, Gallery, and Contact content remains readable at 200%
  text scaling. AppBar titles wrap onto multiple lines rather than
  ellipsizing or overlapping content.
- Confirmed no test-reported text overflow or overlap in these screens.

### Validation evidence

- Focused tests passed: `test/features/account/account_flow_test.dart`
  (5 tests), `test/features/settings/settings_screen_test.dart` (4),
  `test/features/settings/region_settings_test.dart` (4),
  `test/features/settings/privacy_policy_screen_test.dart` (1),
  `test/features/settings/privacy_actions_test.dart` (6), and
  `test/app/router_test.dart` (6).
- The shared helper dependents also passed:
  `test/features/home/home_screen_test.dart` (4) and
  `test/features/home/module_destination_test.dart` (4).
- `flutter analyze`: no issues.
- No device tests or full-suite run were performed in this batch.

### Result

Pass: Batch 3 retains existing account, settings, privacy, and secondary
destination behavior while applying the shared Climate Instrument visual
tokens. All reviewed screens pass their Very Large text/no-clipping and
no-overlap checks.

## Phase 4 — Estimate Result

### Scope

Review target: `lib/features/onboarding/presentation/estimate_result_screen.dart`.

### Review check

- Confirmed the estimate total remains visible with its unit in IBM Plex Mono.
- Confirmed the compatible demo estimate shows the cited lower-bound budget
  share; its displayed percentage remains uncapped while the bar fill caps at
  100%.
- Confirmed unsupported unit combinations show no budget bar or numeric share.
- Confirmed each included category displays a horizontal bar, kg amount, and
  share; displayed category amounts reconcile to the total.
- Confirmed the coverage panel derives included and omitted categories from
  estimate category contributions and the selected region's available factor
  data, and does not infer categories absent from that data.
- Confirmed demo labeling is repeated on each result panel, and the factor and
  benchmark citation disclosures remain present.
- Confirmed there are no average-person comparisons, comparison rings, or EPA
  equivalency cards.
- Confirmed the AppBar, budget panel, breakdown, coverage, and factor
  disclosures have no text clipping or overlap at 200% text scaling.

### Validation evidence

- `flutter test test/features/onboarding`: passed (28 tests), including the
  result-screen Very Large text test and the regional-picker regression.
- `flutter test test/accessibility/foundation_accessibility_test.dart`: passed
  (5 tests).
- `flutter analyze`: no issues.
- No device tests or full-suite run were performed.

### Result

Pass: the estimate result now provides the cited lower-bound budget share
when units are compatible, data-derived category breakdown and coverage, and
preserved estimate/factor disclosures. The existing estimate total,
calculation value, factors, and navigation remain unchanged.
