# T061 Baseline Measurement

## Run conditions

- Date: 2026-11-11
- Device: Infinix X678B (`Infinix_X678B`, product `X678B-OP`; serial
  `1026825381000731`)
- Connection: USB ADB only; wireless debugging was off (`adb_wifi_enabled=0`,
  `service.adb.tcp.port` blank)
- Mode: Flutter profile, `integration_test` with `traceAction`
- Command:
  `flutter drive --driver=test_driver/foundation_motion_test_test.dart --target=integration_test/foundation_motion_test.dart --profile --no-dds -d 1026825381000731`
- Renderer: Impeller active (OpenGLES); see
  [impeller-verification.md](./impeller-verification.md)
- Display: 1080 × 2400; active render rate 120.00001 Hz
- Repeats: 3 per scenario
- Frames: 601 collected per repeat (including timing callback flush), 1,803
  combined frames per scenario
- Gate: build-thread and raster-thread p95 each at or below 16,670 µs
  (16.67 ms)
- Drive result: all 5 integration scenarios passed; response data was saved
  successfully.

## Combined scenario distributions

Durations below are microseconds. Build and raster percentiles are reported
separately. The combined samples contain all 601 measured frames from each of
the three repeats.

| Scenario | Frames (repeats) | Build p50 | Build p90 | Build p95 | Build p99 | Raster p50 | Raster p90 | Raster p95 | Raster p99 | Build gate | Raster gate |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|
| `onboarding_to_estimate` | 1,803 (3 × 601) | 257 | 381 | 402 | 462 | 3,181 | 3,318 | 3,483 | 3,792 | Pass | Pass |
| `home_and_all_modules` | 1,803 (3 × 601) | 363 | 402 | 419 | 481 | 3,037 | 3,176 | 3,243 | 3,638 | Pass | Pass |
| `account` | 1,803 (3 × 601) | 361 | 408 | 429 | 518 | 2,695 | 2,773 | 2,829 | 3,223 | Pass | Pass |
| `settings_and_privacy` | 1,803 (3 × 601) | 360 | 402 | 422 | 477 | 3,200 | 3,306 | 3,497 | 4,007 | Pass | Pass |
| `secondary_destinations` | 1,803 (3 × 601) | 346 | 387 | 404 | 453 | 2,547 | 2,610 | 2,644 | 2,891 | Pass | Pass |

Total-span p50/p90/p95/p99 (µs), as an additional diagnostic:

| Scenario | p50 | p90 | p95 | p99 |
|---|---:|---:|---:|---:|
| `onboarding_to_estimate` | 3,891 | 4,099 | 4,358 | 4,926 |
| `home_and_all_modules` | 3,816 | 4,007 | 4,132 | 4,676 |
| `account` | 3,471 | 3,649 | 3,798 | 4,418 |
| `settings_and_privacy` | 3,976 | 4,202 | 4,478 | 5,197 |
| `secondary_destinations` | 3,305 | 3,420 | 3,508 | 3,906 |

## Raw traces

The complete driver response, including all per-repeat `traceAction` payloads
and frame-timing reports, is saved at
[`traces/t061_trace_actions.json`](./traces/t061_trace_actions.json)
(102,887,352 bytes). Its `t061_scenario_summaries` entries were used for the
combined distributions above.

## T004 performance-fix decision

**Not applicable; no performance fix is justified by this baseline.** All five
scenarios pass the 16.67 ms p95 gate on both the build and raster threads.
Therefore no trace indicates a gate-breaking performance gap, no app code was
changed for performance, and no `motor` package is introduced.
