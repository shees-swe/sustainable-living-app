# Research: Climate Instrument Visual Design and Motion

## Decisions

### Offline IBM Plex fonts

- **Decision**: Bundle only the IBM Plex Sans and IBM Plex Mono font files and
  weights used by the design as local assets; configure `google_fonts` with
  runtime fetching disabled. Verify font resolution from a cold offline launch.
- **Rationale**: Typography is part of the required visual system and must not
  depend on connectivity. The package documentation says matching bundled
  assets are preferred over HTTP and exposes runtime fetching configuration.
- **Alternatives considered**: Runtime Google Fonts downloads (violates offline
  behavior); adding unrelated font weights (larger app without user value).
- **Sources**: [google_fonts package guide](https://pub.dev/packages/google_fonts);
  [GoogleFonts.config API](https://pub.dev/documentation/google_fonts/latest/google_fonts/GoogleFonts/config.html).

### Profile-mode measurement

- **Decision**: Before any screen or theme change, use the integration-test
  `traceAction` profiling pattern on the physical Infinix X678B in profile
  mode, and collect frame-level `FrameTiming` values. Record build and raster
  duration percentiles separately, plus total span, for each repeat and
  scenario.
- **Rationale**: `traceAction` records a timeline around a reproducible action;
  frame timing callbacks provide build/raster durations. These are complementary
  evidence. The 600-frame and 3–5-repeat requirements make the requested
  baseline materially stronger than the existing five-frame runs.
- **Alternatives considered**: Debug-mode timings (not representative of
  profile performance); `totalSpan` alone (does not identify UI-build vs raster
  thread); historical five-frame data (too small and from before the redesign).
- **Sources**: [Flutter integration profiling recipe](https://docs.flutter.dev/cookbook/testing/integration/profiling);
  [`FrameTiming`](https://api.flutter.dev/flutter/dart-ui/FrameTiming-class.html);
  [`addTimingsCallback`](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addTimingsCallback.html);
  [`buildDuration`](https://api.flutter.dev/flutter/dart-ui/FrameTiming/buildDuration.html);
  [`rasterDuration`](https://api.flutter.dev/flutter/dart-ui/FrameTiming/rasterDuration.html);
  [`totalSpan`](https://api.flutter.dev/flutter/dart-ui/FrameTiming/totalSpan.html).

### Rendering mode and device conditions

- **Decision**: Record whether Impeller is active on the actual device in every
  profile report, alongside device/OS, refresh rate, build mode, and run setup.
  Keep the renderer, device, refresh rate, profile mode, scenario, and
  measurement method identical when comparing baseline and follow-up results.
  Record the baseline's existing font setup; the subsequent bundled IBM Plex
  fonts are an intentional part of the design delta and must not be installed
  before the mandated pre-screen baseline.
- **Rationale**: Renderer differences can confound a performance comparison.
  Font assets also affect rendering, but preloading the new design fonts would
  alter the required current-foundation baseline. Compare that baseline with
  the later full-design trace, recording this intentional difference. The
  existing Foundation quickstart records duplicate USB/ADB transport
  problems; USB-only with wireless debugging disabled is the repeatable setup.
- **Alternatives considered**: Assume the configured/default renderer is
  active (does not establish the on-device condition); install new design
  fonts before the baseline (violates measurement-first order); use debug mode
  or a different device (not comparable to the required T061 baseline).
- **Sources**: [Flutter Impeller documentation](https://docs.flutter.dev/perf/impeller);
  [Foundation quickstart](../001-app-foundation/quickstart.md).

### Reduced-motion spring behavior

- **Decision**: Preserve the existing reduced-motion preference and exercise
  changed spring animations with reduced motion enabled. Account for Android's
  `disableAnimations` and iOS's `reduceMotion` signals; do not assume custom
  spring motion is automatically made appropriate by a controller setting.
- **Rationale**: A `SpringSimulation` is custom motion and must be checked for
  the required final-state/no-animation experience. Existing accessibility
  behavior and the Constitution's motion/accessibility principles remain
  release gates.
- **Alternatives considered**: Apply default controller animation behavior
  without testing custom simulations; remove reduced motion (violates the
  Constitution and spec).
- **Sources**: [`MediaQueryData.disableAnimations`](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html);
  [`AccessibilityFeatures.reduceMotion`](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/reduceMotion.html);
  [`AnimationBehavior`](https://api.flutter.dev/flutter/animation/AnimationBehavior.html);
  [`SpringSimulation`](https://api.flutter.dev/flutter/physics/SpringSimulation-class.html).

### Scope and measurement-first ordering

- **Decision**: Establish the baseline before screen work. Do not commit to a
  performance optimization in advance. If measured scenarios fail the p95
  gate, plan only the smallest mitigation supported by the trace and rerun the
  same scenario.
- **Rationale**: The prior Foundation record says two five-frame runs exceeded
  the 16,667 µs combined frame-span budget (136,023 µs and 111,894 µs); it
  explicitly leaves T061 pending and asks for a re-measure after screens are
  rebuilt. The new feature reverses that previous sequence by user direction:
  this baseline is required before any visual rebuild.
- **Alternatives considered**: Optimize from the old sample (too few frames and
  no separate build/raster distributions); assume the redesign will improve or
  worsen performance (unsupported).
- **Sources**: [Foundation quickstart performance record](../001-app-foundation/quickstart.md);
  [T061 record](../001-app-foundation/tasks.md).

## Research limitations

- Research did not inspect or change repository files; project-specific
  inventory and historical measurements were read directly during planning.
- Exact post-redesign performance is unknown until Phase 1 baseline/follow-up
  traces are collected. No `motor` adoption or specific performance fix is
  justified before then.
- The fixed design conflicts with the Constitution's general green-brand
  direction in Principle XIII. The plan records the required narrow exception;
  no constitution amendment is made by this plan.
