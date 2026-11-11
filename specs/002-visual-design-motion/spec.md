# Feature Specification: Climate Instrument Visual Design and Motion

**Feature Branch**: `002-visual-design-motion`

**Created**: 2026-11-11

**Status**: Draft

**Input**: User description: Apply the fixed “Climate Instrument” visual design and motion direction to every existing screen of the 001 Foundation app, redesign the estimate result comparison, and establish performance and accessibility verification requirements.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Read and navigate a consistent app (Priority: P1)

A user moves through the existing app and sees a consistent, light-only visual
system on every screen, including onboarding, Home, modules, account and
settings flows, and secondary destinations. Text, values, controls, and
dividers remain clear and usable, including at the Very Large text setting.

**Why this priority**: Applying the same legible visual language throughout the
existing experience is the core purpose of this feature.

**Independent Test**: Review and navigate every existing screen and its current
states at standard and Very Large text sizes. Verify the specified colors,
typography, spacing, layout, contrast, and lack of clipping or overlap without
changing available destinations or navigation behavior.

**Acceptance Scenarios**:

1. **Given** a user opens any existing screen, **When** they view its content,
   **Then** it uses only the light Climate Instrument surfaces, ink, cobalt
   brand color, semantic data colors, typography, and spacing rules.
2. **Given** a user views a list, table, module destination, or empty state,
   **When** they scan or operate it, **Then** hairline dividers and clear
   alignment establish hierarchy without relying on floating cards or
   decorative effects.
3. **Given** Very Large text is enabled, **When** the user visits every existing
   screen and its relevant states, **Then** no text or control is clipped, no
   content overlaps, and interactive controls remain usable.
4. **Given** the user moves between existing screens or uses Android system
   Back, **When** the navigation completes, **Then** established destinations
   and back behavior are unchanged, including the fix from commit `8a64545`.

---

### User Story 2 - Understand changes and values without disruptive motion (Priority: P1)

A user receives immediate feedback from existing interactions. Where motion
communicates a change, it is restrained and predictable; displayed numbers
count or tick to their final values without bounce or overshoot. Reduced-motion
preferences continue to be honored.

**Why this priority**: Motion must clarify state and numerical change without
slowing, distracting, or excluding users.

**Independent Test**: Exercise current screen transitions, controls, loading
states, and changing numerical values with reduced motion both enabled and
disabled. Verify there is no bounce, overshoot, blocked input, or stranded
intermediate state.

**Acceptance Scenarios**:

1. **Given** a user changes an existing control or screen state, **When**
   feedback is shown, **Then** the state change is immediate except for an
   optional fade of approximately 120 ms, and the user can continue interacting.
2. **Given** an existing screen displays a changing number, **When** its value
   updates, **Then** it counts or ticks to the final value without bounce or
   overshoot; reduced-motion mode presents the value without that animation.
3. **Given** loading content is shown, **When** it resolves or fails, **Then**
   the existing loading state gives way to the correct content or explicit
   existing error state without changing the user flow.
4. **Given** reduced motion is enabled during an interaction, **When** that
   interaction completes, **Then** the user is not left in an intermediate
   state and all existing actions remain available.

---

### User Story 3 - Interpret an honest footprint result (Priority: P1)

A user sees their existing estimate with a single, clearly bounded comparison
to the cited 1.5-degree lifestyle budget, alongside context about what the
estimate includes. The result does not imply a like-for-like comparison where
units, periods, or boundaries differ.

**Why this priority**: The result is a central existing flow, and its visual
presentation must communicate the limits of an estimate rather than overstate
its precision or coverage.

**Independent Test**: Complete the existing estimate flow and inspect the
result. Verify the budget-share bar and lower-bound wording, self-context
panels, sources and units, and the covered/not-covered scope; verify the former
three-reference percentage comparison and rings are absent.

**Acceptance Scenarios**:

1. **Given** a completed estimate, **When** the result is shown, **Then** it
   contains a budget-share bar against only the cited 1.5-degree lifestyle
   budget of 2.5 t CO2e per person per year by 2030 (IGES/Akenji et al., already
   in the cited factor pack), with the share worded as a lower bound, such as
   “at least Y% of the 2030 budget.”
2. **Given** a completed estimate, **When** the user inspects its contextual
   details, **Then** category contributions appear as horizontal bars, the
   estimate is identified as an annual per-person rate with its unit, and a
   coverage panel identifies what the estimate includes and leaves out.
3. **Given** the cited benchmark or estimate is displayed, **When** the user
   checks its context, **Then** the value, unit, period, source, and relevant
   estimate coverage are clear, and no new or unsupported data or factor is
   introduced.
4. **Given** the result screen is redesigned, **When** the user compares their
   estimate, **Then** the former three-reference “%-vs-average” comparison and
   comparison rings are not shown, and EPA-style equivalency cards are not
   introduced.

---

### User Story 4 - Receive a responsive, accessible visual experience (Priority: P2)

A user can use the redesigned app without perceptible jank, with contrast and
type that remain readable and with reduced-motion behavior intact. Performance
changes are made only when measurements show they are needed.

**Why this priority**: The visual redesign must preserve the app's accessibility
and responsiveness rather than trade them for decoration or animation.

**Independent Test**: Before any optimization, capture the required on-device
profile measurements for each defined scenario, verify Impeller status, then
compare any proposed performance change against that baseline and the stated
frame-time gate.

**Acceptance Scenarios**:

1. **Given** the baseline has not been measured, **When** performance work
   begins, **Then** no optimization is made before the required baseline
   capture.
2. **Given** a scenario is measured, **When** its performance report is
   reviewed, **Then** it includes at least 600 steady-state frames for each
   repeat, 3–5 repeats, separate build and raster percentiles, and p95 frame
   time at or below 16.67 ms per thread.
3. **Given** the app runs on the target device, **When** the measurement is
   performed, **Then** the report records whether Impeller is active on-device.
4. **Given** a performance issue is measured, **When** a change is proposed,
   **Then** it addresses the measured gap, preserves reduced-motion behavior,
   and is checked against the same scenario and baseline.

### Edge Cases

- Very Large text, long localized labels, empty content, errors, dialogs,
  numeric values, and narrow layouts must not cause clipping, overlap, or
  unusable controls.
- A user has reduced motion enabled while a number changes or a screen state
  updates; the final state must remain immediate and operable.
- An estimate has no category contribution available, or its coverage is
  incomplete; the screen must not invent a category value or imply full
  lifestyle coverage.
- The estimate and benchmark may have different coverage boundaries; the budget
  comparison must remain explicitly a lower bound and must not imply that the
  estimate measures all lifestyle emissions.
- A measured performance scenario exceeds the gate; any subsequent fix must be
  justified by the recorded measurement and re-measured.
- Impeller status cannot be verified on the target device; the report must
  record that it could not be verified rather than assume it is active.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every existing screen and current user-visible state in the
  001 Foundation app MUST use the Climate Instrument direction. Scope includes
  Get started and region selection, the estimate questionnaire and result,
  Home, all 11 existing module destinations, account registration and sign-in,
  Settings and regional selection, privacy policy and privacy actions, About
  Us, Gallery, Contact Us, and their existing loading, empty, confirmation, and
  error states.
- **FR-002**: The interface MUST be light-only, using pure white and cool
  light-grey surfaces with near-black ink. It MUST NOT use cream, serif display
  type, or sage green.
- **FR-003**: Electric cobalt blue MUST be the primary brand color. Saturated
  emerald MUST be reserved for saved states and positive deltas; amber or red
  MUST be reserved for emissions and warnings. Green MUST NOT be used as the
  brand color.
- **FR-004**: Headings and body text MUST use IBM Plex Sans. Every number, unit,
  and table figure MUST use IBM Plex Mono. Both font families MUST be bundled
  as app assets through `google_fonts` with `allowRuntimeFetching=false`, so
  text remains available offline.
- **FR-005**: The visual system MUST use 4–8 px corner radii, hairline dividers
  in place of floating cards, list rows and tables as primary layout patterns,
  and an 8/16 px spacing grid. Warmth MUST come from copy and empty states, not
  from softening the visual system.
- **FR-006**: Motion MUST be instrument-like: state changes are immediate,
  optional fades are approximately 120 ms, and changing numbers count or tick
  to their values. Motion MUST NOT be linear, bounce, overshoot, or block user
  input. Where applicable, motion MUST use interruptible spring physics,
  velocity handoff, momentum projection, and 1:1 drag response. Animations MUST
  use `SpringSimulation` / `animateWith`; all motion MUST respect the existing
  reduced-motion preference.
- **FR-007**: Loading states MUST use `skeletonizer` placeholders. The `motor`
  package MUST be used only if measurements demonstrate a concrete performance
  gap that it addresses.
- **FR-008**: The result screen MUST remove the three-reference “%-vs-average”
  comparison and MUST NOT contain comparison rings. It MUST show a budget-share
  bar against only the 2.5 t CO2e/person/year-by-2030 1.5-degree lifestyle
  budget cited in the existing factor pack. The share MUST compare the
  existing annual per-person estimate to that benchmark using equivalent units,
  and MUST be described as a lower bound, such as “at least Y% of the 2030
  budget.” The screen MUST NOT show a numeric share if the estimate cannot be
  compared on that basis using existing data.
- **FR-009**: The result screen MUST provide self-context through horizontal
  category bars, the estimate as an annual per-person rate with its unit, and a
  coverage panel that states what is included and excluded. It MUST preserve
  existing calculation data and factors and MUST NOT imply that an incomplete
  estimate covers a whole lifestyle.
- **FR-010**: EPA-style equivalency cards MUST remain out of scope for this
  feature and MUST be recorded as deferred; they MUST NOT be added to the
  result screen.
- **FR-011**: Before any performance optimization, performance MUST be measured
  in profile mode on the Infinix X678B using the integration-test `traceAction`
  harness. Each scenario MUST capture at least 600 steady-state frames per
  repeat across 3–5 repeats. Reports MUST provide build and raster percentiles
  separately and verify and record whether Impeller is active on-device. The
  p95 frame-time gate is at or below 16.67 ms per thread.
- **FR-012**: Any performance optimization MUST be justified by the baseline
  measurements and re-measured against the same scenario. Animations MUST use
  `SpringSimulation` / `animateWith`; reduced-motion behavior MUST remain
  intact.
- **FR-013**: A `DESIGN.md` at the project root MUST be created during the plan
  phase. It MUST contain the eight canonical sections from Overview through
  Do's and Don'ts, YAML design tokens with prose rationale, and computed WCAG
  contrast ratios for every text/background pair.
- **FR-014**: Every text/background pair specified by the design tokens MUST
  meet WCAG AA contrast: at least 4.5:1 for normal text and at least 3:1 for
  large text. The contrast ratios and pairs MUST be documented in `DESIGN.md`.
- **FR-015**: Very Large text MUST remain free of clipping and overlap on every
  existing screen; controls and content MUST remain legible and operable.
  Interactive targets MUST meet or exceed the minimum recommended touch-target
  size for their supported platform. Reduced-motion support MUST remain
  available and effective, and accessibility MUST be explicitly checked and
  pass before release.
- **FR-016**: This feature MUST NOT add new product features, change navigation,
  or alter underlying estimate data or emission factors. The existing Android
  system Back fix from commit `8a64545` MUST NOT regress.
- **FR-017**: The 104 existing foundation tests MUST remain green and
  `flutter analyze` MUST remain clean.
- **FR-018**: T066 Step 3 MUST close through the result-screen decision in
  FR-008–FR-010: remove the incomparable three-reference percentage
  comparison/rings, use the single cited budget benchmark with lower-bound
  wording, and provide estimate self-context.

### Key Entities

- **Visual Design Tokens**: The named color, typography, spacing, radius,
  divider, contrast, and motion values consistently applied to existing
  screens.
- **Estimate Result Context**: The existing estimate and its unit and period,
  single cited budget benchmark, category breakdown, estimate rate, and
  included/excluded coverage.
- **Performance Measurement Record**: A scenario's device and rendering-mode
  verification, repeat and frame counts, separate build and raster percentiles,
  and p95 gate result.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the existing screens and their current user-visible
  states use the specified light-only design direction; no cream, serif display
  type, or sage green is present.
- **SC-002**: All design-token text/background pairs meet WCAG AA contrast, and
  every required pair has a computed ratio recorded in the root `DESIGN.md`.
- **SC-003**: At Very Large text size, 100% of existing screens pass review
  without clipped content or overlap, and existing controls remain operable.
- **SC-004**: Result-screen review confirms the former three-reference
  percentage comparison and rings are absent, the single 2.5 t CO2e
  per-person/year-by-2030 budget is described as a lower bound, and the
  category, annual-rate, and coverage context are present.
- **SC-005**: Each required performance scenario has a baseline report from
  profile mode on the Infinix X678B with Impeller status recorded, at least
  600 steady-state frames per repeat, and 3–5 repeats; build and raster
  percentiles are reported separately and each thread's p95 is at or below
  16.67 ms.
- **SC-006**: Reduced-motion checks pass for all changed motion states, with no
  bounce or overshoot and no interaction blocked by animation.
- **SC-007**: All 104 existing foundation tests pass and `flutter analyze`
  completes without findings.
- **SC-008**: Existing destinations and navigation behavior remain unchanged,
  including Android system Back behavior from commit `8a64545`.
- **SC-009**: Accessibility review confirms that all changed interactive
  targets meet their platform's minimum recommended size and that Very Large
  text, contrast, and reduced-motion checks pass.

## Assumptions

- The 001 Foundation app's current screens, routes, user-visible states,
  calculations, and bundled cited factor pack are the baseline; no new screen,
  route, feature, data, or factor is introduced.
- The existing estimate is expressed as an annual per-person rate where its
  available inputs support that interpretation; result labels must retain the
  existing estimate's actual unit and period.
- The 2.5 t CO2e benchmark and its citation are already present in the cited
  factor pack; the result uses that existing reference rather than adding or
  changing factor data.
- The root `DESIGN.md` is a plan-phase deliverable and is not part of this
  specify-phase output.
- Performance scenarios cover the existing user flows and screen states
  affected by the visual and motion changes. A missing measurement capability
  or unverifiable device condition is reported explicitly, not replaced with
  an assumed result.
- “Warmth” is communicated through concise, respectful copy and existing empty
  states; it does not change the required palette, typography, or layout rules.

## Deferred

- EPA-style equivalency cards are deferred from 002 because the requested scope
  excludes US-specific equivalency factors and favors direct emissions values.
