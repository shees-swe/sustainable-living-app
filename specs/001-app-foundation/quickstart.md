# Foundation Validation Quickstart

This guide validates the implemented foundation on supported devices. It does
not validate the detailed behavior of the 11 module destinations.

## Prerequisites

- Latest stable Flutter SDK and bundled Dart SDK pinned for the project.
- Android SDK/emulator or device targeting API 28 or later.
- For iOS simulator/device builds: macOS, Xcode, and an iOS deployment target
  supported by the pinned Flutter SDK.
- Dependencies and generated Drift/localization sources available locally.
- Network access may be used for initial dependency setup; the app's validation
  flows themselves must not require network access.

## Setup and Static Checks

From the repository root:

```powershell
flutter --version
flutter pub get
dart run build_runner build
dart run drift_dev make-migrations
flutter gen-l10n
flutter analyze
```

**Expected**: Flutter and Dart versions match the repository pin; dependencies
resolve; generated sources are current; `flutter analyze` reports no issues.

## Regional and Reference Data Validation

Run the schema and source-link validation from the repository root:

```powershell
dart run tool/validate_region_data.dart
```

The command validates every regional pack listed in
`assets/data/regions/index.json`, the shared foundation references, and the
standalone test-data copies against their respective JSON schemas. It also
checks that cited sources and referenced factors resolve. A nonzero exit code
or printed error identifies a failed path and constraint. No transport or
recipe factors are synthesized to satisfy validation.

Phase 1 validation commands and outcomes:

```powershell
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug
```

**Verified**: dependency resolution and localization generation completed;
analysis reported no issues; the scaffold widget test passed; and the debug APK
was created at `build/app/outputs/flutter-apk/app-debug.apk`. The APK was
installed and launched successfully on an Infinix X678B Android phone.

Phase 2 validation commands and outcomes:

```powershell
dart run build_runner build
dart run drift_dev make-migrations
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug
```

**Verified**: Drift generated code and the version 1 schema snapshot were
created; localization generation completed; analysis reported no issues; all
18 tests passed; and the debug APK was built at
`build/app/outputs/flutter-apk/app-debug.apk`. The current session has no
connected Android device, so the rebuilt APK was not reinstalled for another
launch check; the Phase 1 launch check was completed on an Infinix X678B.

Phase 3 validation commands and outcomes:

```powershell
flutter pub get
flutter gen-l10n
flutter test
flutter analyze
flutter build apk --debug
flutter devices
```

**Verified**: the incompatible `phosphor_flutter` dependency was removed;
registry, router, Home, and offline destination tests passed as part of the full
27-test suite; analysis reported no issues; and the debug APK was built at
`build/app/outputs/flutter-apk/app-debug.apk`. `flutter devices` found no
connected Android target in this session, so the Phase 3 APK launch smoke check
was pending at that time. The rebuilt APK was subsequently installed and
launched on an Infinix X678B Android phone; the Home title and all 11 module
destinations were confirmed, as was navigation to module stubs and About Us.

Phase 4 validation commands and outcomes:

```powershell
flutter gen-l10n
flutter test
flutter analyze
flutter build apk --debug
flutter devices --machine
```

**Verified**: localized guest onboarding, estimate calculation and persistence,
comparison compatibility, rings, unavailable-reference rendering, factor
provenance, app startup restoration, and existing navigation all passed; all 47
tests passed, analysis reported no issues, and the Android debug APK was built
at `build/app/outputs/flutter-apk/app-debug.apk`. The current device list
contained no Android target during the build session; the user subsequently
installed and launched that APK and confirmed the onboarding and guest estimate
flow.
Every numeric factor and comparison in the Phase 4 fixture is synthetic and
explicitly labeled demo-only; no production regional or 1.5°C values are
asserted.

Phase 6 regional-data validation:

```powershell
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug
flutter devices --machine
adb devices -l
```

**Verified**: localized regional onboarding uses the explicitly selected pack;
Pakistan's cited 0.347 kg CO2/kWh factor is displayed and calculated as CO2,
not CO2e; unsupported transport input is omitted; demo fixtures remain marked
demo-only; and the 2024 Pakistan/global averages and 2030 lifestyle target are
shown with provenance as contextual, non-comparable references. Focused
regional/onboarding tests passed, all 91 tests passed, `flutter analyze` reported
no issues, localization generation completed, and the Android debug APK was
built at `build/app/outputs/flutter-apk/app-debug.apk`. The initial USB launch
check was blocked because no Android device was detected; after the Infinix
X678B was reconnected, `flutter install --debug -d 1026825381000731` installed
the APK successfully, and the user confirmed that the app opened and ran. The
Pakistan transport factor and recipe-impact data remain unavailable because no
cited values were supplied. The Ember dataset discrepancy and IGES v11.6
cross-check remain recorded caveats/release gates in [research.md](./research.md).

## Automated Tests

```powershell
flutter test
```

Run focused suites while iterating:

```powershell
flutter test test/features/onboarding
flutter test test/features/home
flutter test test/core/data
flutter test test/features/account
```

**Expected**: Unit coverage verifies footprint calculations, sourced factor
lookup and pack provenance, region-pack selection, local password verification,
data export and deletion, and migration behavior. Widget coverage verifies
onboarding, comparison values and semantics, language behavior, and required
Home destinations. Device/integration tests cover offline startup, account use,
and privacy actions.

## Device Validation

1. Run the app on Android API 28+ and an iOS simulator/device.
2. Disable network access and cold-launch the app.
3. Select a bundled country/region, complete the estimate, and verify three
   comparable, labeled rings: selected-region average, global average, and
   methodology-qualified 1.5°C-aligned budget. Verify source, date, period, and
   assumptions for each value.
4. Skip onboarding and confirm guest browsing remains available without login.
5. Visit Home; open all 11 module destinations and About Us; locate Gallery and
   Contact Us through secondary navigation.
6. Register and log in locally. Confirm that browsing content does not require
   the account and that no plaintext password appears in persistent storage,
   logs, or export.
7. From Settings, read the privacy policy, export personal data, cancel a
   deletion request, then confirm deletion and verify return to guest state.
8. Change display language and selected region independently. Confirm region
   changes update relevant factors/currency and language changes do not change
   the selected region.
9. Exercise missing and invalid regional data: no unsupported numeric value or
   silent cross-region fallback may appear.
10. Enable reduced motion and repeat navigation/gesture interactions. Verify
    the path remains operable and transitions are interruptible.

## Release Performance and Accessibility

- Run the navigation frame-timing scenario on a connected Android device.
  Connect the Infinix over USB only and turn wireless debugging off before
  starting `flutter drive`; do not leave the same phone listed on an adb-tls
  transport as well as USB, because duplicate transports caused prior driver
  stalls and VM-service disposals.

  ```powershell
  flutter drive `
    --driver=test_driver/foundation_motion_test_test.dart `
    --target=integration_test/foundation_motion_test.dart `
    --profile `
    -d <device-id>
  ```

  The scenario covers onboarding-to-Home and Home-to-module transitions and
  fails if the 95th-percentile frame span exceeds 16.667 ms. Run it on
  physical Android and iOS devices; do not use debug-mode timings as release
  evidence.
- Profile a release build on representative physical Android and iOS devices
  using Flutter DevTools' Performance view. Verify standard interactions meet
  the 60 fps criterion (approximately 16.7 ms/frame at 60 Hz); do not use
  debug-mode timings as release evidence. Capture the onboarding-to-result and
  Home-to-module transitions; check the 95th-percentile frame span against
  16.667 ms and resolve any missed frame budget before release.
- Run the focused accessibility and motion tests:

  ```powershell
  flutter test `
    test/accessibility/foundation_accessibility_test.dart `
    test/core/accessibility/reduced_motion_test.dart `
    test/core/motion/motion_spec_test.dart
  ```

  These cover tap-target, label, contrast, keyboard focus, type scaling,
  semantic ring, platform reduced-motion, and interruptible spring checks.
- Check text scale, contrast, touch targets, semantic ring descriptions, keyboard
  and screen-reader navigation as applicable, and reduced-motion behavior.
- Confirm each foundation screen remains usable in English and the localization
  test locale, including long and right-to-left strings.

## Final Foundation Polish Checkpoint (2026-11-09)

### Completed checks

| Check | Command / evidence | Result |
|---|---|---|
| Static analysis | `flutter analyze` | Passed; no issues found. |
| Unit/widget suite | `flutter test` | Passed; 102 tests. The device integration test is not part of this suite. |
| Regional/reference schemas | `dart run tool/validate_region_data.dart` | Passed for bundled and standalone test-data fixtures, including source/factor links. |
| Android release package | `flutter build apk --release` | Passed; `build/app/outputs/flutter-apk/app-release.apk` created (57.4 MB). |
| Android debug package | `flutter build apk --debug` | Passed; `build/app/outputs/flutter-apk/app-debug.apk` created. |
| Infinix USB launch | `flutter run --debug -d 1026825381000731 --no-resident` | Passed on Infinix X678B / Android 14. Flutter installed the debug APK as an update over the previously installed profile build and launched it. |
| Region-heading regression | Onboarding widget regression test | Passed after removing the duplicate parent heading; the regional picker renders one “Choose a region” heading. |

### Pending checks and release gates

- **T061 Android motion profile — measured and not met**: On 2026-11-09, with
  the Infinix connected over USB only and wireless debugging off,
  `flutter drive --profile` completed twice. Run 1 reported
  `frames=5, p95FrameSpanUs=136023`; Run 2 reported
  `frames=5, p95FrameSpanUs=111894`. The budget remains 16667 µs; both runs
  fail the gate. Each result is based on a 5-frame sample. The earlier driver
  stalls and VM-service disposals occurred while the phone appeared on both
  USB and adb-tls transports; the duplicate transport was the root cause.
  T061 remains pending, not complete. Re-measure during the design phase after
  the screens are rebuilt.
- **T061 iOS motion profile**: Not run because iOS profile testing requires
  macOS/Xcode or an iOS device. This is an environment limitation, not a pass
  or a measured failure.
- **T066 Android offline acceptance**: Release APK build succeeded, and the
  debug app launch succeeded on the Infinix. The complete offline acceptance
  flow on a physical Android device has not been run; T066 remains pending.
- **T067 iOS release acceptance**: Not run; this Windows environment does not
  provide macOS/Xcode or an iOS device.
- **T071 usability study / SC-001**: Study script and results log are prepared
  in `evidence/usability-study.md`. No real participants were recruited or
  tested; the 9-of-10 under-60-second criterion remains unevaluated.
- **T072 design review / SC-009**: Screen checklist is prepared in
  `evidence/design-review.md`. The visual verdict and dispositions remain
  pending the user's manual review; automated tests are not substituted.
- **V1 data release gate**: The IGES List of Grid Emission Factors v11.6
  reconciliation has not been completed. No replacement or unsourced
  transport/recipe emission factors were added. Transport and recipe impact
  values remain unavailable/demo-labelled.

The final task count is **67/72 complete**. T061, T066, T067, T071, and T072
remain unchecked for the reasons above. Android motion measurement is complete
for this pass but fails its frame budget; re-measure after the screens are
rebuilt in the design phase. Do not mark the Foundation release checkpoint
complete until the pending validations and the IGES data gate have been
resolved.

## References

- [Data model](./data-model.md)
- [Foundation UI contract](./contracts/foundation-ui.md)
- [Regional data-pack schema](./contracts/regional-data-pack.schema.json)
- [Shared comparison-reference schema](./contracts/foundation-references.schema.json)
- [Research decisions and sources](./research.md)
