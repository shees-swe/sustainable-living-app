# Implementation Plan: Climate Instrument Visual Design and Motion

**Branch**: `002-visual-design-motion` | **Date**: 2026-11-11 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-visual-design-motion/spec.md`

## Summary

Apply the fixed Climate Instrument design and motion direction to every
existing foundation screen. Start by improving and running the T061 profile
measurement harness on the Infinix X678B, before any screen changes. Record
separate build and raster percentiles, per-thread p95, and on-device Impeller
status. Do not select or plan a performance fix until those results exist.

Next, establish one shared theme/token source and bundled offline IBM Plex Sans
and IBM Plex Mono fonts. Apply that foundation across all existing screens
without changing routes, data, or factors. Replace the result comparison with
the single cited 2030 lifestyle-budget lower-bound bar and self-context panels;
remove the three-reference percentages and rings. Finish with the restrained
motion and loading-state pass, retaining reduced-motion behavior.

The required root [DESIGN.md](../../DESIGN.md) is created in this planning
phase. Its proposed palette passes WCAG AA for every text/surface pair; exact
ratios and rationale are recorded there.

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter (project constraint `sdk: ^3.13.7`)

**Primary Dependencies**: Flutter Material, `integration_test`, existing
`flutter_test`, and `google_fonts` for locally bundled IBM Plex Sans and IBM
Plex Mono. `skeletonizer` is required for loading placeholders. Use Flutter's
`SpringSimulation` and `animateWith` for applicable motion. Add `motor` only
after a concrete post-baseline gap demonstrates its need; no such gap is
established at planning time.

**Storage**: No new persistence or backend. Existing estimate and preference
data remain authoritative and unchanged. Performance evidence is a local
feature-plan artifact.

**Testing**: All 104 foundation tests, `flutter analyze`, focused widget and
accessibility tests, and profile-mode integration tests on the Infinix X678B.
The profile harness uses `traceAction` and frame timings; report build and
raster distributions separately.

**Target Platform**: Existing Android 9+ and iOS targets; required T061
re-measurement is on the physical Infinix X678B Android device.

**Project Type**: Flutter mobile application; single codebase with feature-first
screens under `lib/features/`.

**Performance Goals**: On each measured scenario, collect at least 600
steady-state frames per repeat across 3–5 repeats. Report build-thread and
raster-thread percentiles separately; p95 for each thread must be at or below
16.67 ms. Record whether Impeller is active on the device.

**Constraints**: Measurement precedes every screen change and every
optimization. Keep the existing reduced-motion preference effective, support
Very Large text without clipping or overlap, preserve offline fonts, all
existing routes and the Android Back fix from commit `8a64545`, keep all 104
foundation tests green and `flutter analyze` clean, and add no feature, data, or
factor changes.

**Scale/Scope**: All current Foundation screens, routes, and existing states:
onboarding/region selection, estimate questionnaire and result, Home, all 11
module destinations, account registration/sign-in, Settings and regional
picker, privacy policy/actions, About Us, Gallery, and Contact Us. Include
existing loading, empty, confirmation, and error states. No new destination.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-research gate

- **Principles I–VI, VIII–XII**: Pass. The work remains within the existing
  Flutter app, offline model, architecture, sourced-data rules, localization,
  privacy boundaries, required module coverage, and quality gates. No data,
  factor, navigation, or product-scope change is planned.
- **Principle VII — Physics-Based Motion**: Pass with implementation
  constraints. Applicable motion remains interruptible and uses spring
  physics/`animateWith`, with velocity handoff, momentum projection, and 1:1
  drag response where applicable. Instant state changes and approximately
  120 ms fades are retained where appropriate; no linear motion, bounce,
  overshoot, or input blocking. Reduced motion is a release gate.
- **Principle X — Accessibility**: Pass with release gates. Verify contrast,
  all existing screens at Very Large text, touch targets, semantics, and
  reduced-motion behavior.
- **Principle XI — Verified Quality Gates**: Pass with release gates: all 104
  foundation tests remain green and `flutter analyze` remains clean in each
  implementation phase; device profile evidence is required before
  performance changes.
- **Principle XIII — Clear, Agent-Led Design**: Specific conflict requiring
  explicit disposition. Its current “green visual identity” requirement
  conflicts with this feature's fixed, user-selected Climate Instrument
  direction, which assigns cobalt as brand and emerald only to saved/positive
  data. This plan follows the feature-specific fixed design direction, not a
  green brand. That is a narrowly scoped exception to Principle XIII, not a
  general constitution amendment; the governing principle should be reconciled
  by maintainers before this direction is adopted as a permanent product-wide
  principle.

**Gate outcome**: Proceed on the basis of the explicit design decision and
documented Principle XIII exception. Do not weaken Principles VII or X.

### Post-design gate

- Shared design tokens include computed AA-passing contrast ratios for every
  text/background pair.
- The screen inventory covers every existing destination and state.
- The estimate result's single comparison is bounded to existing supported
  data; no mismatched units or unsupported category/factor values are inferred.
- Measurement-first ordering, no-optimization-before-evidence, reduced motion,
  Very Large text, 104-test/analyzer, and Back-navigation gates are preserved.

**Post-design gate outcome**: Pass subject to the same explicit Principle XIII
exception; there is no new constitutional or architectural violation.

## Phase 0: Research

Research decisions are recorded in [research.md](./research.md). There are no
unresolved technical clarifications. The first implementation activity remains
the measurement phase below; it must finish and produce evidence before any
screen work.

## Execution Phases and Gates

The following sequence is binding. **Apply every common gate at the end of
each phase and each screen batch**:

1. `flutter analyze` has no findings.
2. All 104 foundation tests pass.
3. Check every screen in the current batch at Very Large text: no clipping or
   overlap; controls remain operable.
4. Verify the existing Android system Back behavior from a module, Settings,
   and estimate result; the fix from commit `8a64545` must not regress.
5. No new feature or route, navigation change, or estimate/factor change.
6. Preserve offline operation and reduced-motion behavior.

### Phase 1 — T061 baseline measurement (first; before screen work)

1. Update the integration-test `traceAction` harness and frame collection
   before touching any screen, theme, or animation code. Use profile mode on
   the physical Infinix X678B. Keep USB-only ADB and disable wireless debugging
   to avoid the duplicate transport issue already recorded in the Foundation
   quickstart.
2. Define repeatable existing-flow scenarios: onboarding through the estimate
   result; Home scrolling and representative module destinations (exercise all
   11 module destinations); account registration/sign-in; Settings/regional
   picker and privacy flows; and About Us, Gallery, and Contact Us. Record the
   exact action sequence and app/device state for each.
3. For each scenario and each of 3–5 repeats, gather at least 600
   steady-state frames after the interaction settles. Capture a
   `traceAction` timeline and frame timings. Report p50/p90/p95/p99 for
   `buildDuration`, `rasterDuration`, and `totalSpan` separately; report p95
   against the 16.67 ms per-thread gate and state pass/fail for each scenario.
   Record device/build details, refresh rate, profile mode, warm-up handling,
   repeat count, frame count, current font setup, and whether Impeller is
   active on-device.
4. Verify that Impeller is active on-device and record the verification in
   every report. If Impeller is not active or cannot be verified, stop and
   resolve the renderer/device setup before proceeding; do not treat an
   unverifiable state as a passing gate.
5. Save the raw trace and a concise baseline report under
   `specs/002-visual-design-motion/evidence/`. Confirm that every required
   scenario satisfies the sample/repeat requirements before interpreting
   percentiles.
6. Compare against the historical Foundation runs only as context: the
   2026-11-09 quickstart reports five-frame p95 spans of 136,023 µs and
   111,894 µs. Those samples were too short, report combined `totalSpan`, and
   do not qualify as this feature's baseline.
7. **No optimization is approved in this phase.** After the valid baseline is
   inspected, any measured p95 failure becomes a documented, scenario-specific
   issue. Only then may a minimal mitigation be proposed and evaluated against
   the same baseline scenario. Do not add `motor` speculatively.

**Phase gate**: Valid per-scenario baseline report exists, frame/repeat minimums
are met, Impeller is verified active on-device, and all common gates pass. If
the measurement infrastructure or device is unavailable, or Impeller cannot
be verified active, stop before design/screen work and report the blocker; do
not substitute debug mode, a different device, or fabricated timings.

### Phase 2 — Shared design-token foundation

1. Implement the root `DESIGN.md` tokens as the canonical visual contract and
   establish one shared Flutter theme source used by the app.
2. Apply the approved white/cool-grey surfaces, near-black text, cobalt brand,
   semantic emerald and emissions/warning colors, 4–8 px radii, 8/16 px
   spacing, and hairline dividers. Avoid floating cards and shadows.
3. Bundle the used IBM Plex Sans and IBM Plex Mono weights as local app
   assets, configure `google_fonts` with runtime fetching disabled, and verify
   every configured style resolves offline.
4. Establish text roles: Plex Sans for headings/body; Plex Mono for every
   number, unit, and table figure. Check localization and accessibility scaling.

**Phase gate**: Shared theme is the only source of visual tokens, all
text/surface ratios in `DESIGN.md` pass WCAG AA, and a fresh offline launch
renders bundled fonts correctly. Apply all common gates.

### Phase 3 — Existing-screen visual application

Apply the shared theme to the following complete batches, checking Very Large
text and common gates after each:

1. **Onboarding and result**: onboarding and region selection, questionnaire,
   estimate result and its empty/error/loading states.
2. **Home and modules**: Home and all 11 current module destinations.
3. **Account and settings**: registration, sign-in, Settings, regional picker,
   privacy policy, export/deletion confirmations and outcomes.
4. **Secondary destinations**: About Us, Gallery, Contact Us and their existing
   empty/unavailable states.

Rebuild the result screen under the fixed decision: one lower-bound budget
share against the existing 2.5 t CO2e/person/year-by-2030 benchmark, only if
existing estimate values can be expressed in equivalent units; otherwise
explain unavailability rather than invent a share. Add horizontal bars only
for supported existing estimate categories; show estimate rate and unit,
what the current estimate covers and leaves out, and existing source/factor
disclosures. Remove the three-reference percentage comparison and all rings. This decision
closes T066 Step 3. Do not add EPA-style equivalency cards.

**Phase gate**: Every existing screen/state has the tokens and layout language;
the estimate screen has only the honest benchmark and self-context above. No
navigation, data, factor, or feature change. Apply all common gates, including
system Back from all three regression routes.

### Phase 4 — Motion and loading-state pass

1. Make state changes immediate; use an approximately 120 ms fade only where
   it aids continuity. Keep input available throughout.
2. Implement applicable motion through `SpringSimulation` / `animateWith`;
   use damping/configuration that produces no bounce or overshoot. Preserve
   interruptibility, velocity handoff, momentum projection, and 1:1 drag
   response where the existing interaction uses them.
3. Count/tick changing numeric values to their destination; with reduced motion
   enabled, show the final value without count animation.
4. Replace existing loading presentations with skeleton placeholders using
   `skeletonizer`; keep existing loading/error semantics and flow.
5. Compare final traces against Phase 1 using the same profile conditions.
   Implement only mitigations supported by a specific measured gap, then rerun
   the affected scenarios with the same sample and repeat minimums.

**Phase gate**: No linear, bouncy, or overshooting motion; reduced motion and
input responsiveness pass; refreshed frame reports meet the per-thread p95
gate. Any scenario that remains over 16.67 ms blocks release readiness and
requires a measurement-supported correction and re-measurement. Apply all
common gates and repeat accessibility checks.

## Project Structure

### Documentation (this feature)

```text
DESIGN.md
specs/002-visual-design-motion/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── evidence/                 # Profile traces and baseline/final reports
├── checklists/
│   └── requirements.md
└── tasks.md                  # Later /speckit-tasks output; not created here
```

No `contracts/` directory is required: this change adds no external API,
service, or public integration contract.

### Source Code (repository root)

```text
lib/
├── app/
│   ├── app.dart
│   └── router.dart                 # Behavior preserved; Back regression check
├── core/
│   ├── theme/app_theme.dart             # Single shared token/theme source
│   ├── motion/motion_spec.dart
│   └── accessibility/reduced_motion.dart
└── features/
    ├── about/presentation/
    ├── account/presentation/
    ├── carbon_footprint_tracker/presentation/
    ├── certifications_guide/presentation/
    ├── community_journal/presentation/
    ├── contact/presentation/
    ├── eco_friendly_product_suggestions/presentation/
    ├── eco_travel_suggestions/presentation/
    ├── educational_content/presentation/
    ├── energy_conservation_tips/presentation/
    ├── gallery/presentation/
    ├── home/presentation/
    ├── onboarding/presentation/
    ├── progress_dashboard/presentation/
    ├── recipes_meal_planning/presentation/
    ├── settings/presentation/
    ├── sustainable_living_challenges/presentation/
    └── waste_reduction_tracker/presentation/
assets/fonts/                       # Bundled IBM Plex Sans and Mono assets
integration_test/
└── foundation_motion_test.dart     # T061 traceAction/frame timing harness
test/
├── accessibility/
├── core/accessibility/
├── core/motion/
├── app/router_test.dart
└── features/onboarding/presentation/
```

**Structure Decision**: Keep the current single Flutter application and its
feature-first directory layout. Reuse the existing shared theme/motion locations
and result/onboarding feature. Add no new architecture layer, app, backend, or
navigation structure.

## Complexity Tracking

| Exception | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Principle XIII's general green-brand direction is not used for this feature | The fixed, explicit Climate Instrument direction requires cobalt brand and emerald only for positive/saved data. | Applying the older green-brand rule would violate the feature's non-negotiable palette. Keep this exception narrow and seek maintainer reconciliation before making it permanent. |
