# Tasks: Sustainable Living Guide App Foundation

**Input**: Design documents from `specs/001-app-foundation/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Tests are included because the feature request explicitly requires tests per implementation slice. For each story, add or update the focused test before its implementation and confirm the test fails for the missing behavior before making it pass.

**Organization**: Tasks are grouped by user story and kept in the requested integration order. User Stories 1 and 2 are both P1; Home/navigation is delivered first because onboarding depends on the running app shell. Home's module destinations are stubs only; detailed module workflows remain out of scope.

## Phase 1: Setup (Flutter Project Initialization)

**Purpose**: Create a runnable cross-platform Flutter project and establish reproducible baseline checks.

- [X] T001 Create the Flutter app scaffold in the repository root with Android and iOS platforms, Dart entry point, and standard generated platform projects in `pubspec.yaml`, `lib/main.dart`, `android/`, and `ios/`.
- [X] T002 Pin the selected latest-stable Flutter SDK and compatible dependency versions for Riverpod, go_router, Drift, Phosphor, fl_chart, and localization support in `.fvmrc`, `pubspec.yaml`, and `pubspec.lock`.
- [X] T003 Configure Dart analysis, package asset declarations, and English-first gen-l10n from ARB files in `analysis_options.yaml`, `l10n.yaml`, `pubspec.yaml`, and `lib/l10n/arb/app_en.arb`.
- [X] T004 Set Android minimum SDK to API 28 and set the iOS deployment target to the minimum supported by the pinned Flutter SDK in `android/app/build.gradle` and `ios/Runner.xcodeproj/project.pbxproj`.
- [X] T005 Run dependency resolution, analysis, Android debug build, and Android launch smoke check; record the exact commands and expected result in `specs/001-app-foundation/quickstart.md` and confirm APK output at `build/app/outputs/flutter-apk/app-debug.apk`.

**Checkpoint**: A clean Flutter scaffold analyzes, builds, and launches on an Android 9+ target; iOS project files are generated for macOS CI/device validation.

---

## Phase 2: Foundational (Shared Design, Motion, and Local Database)

**Purpose**: Complete cross-story infrastructure before feature slices; keep each checkpoint runnable.

- [X] T006 Add unit/widget tests for the green theme's semantic color roles, typography scale, and spacing tokens in `test/core/theme/app_theme_test.dart`.
- [X] T007 Implement the shared green theme, semantic Material color roles, typography, spacing, and corner-radius tokens in `lib/core/theme/app_theme.dart` and `lib/core/theme/design_tokens.dart`.
- [X] T008 Add unit/widget tests for shared spring retargeting, velocity handoff, interruption, and reduced-motion behavior in `test/core/motion/motion_spec_test.dart`.
- [X] T009 Implement the shared interruptible spring-motion utility, platform reduced-motion adapter, and lifecycle-safe controller helpers in `lib/core/motion/motion_spec.dart` and `lib/core/accessibility/reduced_motion.dart`.
- [X] T010 Add Drift schema and migration tests for initial database creation, preference/estimate/account table constraints, and foreign-key integrity in `test/core/data/database/app_database_test.dart` and `test/core/data/database/migration_test.dart`.
- [X] T011 Implement Drift database initialization, initial schema, generated migration snapshots, and transactional helpers for local accounts, credential verifiers, user preferences, and footprint estimates in `lib/core/data/database/app_database.dart`, `lib/core/data/database/tables/`, and `lib/core/data/database/migrations/`; `displayLanguageTag` defaults to English, `selectedRegionId` is nullable until it matches a verified bundled pack, and `reducedMotion` respects the platform setting.
- [X] T012 Run `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, and Android debug build; keep generated sources and build configuration consistent in `lib/core/data/database/`, `lib/l10n/`, and `pubspec.yaml`.

**Checkpoint**: Shared theme/motion services and versioned local persistence are available; the app still analyzes, tests, builds, and launches.

---

## Phase 3: User Story 2 - Explore the App Offline (Priority: P1)

**Goal**: Provide a stable Home and navigation shell with all required destinations, usable without account or network.

**Independent Test**: Launch the app offline as a guest; verify all 11 required module destinations and About Us are reachable from Home, while Gallery and Contact Us are reachable only through secondary navigation.

### Tests for User Story 2

- [X] T013 [P] [US2] Add module registry and required Home-entry inventory tests for exactly the 11 named modules and About Us in `test/features/home/module_destination_test.dart`.
- [X] T014 [P] [US2] Add router widget tests for guest access, all module routes, About Us, and secondary Gallery/Contact destinations in `test/app/router_test.dart`.
- [X] T015 [P] [US2] Add Home widget tests for accessible labels, route navigation, and offline rendering without login in `test/features/home/home_screen_test.dart`.

### Implementation for User Story 2

- [X] T016 [US2] Define the stable, localizable module destination registry with primary/secondary placement and foundation-stub status in `lib/features/home/domain/module_destination.dart`.
- [X] T017 [US2] Implement a stable go_router configuration for onboarding, Home, account, Settings, About, Gallery, Contact, and all 11 module destinations in `lib/app/router.dart`.
- [X] T018 [US2] Implement the app shell and Home screen using the design tokens, Riverpod scope, Phosphor icons, and all required primary module entries in `lib/app/app.dart` and `lib/features/home/presentation/home_screen.dart`.
- [X] T019 [US2] Implement explicit secondary navigation entries and offline foundation destination screens in `lib/features/about/presentation/about_screen.dart`, `lib/features/gallery/presentation/gallery_screen.dart`, `lib/features/contact/presentation/contact_screen.dart`, and `lib/features/carbon_footprint_tracker/presentation/module_destination_screen.dart`, `lib/features/eco_friendly_product_suggestions/presentation/module_destination_screen.dart`, `lib/features/sustainable_living_challenges/presentation/module_destination_screen.dart`, `lib/features/certifications_guide/presentation/module_destination_screen.dart`, `lib/features/waste_reduction_tracker/presentation/module_destination_screen.dart`, `lib/features/recipes_meal_planning/presentation/module_destination_screen.dart`, `lib/features/energy_conservation_tips/presentation/module_destination_screen.dart`, `lib/features/eco_travel_suggestions/presentation/module_destination_screen.dart`, `lib/features/community_journal/presentation/module_destination_screen.dart`, `lib/features/progress_dashboard/presentation/module_destination_screen.dart`, and `lib/features/educational_content/presentation/module_destination_screen.dart`.
- [X] T020 [US2] Pass router, Home, and offline widget tests and confirm `flutter analyze`, Android debug build, and app launch succeed for the Home slice in `lib/app/router.dart`, `lib/features/home/`, and `test/features/home/`.

**Checkpoint**: Home navigation works offline for guests; module internals are not implemented by this feature.

---

## Phase 4: User Story 1 - Get a Footprint Estimate as a Guest (Priority: P1)

**Goal**: Let a guest complete the short estimate and review the estimate with selected-region, global, and methodology-qualified 1.5°C references before any account wall.

**Independent Test**: With schema-valid sourced reference fixtures and network disabled, complete the estimate in under 60 seconds; confirm three clearly labeled, comparable rings, exact text values, source/date/period details, and no login prompt.

### Tests for User Story 1

- [X] T021 [P] [US1] Add unit tests for estimate input validation, annual CO2e totals, units, rounding, incomplete answers, and invalid factor handling in `test/features/onboarding/domain/footprint_calculator_test.dart`.
- [X] T022 [P] [US1] Add unit tests for reference comparison compatibility, source lookup, and unavailable/missing-value states in `test/features/onboarding/domain/reference_comparison_test.dart`.
- [X] T023 [P] [US1] Add onboarding widget tests for guest entry, region selection before estimate questions, skip behavior, completion, demo-only labeling for fixture results, ring labels, and no login wall; verify the result screen displays the actual calculation factor(s), source, and publication year in `test/features/onboarding/presentation/onboarding_screen_test.dart`.

### Implementation for User Story 1

- [X] T024 [US1] Define versioned estimate answers, completion state (`complete` or `incomplete`), result units, assumptions, and reference comparison value types in `lib/features/onboarding/domain/footprint_estimate.dart` and `lib/features/onboarding/domain/reference_value.dart`.
- [X] T025 [US1] Implement pure footprint calculation and input validation against the test data fixtures; enforce “Nonnegative CO2e amount; do not round before comparison calculation” and normalized explicit units in `lib/features/onboarding/domain/footprint_calculator.dart`.
- [X] T026 [US1] Implement the reference comparison service that matches period, unit, source, and accounting boundary and returns `available` or `unavailable` states; an unavailable value is never drawn as zero and never uses a cross-region substitution in `lib/features/onboarding/domain/reference_comparison.dart`.
- [X] T027 [US1] Implement guest estimate persistence and startup hydration through the Drift estimate table without creating or requiring an account in `lib/features/onboarding/data/footprint_estimate_repository.dart`.
- [X] T028 [US1] Implement data-driven, local fixture region selection before the short guest questionnaire (without implying a verified launch-region list), including completion/skip states, accessible labels, and app-shell navigation in `lib/features/onboarding/presentation/onboarding_screen.dart` and `lib/app/router.dart`.
- [X] T029 [US1] Implement three comparison-ring presentation with fl_chart, shared motion, exact accessible text values, source/date/period disclosure, explicit unavailable rendering, and an inspectable list of actual calculation factors with each source and publication year in `lib/features/onboarding/presentation/comparison_rings.dart`.
- [X] T030 [US1] Integrate the onboarding result screen with the calculator, selected region, reference service, persisted estimate, and guest Home flow; mark fixture-based results demo-only until verified regional data is integrated in US4 in `lib/features/onboarding/presentation/estimate_result_screen.dart` and `lib/app/router.dart`.
- [X] T031 [US1] Pass calculation and onboarding widget tests with region selection before estimate, visible factor/source disclosure, and demo-only fixture labeling offline; then run `flutter analyze`, Android debug build, and app-launch smoke check for the onboarding slice in `test/features/onboarding/` and `lib/features/onboarding/`.

**Checkpoint**: Guests can complete and revisit an estimate; integration with released regional packs is completed in User Story 4.

---

## Phase 5: User Story 3 - Choose Local Account Use and Control Personal Data (Priority: P2)

**Goal**: Add optional local registration/login, privacy policy, user-controlled export, and confirmed deletion without gating public browsing.

**Independent Test**: Register and log in offline, verify passwords are not stored in plaintext, browse as a guest without logging in, export personal data, and confirm deletion returns the app to guest state.

### Tests for User Story 3

- [X] T032 [P] [US3] Add credential verifier tests for unique random salts, Argon2id parameter persistence, correct/incorrect passwords, and rejection of plaintext persistence in `test/features/account/data/password_hasher_test.dart`.
- [X] T033 [P] [US3] Add account repository and widget tests for registration, duplicate normalized identifiers, login failures, local throttling, and guest browsing in `test/features/account/account_flow_test.dart`.
- [X] T034 [P] [US3] Add privacy tests for policy availability, allowlisted export contents, cancelled deletion, confirmed deletion, account cascade, and guest reset in `test/features/settings/privacy_actions_test.dart`.

### Implementation for User Story 3

- [X] T035 [US3] Select and pin a maintained Argon2id implementation compatible with Android and iOS in `pubspec.yaml` and `pubspec.lock`; benchmark OWASP's `19 MiB memory, 2 iterations, parallelism 1` floor on the slowest supported device and retain algorithm/version/cost metadata.
- [X] T036 [US3] Implement credential creation/verification with `argon2id`, a unique cryptographically random per-account salt, and persisted algorithm version/cost metadata; store only the KDF output, never plaintext or reversible ciphertext, in `lib/features/account/data/password_hasher.dart`.
- [X] T037 [US3] Implement the local account repository and credential storage using the exact data-model constraints: `loginIdentifier` is “Required, unique after normalization”; `createdAt` is “Required”; verifier salt is “Unique cryptographically random”; algorithm is `argon2id`; and account deletion cascades in `lib/features/account/data/account_repository.dart` and `lib/core/data/database/tables/local_accounts.dart`.
- [X] T038 [US3] Implement registration/login forms, useful local failure states, failed-attempt throttling, and optional account routing while preserving public guest routes in `lib/features/account/presentation/account_screen.dart` and `lib/app/router.dart`.
- [X] T039 [US3] Add a localized, readable privacy policy resource and in-app policy screen in `assets/content/privacy_policy_en.md` and `lib/features/settings/presentation/privacy_policy_screen.dart`.
- [X] T040 [US3] Implement a versioned allowlist export from a consistent Drift read transaction, excluding credential verifiers and keys, in `lib/features/settings/data/user_data_exporter.dart`.
- [X] T041 [US3] Implement confirmed transactional account/data deletion, database close/file cleanup, guest-state reset, and platform backup exclusions for private local data in `lib/features/settings/data/user_data_deleter.dart`, `lib/core/data/database/app_database.dart`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/res/xml/backup_rules.xml`, `android/app/src/main/res/xml/data_extraction_rules.xml`, and the iOS app delegate at `ios/Runner/AppDelegate.swift`.
- [X] T042 [US3] Implement Settings privacy actions for policy, export, confirmation/cancellation, deletion status, and guest return in `lib/features/settings/presentation/settings_screen.dart`.
- [X] T043 [US3] Pass account and privacy tests offline; verify exported data excludes credential fields and that Android build, app launch, and `flutter analyze` succeed for this slice in `test/features/account/`, `test/features/settings/`, and `lib/features/settings/`.

**Checkpoint**: Optional local accounts and user data controls work offline; account authentication is not a requirement for browsing.

---

## Phase 6: User Story 4 - Personalize Language and Regional Data (Priority: P2)

**Goal**: Externalize all UI strings, default to English, allow explicit region selection, and supply cited, bundled regional factors/content/currency to the estimate.

**Independent Test**: With network disabled, select each available bundled region and verify its cited electricity/transport/recipe data, regional average and currency; change display language separately without changing the selected region.

### Tests for User Story 4

- [X] T044 [P] [US4] Add regional data-pack parser tests for schema/version checks, required provenance, factor units/validity, source resolution, and rejection of incomplete packs in `test/core/data/regions/region_pack_parser_test.dart`.
- [X] T045 [P] [US4] Add region selection tests for persisted choice, language-region independence, currency formatting, and no silent fallback to another region in `test/core/data/regions/region_selection_test.dart`.
- [X] T046 [P] [US4] Add widget tests for region picker, English default, localization coverage, and region-driven estimate/currency updates in `test/features/settings/region_settings_test.dart`.

### Implementation for User Story 4

- [X] T047 [US4] Implement validation of bundled regional packs against `contracts/regional-data-pack.schema.json`, including schema version, pack version, shared factor-catalog version, and required fields in `lib/core/data/regions/region_pack_parser.dart`.
- [X] T048 [US4] Implement the single canonical versioned factor catalog and regional repository; make packs reference canonical `factorId` values, allow region-specific overrides only with their own value, source, and publication year, and reject silent catalog duplication or redefinition in `lib/core/data/regions/emission_factor.dart` and `lib/core/data/regions/region_repository.dart`.
- [X] T049 [US4] Source-audit the explicit launch-region release decision; include a region only when both cited grid factors and a cited regional average are available, and record citations, publication years, factor validity periods, units, method, attribution/license, regional average boundary, transport factors, recipe claims, and ISO 4217 currency in `assets/data/regions/<region-id>.json`.
- [X] T050 [US4] Bundle schema-valid `assets/data/regions/<region-id>.json` files and `assets/data/foundation-references.json`; verify each pack references canonical factor IDs, any regional factor override has its own source and year, all references resolve, and no factor is silently duplicated or substituted from another region.
- [X] T051 [US4] Implement the locally available region catalog and persisted explicit region selection independently of display locale in `lib/core/data/regions/region_catalog.dart`, `lib/features/settings/data/user_preferences_repository.dart`, and `lib/features/settings/presentation/region_picker.dart`.
- [X] T052 [US4] Move Home, onboarding, account, Settings, and navigation copy into English ARB resources and verify all user-facing strings have localization keys in `lib/l10n/arb/app_en.arb`, `lib/app/`, and `lib/features/`.
- [X] T053 [US4] Integrate selected-pack factors and reference values with onboarding comparison rings and format savings with the selected pack's ISO currency code in `lib/features/onboarding/` and `lib/features/settings/`.
- [X] T054 [US4] Pass region/parser/localization tests offline and verify region switching updates regional values without changing display language in `test/core/data/regions/`, `test/features/settings/`, and `test/features/onboarding/`.
- [X] T055 [US4] Run `flutter gen-l10n`, `flutter analyze`, all focused tests, Android debug build, and launch smoke check with all bundled packs enabled in `lib/l10n/`, `assets/data/regions/`, and `pubspec.yaml`.

**Checkpoint**: The selected region supplies cited local data and currency; the estimate uses region-specific data without coupling it to language.

---

## Phase 7: User Story 5 - Use the App Accessibly and Comfortably (Priority: P2)

**Goal**: Ensure the foundation screens respect accessibility preferences and keep all motion interruptible and performant.

**Independent Test**: Complete onboarding and Home navigation with reduced motion enabled and at enlarged text; verify controls remain operable, information remains available, and release-mode interactions meet the 60 fps criterion.

### Tests for User Story 5

- [X] T056 [P] [US5] Add accessibility widget tests for type scaling, contrast roles, touch-target bounds, focus order, and semantic ring descriptions in `test/accessibility/foundation_accessibility_test.dart`.
- [X] T057 [P] [US5] Add reduced-motion tests for Android and iOS signals, motion interruption, and unchanged task completion in `test/core/accessibility/reduced_motion_test.dart` and `test/core/motion/motion_spec_test.dart`.
- [X] T058 [P] [US5] Add release performance test scenarios and frame-budget acceptance documentation for onboarding/Home transitions on Android and iOS in `integration_test/foundation_motion_test.dart` and `specs/001-app-foundation/quickstart.md`.

### Implementation for User Story 5

- [X] T059 [US5] Apply semantic labels, text scaling, contrast-safe theme roles, and minimum accessible tap areas to Home, onboarding, account, and Settings controls in `lib/features/home/`, `lib/features/onboarding/`, `lib/features/account/`, and `lib/features/settings/`.
- [X] T060 [US5] Integrate system reduced-motion signals into shared transitions and ensure active gestures remain interruptible without dropping or blocking input in `lib/core/accessibility/reduced_motion.dart`, `lib/core/motion/motion_spec.dart`, and `lib/app/`.
- [ ] T061 [US5] Run accessibility widget tests and profile release-mode animation performance on representative physical Android and iOS devices; resolve frame budget, semantics, contrast, or touch-target failures in `integration_test/`, `test/accessibility/`, and `specs/001-app-foundation/quickstart.md`. Measured on 2026-11-09 with the Infinix connected over USB only and wireless debugging off: two `flutter drive --profile` runs completed, each with a 5-frame sample. Run 1 p95FrameSpanUs=136023; Run 2 p95FrameSpanUs=111894. Both fail the unchanged 16667 µs budget. T061 remains pending; re-measure during the design phase after the screens are rebuilt. iOS profiling requires macOS/Xcode or an iOS device.

**Checkpoint**: PENDING — accessibility, reduced-motion, analysis, unit/widget tests, debug APK build, and the Infinix USB launch check passed. Android release-mode motion was measured in two runs on 2026-11-09 (5 frames per run): p95FrameSpanUs=136023 and 111894, both above the unchanged 16667 µs budget. Re-measure during the design phase after the screens are rebuilt. iOS profile verification could not run in this Windows environment. Do not treat Phase 7 as release-complete until T061 passes on representative Android and iOS devices.

---

## Phase 8: Polish & Cross-Cutting Release Gates

**Purpose**: Validate the integrated foundation, record usability/design evidence,
prepare the Foundation deliverables, and verify that deferred v1 release gates
are tracked without implementing module internals here.

- [X] T062 [P] Verify every calculator result and visible content claim resolves to a cited source/date and that incompatible average boundaries are labeled contextual in `test/core/data/regions/` and `assets/data/`.
- [X] T063 [P] Verify privacy policy localization, export allowlist, backup behavior, deletion caveats, and user-facing privacy copy in `assets/content/privacy_policy_en.md` and `test/features/settings/`.
- [X] T064 Validate regional and shared reference assets against both JSON schemas and add a repeatable validation command to `specs/001-app-foundation/quickstart.md` and `tool/validate_region_data.dart`.
- [X] T065 Run the full `flutter analyze` and `flutter test` suites and resolve all failures across `lib/`, `test/`, and `integration_test/`.
- [ ] T066 Build the Android release APK, verify the release artifact at `build/app/outputs/flutter-apk/app-release.apk`, and run the complete offline acceptance flow on Android 9+ in `android/` and `specs/001-app-foundation/quickstart.md`. Pending: the release APK was verified and installed over USB, but Step 3 failed the comparable-rings criterion; language selection, invalid-pack injection, reduced-motion operation, and credential exclusion from storage/logs/export could not be verified. See the dated step-by-step device record in `quickstart.md`.
- [ ] T067 Run the iOS release build and complete offline acceptance flow on macOS CI or an iOS device using `ios/` and `integration_test/`; record any platform-specific constraints in `specs/001-app-foundation/quickstart.md`. Pending: this Windows environment has no macOS/Xcode or iOS device.
- [X] T068 Update the final validation steps and expected outcomes after successful full-device checks in `specs/001-app-foundation/quickstart.md`.
- [X] T069 Prepare and verify the standalone test-data deliverable, including sourced regional/reference fixtures and test instructions, without including application source code in `deliverables/test-data/` and `specs/001-app-foundation/quickstart.md`.
- [X] T070 Prepare the project documentation package without source code, and document the demo-video-friendly guest estimate, Home navigation, regional selection, and privacy flows in `deliverables/documentation/` and `deliverables/demo-flows.md`.
- [ ] T071 Run a first-time-user study of the guest estimate and record participant count, completion outcomes, and timing; verify at least 9 out of 10 participants complete and view all three comparison rings in under 60 seconds without assistance in `specs/001-app-foundation/evidence/usability-study.md`. Pending: script and blank results log are prepared; real participants and measured results are required.
- [ ] T072 Review every Foundation screen for consistent visual identity, readable typography, clear spacing, contrast, and accessibility; record reviewer, screens checked, findings, and disposition against SC-009 in `specs/001-app-foundation/evidence/design-review.md`. Pending: requires the user's manual visual verdict and review dispositions.

**Checkpoint**: PENDING — T061 Android release-motion measurement (and iOS profiling), T066 Android offline device acceptance, T067 iOS release/device acceptance, T071 real-participant usability study, and T072 user visual review remain open. The IGES v11.6 reconciliation remains a separate v1 release gate. See the Phase 8 validation record in `quickstart.md`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; creates the Flutter project and proves the first Android build/launch.
- **Foundational (Phase 2)**: Depends on Setup; design tokens and shared motion are completed before database and feature UI; database and localization foundations block story implementation.
- **User Stories (Phases 3-7)**: Depend on Phase 2. Stories are deliberately sequenced to keep every increment runnable and to follow the requested order.
- **Polish (Phase 8)**: Depends on all five user stories and completed regional/reference data.

### User Story Dependencies

- **US2 (P1, Phase 3)**: First story after foundations; Home and routes give all later stories a runnable shell.
- **US1 (P1, Phase 4)**: Follows US2 so onboarding integrates into the real app shell. It is tested with schema-valid fixtures; production region selection and pack integration are completed in US4.
- **US3 (P2, Phase 5)**: Follows onboarding; adds optional account and privacy controls while public guest routes remain available.
- **US4 (P2, Phase 6)**: Follows Settings/privacy as requested; supplies region selection, bundled data and production regional integration for the estimate.
- **US5 (P2, Phase 7)**: Depends on the integrated Home, onboarding, account, Settings, and regional UI to perform cross-screen accessibility and performance verification.

### Within Each Slice

- Write focused tests before the corresponding implementation tasks; confirm the new behavior fails first.
- Keep each task limited to a small set of cohesive files and run analysis/tests/build after each slice checkpoint.
- Do not begin detailed implementation of the 11 module workflows in this foundation feature.
- Treat the exact sourced 1.5°C per-person target and the initial regional pack coverage as release data gates; do not invent values to make tests pass.

### Parallel Opportunities

- T013-T015 are independent Home/router/widget test files and may be authored in parallel before implementation.
- T021-T023, T032-T034, T044-T046, and T056-T058 are story-specific test files that may be authored in parallel; implementation starts after their expected failing state is confirmed.
- T062-T064 are independent final evidence/schema/privacy checks after the corresponding implementation files are stable.
- T069-T072 are independent release-preparation/evidence tasks once their required implementation and test data are stable.
- Core UI slices remain sequential: theme precedes shared motion consumers, then database, Home, onboarding, account/privacy, regional integration, and accessibility release checks.

## Parallel Example: User Story 2

```text
Task: T013 Add module registry inventory tests in test/features/home/module_destination_test.dart
Task: T014 Add navigation route tests in test/app/router_test.dart
Task: T015 Add Home widget tests in test/features/home/home_screen_test.dart
```

## Parallel Example: User Story 4

```text
Task: T044 Add regional pack parser tests in test/core/data/regions/region_pack_parser_test.dart
Task: T045 Add region selection tests in test/core/data/regions/region_selection_test.dart
Task: T046 Add region/localization widget tests in test/features/settings/region_settings_test.dart
```

## Implementation Strategy

### MVP First

1. Complete Phase 1 and Phase 2; verify an Android build and launch after each checkpoint.
2. Complete US2 so Home and all required destinations are demonstrable offline.
3. Complete US1 with region selection before the estimate and sourced fixtures; label fixture-based results demo-only and verify the no-login flow.
4. **Do not release the estimate as production-ready until US4 verifies the selected-region pack and methodology-qualified 1.5°C value.**
5. Add US3 local accounts and privacy controls, then US4 verified packs/localization, then US5 accessibility and release performance gates.
6. Complete the v1 Release Gates and Polish-phase deliverables/evidence before v1 release; Foundation tasks do not implement deferred module internals.

### Incremental Delivery

1. Setup + foundational services: app builds and launches.
2. US2: navigable offline Home foundation.
3. US1: guest-first estimate and comparison presentation using validated test fixtures.
4. US3: optional local account and privacy pack.
5. US4: region selector, localized copy, cited regional packs, and production estimate integration.
6. US5 + polish: accessibility, reduced-motion, performance, and Android/iOS release checks.

## Notes

- Every task uses the required checkbox, sequential ID, optional `[P]`, story label where applicable, and concrete file path.
- Story task counts: US1 11; US2 8; US3 12; US4 12; US5 6.
- The task list does not create `tasks.md`-owned source files; implementation produces the specified paths in later work.
- The 1.5°C target is methodology-dependent. If no compatible cited annual per-person target is approved, stop the release-data task rather than substitute an invented or incomparable value.
- The initial launch region set is a release decision; include only regions with both cited grid factors and a cited regional average.
