# Tasks: Climate Instrument Visual Design and Motion

**Input**: Design documents from `/specs/002-visual-design-motion/`

**Prerequisites**: [spec.md](./spec.md), [plan.md](./plan.md),
[research.md](./research.md), [data-model.md](./data-model.md),
[quickstart.md](./quickstart.md), root [DESIGN.md](../../DESIGN.md)

**Organization**: Tasks follow the binding measurement → token foundation →
existing-screen batches → result redesign → motion → final verification order.
Story labels map each implementation task to its spec user story; shared
measurement and token prerequisites are unlabelled.

## Phase 1: Setup — T061 Baseline Measurement

**Purpose**: Capture and verify the required pre-change baseline before any
screen, theme, font, or animation work. Keep the existing app appearance and
font setup unchanged during these runs.

**Gate**: Do not proceed to Phase 2 until every baseline scenario has
3–5 repeats with at least 600 steady-state frames per repeat, separate build
and raster percentiles, and verified active Impeller on the Infinix X678B.

- [X] T001 Update `integration_test/foundation_motion_test.dart` and `test_driver/foundation_motion_test_test.dart` to run repeatable `traceAction` profile scenarios for onboarding-to-estimate, Home scrolling and all 11 module destinations, account, Settings/privacy, and secondary destinations; collect at least 600 steady-state `FrameTiming` samples per scenario per repeat for 3–5 repeats, reporting p50/p90/p95/p99 for buildDuration, rasterDuration, and totalSpan separately, and p95 pass/fail against 16.67 ms per thread.
- [X] T002 Launch the unchanged app with `flutter run --profile --verbose -d <Infinix-device-id>` on the physical Infinix X678B, verify the renderer startup log identifies Impeller as active, and record the log evidence, device/OS, refresh rate, USB-only ADB setup, and current font setup in `specs/002-visual-design-motion/evidence/impeller-verification.md`; if inactive or unverifiable, document the blocker there and stop before screen work.
- [X] T003 Run every scenario implemented in `integration_test/foundation_motion_test.dart` via `flutter drive --driver=test_driver/foundation_motion_test_test.dart --target=integration_test/foundation_motion_test.dart --profile -d <Infinix-device-id>` for 3–5 repeats, verify at least 600 steady-state frames per repeat, and save raw traces plus separately reported per-scenario distributions and p95 results in `specs/002-visual-design-motion/evidence/baseline-report.md` and `specs/002-visual-design-motion/evidence/traces/`.
- [X] T004 [US4] Only if `specs/002-visual-design-motion/evidence/baseline-report.md` identifies a scenario with build or raster p95 above 16.67 ms, analyze that scenario's raw trace, record the measured gap and smallest justified fix in `specs/002-visual-design-motion/evidence/performance-fix-decision.md`, modify only the specific existing app file implicated by that evidence, and remeasure the identical scenario until every per-thread p95 passes; if a scenario cannot pass, stop and report the blocker before Phase 2. If every scenario passes, mark this task not applicable in that report and make no performance-only changes. Do not add `motor` without a measured concrete gap.

---

## Phase 2: Foundational — Design-Token Foundation

**Purpose**: Establish DESIGN.md as the single source for the theme, palette,
typography, spacing, shapes, and contrast before applying it to screens.

**Gate**: Verify all token text/background pairs meet WCAG AA, offline font
resolution works, `flutter analyze` is clean, and focused theme tests pass.
Do not run the full suite in this phase; reserve its single run for final
verification.

- [ ] T005 Add `google_fonts` to `pubspec.yaml`; bundle IBM Plex Sans weights 400/500/600/700 at `assets/fonts/IBMPlexSans-Regular.ttf`, `assets/fonts/IBMPlexSans-Medium.ttf`, `assets/fonts/IBMPlexSans-SemiBold.ttf`, and `assets/fonts/IBMPlexSans-Bold.ttf`, and IBM Plex Mono weights 400/500/600/700 at `assets/fonts/IBMPlexMono-Regular.ttf`, `assets/fonts/IBMPlexMono-Medium.ttf`, `assets/fonts/IBMPlexMono-SemiBold.ttf`, and `assets/fonts/IBMPlexMono-Bold.ttf`, with the applicable license at `assets/fonts/OFL.txt`; configure `GoogleFonts.config.allowRuntimeFetching = false` in `lib/main.dart` and register the locally bundled font assets without removing the existing Phosphor assets.
- [ ] T006 Implement all color, text-role, spacing, shape, divider, and elevation tokens from root `DESIGN.md` in `lib/core/theme/app_theme.dart`; configure `lib/app/app.dart` to use this single theme source app-wide, with cobalt as brand and emerald only for saved/positive states.
- [ ] T007 [P] Add focused token and typography-role assertions in `test/core/theme/app_theme_test.dart`, verifying the specified light surfaces, IBM Plex Sans text roles, IBM Plex Mono for numeric/unit/table figures, 8 px spacing increments, 4–8 px radii, no shadows, and offline font configuration.
- [ ] T008 At the token-foundation checkpoint, calculate and verify each configured text/surface ratio against root `DESIGN.md`, run `flutter test test/core/theme/app_theme_test.dart` and `flutter analyze`, and record an offline cold-launch font-resolution check in `specs/002-visual-design-motion/quickstart.md`; preserve the 104-test baseline and do not run `flutter test` without a selector here.

---

## Phase 3: User Story 1 — Existing-Screen Design Batches (Priority: P1)

**Goal**: Apply the shared Climate Instrument design to every existing screen
and state without changing navigation, data, factors, or features.

**Independent Test**: Complete each batch's focused widget/accessibility tests
and review every screen in that batch at Very Large text. Verify no clipping,
overlap, or inoperable controls; use the final suite and Android Back checks in
Phase 6 for global confirmation.

### Batch 1 — Onboarding and Region Selection

- [ ] T009 [US1] Apply the shared theme, list/divider hierarchy, spacing, and responsive Very Large text layout to `lib/features/onboarding/presentation/onboarding_screen.dart` without changing onboarding questions, region flow, or routes.
- [ ] T010 [US1] Extend `test/features/onboarding/presentation/onboarding_screen_test.dart` to cover the Climate Instrument onboarding and region-selection states at Very Large text, asserting no clipped text, overlap, or unusable control.
- [ ] T011 [US1] Verify Batch 1 with `flutter test test/features/onboarding/presentation/onboarding_screen_test.dart` and `flutter analyze`; record the Very Large text review for `lib/features/onboarding/presentation/onboarding_screen.dart` in `specs/002-visual-design-motion/evidence/very-large-text-review.md`.

### Batch 2 — Home and All Module Destinations

- [ ] T012 [P] [US1] Apply shared tokens and the list-row design to `lib/features/home/presentation/home_screen.dart` and `lib/features/home/presentation/foundation_module_screen.dart`, preserving every existing Home entry and destination.
- [ ] T013 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/carbon_footprint_tracker/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T014 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/eco_friendly_product_suggestions/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T015 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/sustainable_living_challenges/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T016 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/certifications_guide/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T017 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/waste_reduction_tracker/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T018 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/recipes_meal_planning/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T019 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/energy_conservation_tips/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T020 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/eco_travel_suggestions/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T021 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/community_journal/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T022 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/progress_dashboard/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T023 [P] [US1] Apply shared tokens, hairline dividers, and Very Large text wrapping to `lib/features/educational_content/presentation/module_destination_screen.dart` without changing its destination behavior.
- [ ] T024 [US1] Extend `test/features/home/home_screen_test.dart` and `test/features/home/module_destination_test.dart` with Very Large text/no-overlap assertions for Home and all 11 module destinations; run those focused tests and `flutter analyze`, and record Batch 2 review in `specs/002-visual-design-motion/evidence/very-large-text-review.md`.

### Batch 3 — Account, Settings, Privacy, and Secondary Destinations

- [ ] T025 [P] [US1] Apply shared tokens and Very Large text wrapping to `lib/features/account/presentation/account_screen.dart`, preserving the existing registration and sign-in actions and flow.
- [ ] T026 [P] [US1] Apply shared tokens and hairline list rows to `lib/features/settings/presentation/settings_screen.dart`, preserving every setting and its behavior.
- [ ] T027 [P] [US1] Apply shared tokens and Very Large text wrapping to `lib/features/settings/presentation/region_picker.dart`, preserving current region choices and selection behavior.
- [ ] T028 [P] [US1] Apply shared tokens and readable long-form typography to `lib/features/settings/presentation/privacy_policy_screen.dart`, preserving the existing policy text and privacy actions.
- [ ] T029 [P] [US1] Apply shared tokens and Very Large text wrapping to `lib/features/about/presentation/about_screen.dart` without adding content or navigation.
- [ ] T030 [P] [US1] Apply shared tokens and the specified empty-state language/layout to `lib/features/gallery/presentation/gallery_screen.dart` without adding gallery content.
- [ ] T031 [P] [US1] Apply shared tokens and Very Large text wrapping to `lib/features/contact/presentation/contact_screen.dart` without changing its existing availability message or navigation.
- [ ] T032 [US1] Extend `test/features/account/account_flow_test.dart`, `test/features/settings/settings_screen_test.dart`, `test/features/settings/region_settings_test.dart`, `test/features/settings/privacy_policy_screen_test.dart`, and `test/features/settings/privacy_actions_test.dart` with Very Large text/no-overlap coverage for changed Batch 3 screens; run those focused tests and `flutter analyze`, and record Batch 3 review in `specs/002-visual-design-motion/evidence/very-large-text-review.md`.

---

## Phase 4: User Story 3 — Estimate Result Redesign (Priority: P1)

**Goal**: Replace incomparable references and rings with the single cited
budget-share lower bound and honest self-context.

**Independent Test**: Run the result-screen widget and existing estimate-domain
tests; verify supported equivalent units only, correct lower-bound wording,
horizontal category bars, annual per-person rate/unit, included/excluded
coverage, existing source disclosures, and no rings or EPA equivalencies.

- [ ] T033 [US3] In `lib/features/onboarding/presentation/estimate_result_screen.dart`, remove the three-reference “%-vs-average” comparison and all `ComparisonRing` use; remove `lib/features/onboarding/presentation/comparison_rings.dart` and retire its ring-specific assertions in `test/features/onboarding/presentation/comparison_rings_test.dart`.
- [ ] T034 [US3] In `lib/features/onboarding/presentation/estimate_result_screen.dart`, show the existing 2.5 t CO2e/person/year-by-2030 benchmark as a budget-share bar only when existing estimate units and period are equivalent; label the result as a lower bound (“at least Y% of the 2030 budget”), and show no numeric share when equivalence cannot be established.
- [ ] T035 [US3] In `lib/features/onboarding/presentation/estimate_result_screen.dart`, add horizontal bars only for supported existing estimate categories, show the estimate's existing annual per-person rate and unit, and state what its inputs cover and leave out; preserve existing values, factors, assumptions, and source disclosures, with no EPA-style equivalency cards.
- [ ] T036 [US3] Create `test/features/onboarding/presentation/estimate_result_screen_test.dart` to verify budget-share gating/lower-bound wording, supported category bars, rate/unit, coverage and provenance, and absence of comparison rings and EPA cards; run it with `test/features/onboarding/domain/reference_comparison_test.dart` and `test/features/onboarding/domain/footprint_calculator_test.dart`, then run `flutter analyze` and record the result-screen Very Large text check in `specs/002-visual-design-motion/evidence/very-large-text-review.md`.

---

## Phase 5: User Stories 2 and 4 — Motion and Measured Performance Follow-Up

**Goal**: Make existing motion immediate or instrument-like, preserve reduced
motion, and use skeletons for current loading states.

**US2 Independent Test**: Exercise every changed motion/loading state with
reduced motion on and off; verify instant final state under reduced motion, no
bounce or overshoot, no blocked input, and correct loading completion/error
behavior.

- [ ] T037 [US2] Update `lib/core/motion/motion_spec.dart` and `lib/core/accessibility/reduced_motion.dart` so existing state changes are immediate, optional fades are approximately 120 ms, and applicable animations use interruptible `SpringSimulation`/`animateWith` with no bounce or overshoot while preserving the platform reduced-motion preference.
- [ ] T038 [US2] Add a reusable numeric count/tick motion helper at `lib/core/motion/numeric_tick.dart` and focused tests at `test/core/motion/numeric_tick_test.dart`; use Plex Mono-ready numeric values, settle exactly at the destination, and bypass the count animation when reduced motion is enabled.
- [ ] T039 [US2] Add `skeletonizer` to `pubspec.yaml`, implement a reusable loading placeholder in `lib/core/widgets/app_skeleton.dart`, and replace existing loading content in `lib/features/onboarding/presentation/estimate_result_screen.dart` without changing its existing success/error flow.
- [ ] T040 [US2] Extend `test/core/accessibility/reduced_motion_test.dart`, `test/core/motion/motion_spec_test.dart`, and `test/accessibility/foundation_accessibility_test.dart` to verify changed spring/fade/count behavior, reduced-motion completion, input responsiveness, and loading placeholder semantics; run these focused tests and `flutter analyze`.

### US4 — Measured Performance Follow-Up (Priority: P2)

**Goal**: Compare the completed design against the Phase 1 baseline under
identical profile conditions and close only data-supported performance gaps.

**Independent Test**: Re-run the exact Phase 1 scenarios with Impeller active,
3–5 repeats, and at least 600 steady-state frames per repeat; compare separate
build/raster p95 against 16.67 ms per thread.

- [ ] T041 [US4] After Phases 2–5, rerun every scenario in `integration_test/foundation_motion_test.dart` on the same Infinix X678B profile-mode setup with Impeller verified active, identical actions, 3–5 repeats, and at least 600 steady-state frames per repeat; save separate before/after build, raster, and totalSpan percentile comparisons and per-thread p95 decisions in `specs/002-visual-design-motion/evidence/final-performance-report.md`.
- [ ] T042 [US4] If `specs/002-visual-design-motion/evidence/final-performance-report.md` reports any per-thread p95 above 16.67 ms, trace that exact failing scenario, document its measured cause and smallest justified mitigation in `specs/002-visual-design-motion/evidence/performance-fix-decision.md`, change only the implicated existing source file, and rerun that scenario with Phase 1 sample/repeat requirements; if all scenarios pass, record no further optimization and do not add `motor`.

---

## Phase 6: Polish — Final Verification and Device Launch

**Purpose**: Run the one full foundation suite, analyzer, navigation and
accessibility regressions, and debug build/on-device launch verification.

**Gate**: All 104 foundation tests pass; `flutter analyze` is clean; system
Back works from a module, Settings, and estimate result; reduced motion and
Very Large text checks pass; debug app launches on the Infinix. No new
features/routes, navigation changes, or data/factor changes.

- [ ] T043 Run the complete `flutter test` suite exactly once from the repository root and confirm all 104 foundation tests pass; record the command and result in `specs/002-visual-design-motion/quickstart.md`.
- [ ] T044 Run `flutter analyze` from the repository root and resolve all findings; record the clean result in `specs/002-visual-design-motion/quickstart.md`.
- [ ] T045 Run `test/app/router_test.dart` and verify Android system Back from a module, Settings, and estimate result returns to the expected Home/destination behavior; confirm the fix from commit `8a64545` is intact and record the device check in `specs/002-visual-design-motion/quickstart.md`.
- [ ] T046 Run `test/core/accessibility/reduced_motion_test.dart`, `test/core/motion/motion_spec_test.dart`, and `test/accessibility/foundation_accessibility_test.dart`; confirm reduced-motion behavior, contrast/touch-target checks, and the complete Very Large text review recorded in `specs/002-visual-design-motion/evidence/very-large-text-review.md` have no failures.
- [ ] T047 Build the debug APK with `flutter build apk --debug`, install and launch it on the physical Infinix X678B, walk the existing onboarding/result, Home/module, Settings, and secondary-screen flows without network access, and record build artifact path and launch outcome in `specs/002-visual-design-motion/quickstart.md`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 — measurement**: T001 → T002 → T003 → conditional T004. No visual,
  theme, font, or animation changes may precede the verified baseline.
- **Phase 2 — tokens**: T005 → T006; T007 can proceed in parallel with T006
  after T005; T008 requires T005–T007.
- **Phase 3 — visual application**: T009 → T010 → T011; then T012–T023 may be
  implemented in parallel after the theme gate, followed by T024. T025–T031
  may be implemented in parallel after T024, followed by T032.
- **Phase 4 — result (US3)**: T033 → T034 → T035 → T036; depends on the shared
  theme and onboarding batch but remains an independently testable result
  increment.
- **Phase 5 — motion/performance (US2, US4)**: T037 precedes T038–T039; T040
  follows T037–T039; T041 depends on T003, T040, and completed Phases 2–4;
  conditional T042 follows T041.
- **Phase 6 — final verification**: T043–T047 follow all implementation and
  performance work. Run the full suite only at T043.

### User Story Dependencies

- **US1 (P1)**: Starts after the measurement and theme prerequisites; its screen
  batches are sequentially gated as shown above.
- **US3 (P1)**: Starts after the theme and onboarding screen batch; independently
  validates estimate result presentation while preserving existing calculations.
- **US2 (P1)**: Starts after the shared theme; its number and loading states
  integrate with US1/US3 screens but do not alter navigation or data.
- **US4 (P2)**: Baseline measurement occurs before all stories; any conditional
  baseline fix follows T003. Final comparison follows all design/motion work.

### Independent Test Criteria

- **US1**: Navigate every existing screen in its batch at Very Large text and
  pass the batch's focused widget tests without clipping, overlap, navigation,
  data, or factor changes.
- **US2**: Run the focused motion/accessibility tests with reduced motion on
  and off; verify settled values, no bounce/overshoot, unblocked input, and
  correct loading outcomes.
- **US3**: Run `estimate_result_screen_test.dart` and existing estimate-domain
  tests; verify only an equivalent-unit lower-bound share, supported horizontal
  category bars, annual rate/unit, coverage/provenance, and no rings/EPA cards.
- **US4**: Compare repeated Infinix profile traces with 600+ steady-state
  frames per repeat, separate build/raster percentiles, verified Impeller, and
  p95 at or below 16.67 ms per thread.

### Parallel Opportunities

- T007 may run parallel with T006 after font/dependency setup T005.
- In the Home/modules batch, T012–T023 touch distinct screen files and can be
  split among workers; T024 waits for the full batch.
- In the account/settings/secondary batch, T025–T031 touch distinct screen
  files and can run in parallel; T032 waits for the full batch.
- No performance-fix work can run in parallel with baseline capture or before
  T003 produces the evidence.
- The result screen's T033–T035 tasks share `estimate_result_screen.dart` and
  are intentionally sequential.

## Implementation Strategy

### MVP First

1. Complete T001–T003 and the measurement gate; execute T004 only if its
   measured condition is met.
2. Complete T005–T008 to make `DESIGN.md` executable as the shared theme.
3. Implement and verify the onboarding batch (T009–T011) as the smallest
   user-visible Climate Instrument increment.
4. Continue remaining screen batches, then complete the separate result phase,
   motion pass, measured performance follow-up, and final verification.

### Incremental Delivery

1. Measurement evidence blocks premature optimization and defines the baseline.
2. Shared theme/tokens unblock consistent application without changing routes.
3. Each screen batch is verified for Very Large text and affected tests before
   moving on.
4. Result, motion, and performance remain independently verifiable phases.
5. Run the complete 104-test suite once at final verification; use focused
   selectors at earlier phase gates to keep test runs economical.

## Notes

- `[P]` tasks touch distinct files and have no dependency on unfinished work.
- Every implementation task is story-labeled; setup/foundation/final tasks are
  unlabelled per the Spec Kit checklist convention.
- All tasks preserve the explicit scope: no features, routes, navigation,
  estimate data, or emission-factor changes.
- No `motor` task is scheduled because the plan identifies no concrete measured
  gap; T004/T042 explicitly forbid speculative adoption.
