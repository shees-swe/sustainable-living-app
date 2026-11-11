# Data Model: Climate Instrument Visual Design and Motion

This feature introduces no persisted product data, schema, external service, or
new domain record. The following design-time entities describe the artifacts
and existing values that the implementation must preserve and present.

## Visual Design Token Set

| Field | Type / allowed values | Validation |
|---|---|---|
| Surface colors | White `#FFFFFF`; cool grey `#F3F4F6` | Light-only; no cream or dark palette |
| Text colors | Ink `#111827`; secondary ink `#4B5563`; white on cobalt only | Every used text/surface pair is WCAG AA; pairs and ratios are in root `DESIGN.md` |
| Brand color | Cobalt `#0057D9` | Sole brand color |
| Semantic colors | Emerald `#007A52`; amber `#8A4B08`; red `#B42318` | Emerald only saved/positive; amber/red emissions or warnings |
| Typography | IBM Plex Sans and IBM Plex Mono | Sans for headings/body; Mono for every number, unit, table figure; bundled; runtime fetch off |
| Spacing and shapes | 8 px grid; 4–8 px radius; 1 px divider | Shared tokens; no floating cards or shadows |
| Motion | Instant states; optional ~120 ms fade; spring/tick motion | No bounce/overshoot; reduced-motion support |

**Relationships**: The shared theme is the single source of visual tokens.
Every existing screen consumes the theme; no screen defines an independent
brand palette.

## Existing Screen Inventory

| Group | Existing screens/states |
|---|---|
| Onboarding and estimate | Onboarding, region selection, estimate questionnaire, result, existing loading/error states |
| Home and modules | Home and the 11 current module destinations |
| Account and settings | Registration, sign-in, Settings, regional picker, privacy policy, export/deletion prompts and outcomes |
| Secondary | About Us, Gallery, Contact Us, existing empty/unavailable states |

**Validation**: The inventory is closed to existing routes and states. No
additional feature, destination, navigation behavior, or persisted field is
introduced.

## Estimate Result Context

| Field | Source / constraints | Validation |
|---|---|---|
| Estimate value, unit, period | Existing estimate result | Preserve underlying value and actual units/period; do not infer missing data |
| 2030 lifestyle budget | Existing cited factor pack; 2.5 t CO2e per person per year by 2030 | One benchmark only; show a numeric share only for equivalent existing units |
| Budget share | Derived presentation from the existing estimate and benchmark, not a changed factor | Clearly lower-bound wording; otherwise explain inability to compare |
| Category contribution | Existing estimate category data only | Horizontal bars; omit unsupported categories/values |
| Coverage statement | Existing estimate inputs and documented assumptions | Explicitly state included and excluded scope; no whole-lifestyle claim |
| Provenance | Existing factor/reference disclosures | Preserve source, date/publication year, assumptions, and units |

**Relationship**: The result context relates one existing estimate to one
existing benchmark. The prior three-reference comparison and rings are removed;
EPA equivalencies remain deferred.

## Performance Measurement Record

| Field | Validation |
|---|---|
| Device and renderer | Physical Infinix X678B; verify and record that Impeller is active |
| Build and test mode | Flutter profile mode; integration-test `traceAction` harness |
| Scenario | Named existing user flow with fixed action sequence and state |
| Repeats and frames | 3–5 repeats; at least 600 steady-state frames per scenario per repeat |
| Frame distributions | Build, raster, and total-span percentiles reported separately |
| Gate result | p95 for each thread at or below 16.67 ms; failed scenarios remain explicitly failed |

**Relationship**: A baseline record must exist before a performance
optimization is authorized. If Impeller is not active or cannot be verified,
the measurement phase is blocked until the renderer/device setup is resolved.
Re-measure using the same scenario and conditions after any justified
mitigation.
