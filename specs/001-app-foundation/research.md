# Research: Sustainable Living Guide App Foundation

## Decisions

### Flutter platform and project shape

- **Decision**: Use one Flutter/Dart application. Target Android API 28 or later
  and set the iOS deployment target to the minimum supported by the exact stable
  Flutter SDK selected at implementation time. Pin the SDK and package versions.
- **Rationale**: This meets the constitution's cross-platform and Android 9+
  requirements without maintaining separate native application code. Flutter
  architecture guidance supports clear responsibility boundaries but does not
  mandate a particular directory layout; the repository uses the required
  feature-first convention.
- **Alternatives considered**: Separate native Android and iOS applications or
  multiple app projects; both add moving parts and duplicate behavior.

### Foundation architecture and state

- **Decision**: Place startup, app theme, and stable router configuration in
  `lib/app/`; shared persistence, data-pack, localization, motion, and
  accessibility helpers in `lib/core/`; feature UI and behavior in
  `lib/features/<feature>/`. Use Riverpod as the in-memory state boundary and
  repositories for durable data access.
- **Rationale**: This respects feature separation without adding clean-architecture
  layers. Hydrate durable preferences before route redirects. Represent loading
  explicitly, preserve deep-link intent across onboarding, and do not recreate
  the router on ordinary provider updates. Riverpod's experimental offline
  persistence is not the foundation for durable records.
- **Alternatives considered**: Global mutable state, persistence in providers,
  or many additional service/repository abstraction layers. These are less
  explicit or add complexity beyond the app's need.

### Navigation and foundation routes

- **Decision**: Use go_router with stable onboarding, Home, account, Settings,
  About, Gallery, Contact, and module destination routes. Keep route redirects
  limited to hydrated onboarding/account state; browsing never depends on login.
- **Rationale**: Explicit route state makes required navigation and first-launch
  behavior independently testable and avoids redirect loops or cold-start flashes.
- **Alternatives considered**: Navigation decisions embedded in widgets or
  repeated conditional routing per feature.

### Local persistence, credentials, and data lifecycle

- **Decision**: Use Drift/SQLite for user-owned records and preferences. Store a
  salted Argon2id password verifier with algorithm and cost metadata, never the
  password. Use OWASP's current Argon2id minimum parameters as a floor
  (19 MiB memory, two iterations, parallelism one), benchmark on the slowest
  supported device, and raise the cost where practical. The local password is an
  account verifier, not a promise that the SQLite database is encrypted.
- **Rationale**: A memory-hard password KDF is more resistant to offline guessing
  than a fast general-purpose hash. Keeping the credential boundary explicit
  avoids claiming database confidentiality that the password hash does not
  provide. A backend, cross-device sync, and online password recovery are out of
  scope.
- **Alternatives considered**: Plaintext/reversible passwords or a fast hash such
  as SHA-256; both are unacceptable. Full database encryption adds key recovery,
  platform-key lifecycle, and data-loss complexity not required by the current
  feature. A maintained, Android/iOS-compatible Argon2id package must be verified
  before implementation.
- **Argon2id package**: Pin `cryptography_plus` 3.0.0. Its pub.dev metadata shows
  a 2026-03-02 release and Dart SDK compatibility; the published API documents
  RFC 9106 Argon2id, Argon2 version 19, and a pure-Dart implementation. This
  avoids an extra native plugin and supports Android/iOS through Dart. Use the
  OWASP floor of 19,456 KiB, two iterations, and parallelism one; retain explicit
  device benchmark evidence before release. On the Infinix X678B (Android
  14/API 34), three measured hashes after one warm-up took 1,162 ms, 1,212 ms,
  and 1,423 ms (median 1,212 ms), with `cryptography_plus` 3.0.0, Argon2id
  version 19, 19,456 KiB, two iterations, parallelism one, and a 32-byte output.
- **Data handling decision**: Generate a user-initiated logical export from an
  allowlist of personal data in a consistent database transaction. Exclude
  credentials and key material. Delete account-linked rows transactionally and
  close the database before removing its files. Disable platform automatic
  backups for local private data in v1 so deleted records are not silently
  restored; clearly avoid promising forensic erasure of flash storage or external
  user-created exports.
- **Migration decision**: Version Drift schemas, retain generated snapshots,
  and test migrations from prior schemas for both successful upgrade and data
  preservation. Await every operation inside transactions and run foreign-key
  checks after complex migrations.

### Bundled regional data and factor provenance

- **Decision**: Keep each country/region pack as a locally bundled, versioned
  data file validated against the shared contract. Packs expose rows in one
  canonical logical emission-factor table/catalog; all factor records include
  geography, units, source identifier, publication year, and validity period.
  Content records cite their own source and date. Represent currency with an ISO
  4217 code and format it separately using the display locale.
- **Rationale**: A common factor schema allows the selected region to change
  factors without hard-coded country branches and meets the single-table and
  provenance requirements. Locale and selected data region are distinct: a
  language setting must not silently change the region or emissions assumptions.
- **Missing-data decision**: If a region or individual factor has no valid,
  verified bundled value, label it unavailable or use only a separately
  documented, explicitly scoped generic factor; never silently substitute a
  different region's data.
- **Recipe-data constraint**: Nutrition or ingredient-composition sources are
  not emissions-factor sources. A recipe's environmental impact may be shown
  only when its impact source and method are explicitly cited and validated.
- **Alternatives considered**: Network-fetching updates, region inference from
  language, uncited fallback values, or separate incompatible schemas per
  country; these conflict with offline operation, provenance, or global-first
  behavior.
- **Phase 6 launch pack decision (2026-11-07)**: Bundle Pakistan as the only
  sourced production regional pack, using the user-provided Ember Yearly
  Electricity Data 2025-release factor (0.347 kg CO2/kWh, validity year 2025)
  and Our World in Data / Global Carbon Budget 2025 Pakistan average
  (0.72 t CO2/person, 2024). The factor source publication year and the factor's
  validity year are retained separately. The user-provided values are used
  without substitution; the IGES List of Grid Emission Factors v11.6 cross-check
  remains a v1 release gate. The currently accessible Ember yearly dataset
  reports a different value for 2024 and is not substituted for the cited 2025
  release. Transport factors and recipe impact claims are absent because no
  citations were provided; the app must explicitly communicate that gap.
- **Reference comparability**: The cited OWID/GCB averages are consumption-based
  fossil CO2 per capita, while the onboarding estimate is a demo-only
  electricity/transport CO2e calculation. The Akenji et al. 1.5-Degree
  Lifestyles target is a 2030, equity-based household lifestyle CO2e target.
  Until period, units, and accounting boundary are compatible, show those
  sourced values as contextual references and do not render them as comparable
  estimate rings.

### Footprint comparison rings and scientific references

- **Decision**: Calculate estimate and comparison values outside the chart
  presentation layer. The onboarding rings use comparable units, period, and
  scale; provide exact text values, source/date details, and semantic
  descriptions alongside the visual.
- **Rationale**: A ring is a visualization, not the source of truth. Matched
  denominators and accessible text reduce the risk of implying false
  comparability.
- **1.5°C reference decision**: Use a published, equity-based,
  consumption-footprint per-person target as the candidate methodology. The Hot
  or Cool Institute's *1.5-Degree Lifestyles* work is a methodological
  precedent, not an automatically current or universal value. Before release,
  verify the exact report vintage and numeric target against the onboarding
  footprint boundary, then record its allocation rule, target year, gases,
  exclusions, period, unit, and uncertainty. IPCC carbon budgets and UNEP global
  pathway targets are climate constraints, not personal annual budgets by
  themselves. Do not divide cumulative budgets by population or years without a
  published allocation method. If a valid, comparable target cannot be
  verified, the release gate fails; do not invent a number or treat a regional
  or global average as a 1.5°C budget.
- **Average comparison rule**: Regional/global averages are descriptive
  benchmarks, not fair-share limits. Match their accounting boundary, gases,
  period, unit, and denominator to the estimate or label them as contextual,
  non-like-for-like comparisons. For example, consumption-based country CO2
  series cannot be passed off as an all-gases personal CO2e benchmark.
- **Alternatives considered**: Drawing rings from separately normalized scales,
  hiding exact values, or hard-coding an unreferenced universal budget.

### Localization and presentation

- **Decision**: Use Flutter gen-l10n and ARB resources from the first screen,
  with English as the launch default. Use placeholders and plural/select
  messages rather than concatenating translated fragments. Keep display locale
  and selected data region as separate preferences.
- **Rationale**: This satisfies global-first localization from day one and avoids
  coupling language to regional emissions or currency data.
- **Alternatives considered**: Inline UI text or using locale country codes as
  implicit region selection.

### Theme, accessibility, and motion

- **Decision**: Use a green-seeded Material color scheme with semantic color
  roles, a compact set of spacing/type/radius tokens, and contrast review.
  Implement a shared spring-motion utility that can be interrupted and retargeted
  from current position/velocity. Honor reduced motion using the relevant Android
  and iOS accessibility signals and simplify or skip nonessential motion.
- **Rationale**: Shared token and motion foundations keep interactions coherent
  while meeting the constitution's simplicity, motion, and accessibility gates.
- **Performance validation**: Profile release-mode UI and raster frame work on
  representative physical Android and iOS devices. At 60 Hz use approximately
  16.7 ms as the frame budget; debug-mode timings are not release evidence.
- **Alternatives considered**: Literal colors scattered across features,
  independent per-feature spring constants, linear/blocking transitions, or
  checking only one platform's reduced-motion signal.

### Testing and quality gates

- **Decision**: Use unit tests for calculations, factor/catalog selection,
  password verification, migrations, export, and deletion; widget tests for
  onboarding, ring semantics, Home destinations, localization, and route
  redirects; and offline integration checks for persistence and privacy flows.
- **Rationale**: These cover the highest-risk contracts and meet the project
  quality gates while keeping detailed module tests in their later feature plans.
- **Alternatives considered**: Relying on analyzer/build success alone or
  deferring onboarding and Home widget coverage.

## Source References

- [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter supported platforms](https://docs.flutter.dev/reference/supported-platforms)
- [Flutter Android deployment](https://docs.flutter.dev/deployment/android)
- [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios)
- [Flutter ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)
- [Flutter SpringSimulation](https://api.flutter.dev/flutter/physics/SpringSimulation-class.html)
- [Flutter AnimationController.animateWith](https://api.flutter.dev/flutter/animation/AnimationController/animateWith.html)
- [Flutter Android reduced-motion signal](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)
- [Flutter iOS reduceMotion signal](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/reduceMotion.html)
- [Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance)
- [Flutter DevTools Performance view](https://docs.flutter.dev/tools/devtools/performance)
- [Riverpod providers](https://riverpod.dev/docs/concepts2/providers)
- [Riverpod provider lifecycle](https://riverpod.dev/docs/concepts2/auto_dispose)
- [Riverpod offline persistence status](https://riverpod.dev/docs/concepts2/offline)
- [Riverpod testing](https://riverpod.dev/docs/how_to/testing)
- [go_router configuration](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
- [go_router redirection](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- [Drift migrations](https://drift.simonbinder.eu/migrations/)
- [Drift migration tests](https://drift.simonbinder.eu/migrations/tests/)
- [Drift transactions](https://drift.simonbinder.eu/dart_api/transactions/)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [NIST SP 800-63B-4 password verifiers](https://pages.nist.gov/800-63-4/sp800-63b/authenticators/#passwordver)
- [RFC 9106: Argon2](https://www.rfc-editor.org/rfc/rfc9106.html)
- [Android Keystore](https://developer.android.com/privacy-and-security/keystore)
- [Android Auto Backup](https://developer.android.com/identity/data/autobackup)
- [SQLite VACUUM](https://sqlite.org/lang_vacuum.html)
- [Flutter internationalization](https://docs.flutter.dev/ui/internationalization)
- [Flutter GlobalMaterialLocalizations](https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html)
- [Dart NumberFormat](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html)
- [fl_chart PieChartData](https://pub.dev/documentation/fl_chart/latest/fl_chart/PieChartData-class.html)
- [Flutter Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [ISO 4217 currency codes](https://www.iso.org/iso-4217-currency-codes.html)
- [IPCC AR6 Synthesis Report](https://www.ipcc.ch/report/ar6/syr/)
- [IPCC AR6 WGIII, Chapter 2](https://www.ipcc.ch/report/ar6/wg3/chapter/chapter-2/)
- [UNEP Emissions Gap Report 2025](https://www.unep.org/resources/emissions-gap-report-2025)
- [Hot or Cool Institute: 1.5-Degree Lifestyles methodology](https://hotorcool.org/projects/1-5-degree-lifestyles/)
- [Climate Equity Reference Project](https://climateequityreference.org/)
- [Our World in Data: consumption-based CO2 per capita definition and source notes](https://ourworldindata.org/grapher/consumption-co2-per-capita)
- [EDGAR GHG dataset](https://edgar.jrc.ec.europa.eu/dataset_ghg2024)
- [UK government conversion factors and methodology](https://www.gov.uk/government/collections/government-conversion-factors-for-company-reporting)
- [USDA FoodData Central documentation](https://fdc.nal.usda.gov/data-documentation/)
