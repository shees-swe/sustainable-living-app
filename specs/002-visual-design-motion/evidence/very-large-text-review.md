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
