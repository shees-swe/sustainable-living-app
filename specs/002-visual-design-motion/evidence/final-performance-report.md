# T061 Final Profile Comparison

## Run conditions

- Date: 2026-11-11.
- Device: Infinix X678B, serial `1026825381000731`, connected over USB.
- Mode: Flutter profile, integration-test `traceAction`.
- Command:
  `flutter drive --driver=test_driver/foundation_motion_test_test.dart --target=integration_test/foundation_motion_test.dart --profile --no-dds -d 1026825381000731`
- Renderer: Impeller OpenGLES was verified on this same device and Flutter
  profile configuration in [impeller-verification.md](./impeller-verification.md).
- Repeats: 3 per scenario.
- Frames: 601 per repeat for four scenarios; onboarding collected
  605, 601, and 601 frames. Each repeat therefore exceeded the 600-frame
  requirement. Combined samples: 1,807 onboarding frames and 1,803 for each
  other scenario.
- Gate: build-thread and raster-thread p95 each at or below 16,670 µs
  (16.67 ms).
- Drive result: all five scenarios passed and the driver response was saved.
- Raw response:
  [t061_final_trace_actions.json](./traces/t061_final_trace_actions.json).
  The Phase 1 trace was preserved unchanged at
  [t061_trace_actions.json](./traces/t061_trace_actions.json).

## Build duration percentiles

Microseconds; each cell is baseline → final (delta).

| Scenario | p50 | p90 | p95 | p99 |
|---|---:|---:|---:|---:|
| `onboarding_to_estimate` | 257 → 229 (-28) | 381 → 365 (-16) | 402 → 381 (-21) | 462 → 434 (-28) |
| `home_and_all_modules` | 363 → 348 (-15) | 402 → 387 (-15) | 419 → 403 (-16) | 481 → 467 (-14) |
| `account` | 361 → 341 (-20) | 408 → 375 (-33) | 429 → 389 (-40) | 518 → 422 (-96) |
| `settings_and_privacy` | 360 → 339 (-21) | 402 → 378 (-24) | 422 → 394 (-28) | 477 → 434 (-43) |
| `secondary_destinations` | 346 → 331 (-15) | 387 → 368 (-19) | 404 → 380 (-24) | 453 → 409 (-44) |

## Raster duration percentiles

Microseconds; each cell is baseline → final (delta).

| Scenario | p50 | p90 | p95 | p99 |
|---|---:|---:|---:|---:|
| `onboarding_to_estimate` | 3,181 → 3,507 (+326) | 3,318 → 3,671 (+353) | 3,483 → 3,955 (+472) | 3,792 → 4,342 (+550) |
| `home_and_all_modules` | 3,037 → 3,346 (+309) | 3,176 → 3,429 (+253) | 3,243 → 3,524 (+281) | 3,638 → 3,968 (+330) |
| `account` | 2,695 → 2,738 (+43) | 2,773 → 2,802 (+29) | 2,829 → 2,835 (+6) | 3,223 → 3,027 (-196) |
| `settings_and_privacy` | 3,200 → 3,155 (-45) | 3,306 → 3,226 (-80) | 3,497 → 3,282 (-215) | 4,007 → 3,670 (-337) |
| `secondary_destinations` | 2,547 → 2,565 (+18) | 2,610 → 2,620 (+10) | 2,644 → 2,644 (0) | 2,891 → 2,752 (-139) |

## Total-span percentiles

Microseconds; each cell is baseline → final (delta).

| Scenario | p50 | p90 | p95 | p99 |
|---|---:|---:|---:|---:|
| `onboarding_to_estimate` | 3,891 → 4,185 (+294) | 4,099 → 4,447 (+348) | 4,358 → 4,798 (+440) | 4,926 → 5,406 (+480) |
| `home_and_all_modules` | 3,816 → 4,096 (+280) | 4,007 → 4,237 (+230) | 4,132 → 4,444 (+312) | 4,676 → 5,016 (+340) |
| `account` | 3,471 → 3,476 (+5) | 3,649 → 3,588 (-61) | 3,798 → 3,660 (-138) | 4,418 → 3,915 (-503) |
| `settings_and_privacy` | 3,976 → 3,896 (-80) | 4,202 → 4,017 (-185) | 4,478 → 4,096 (-382) | 5,197 → 4,669 (-528) |
| `secondary_destinations` | 3,305 → 3,297 (-8) | 3,420 → 3,394 (-26) | 3,508 → 3,435 (-73) | 3,906 → 3,671 (-235) |

## p95 gate decisions

| Scenario | Build p95 (baseline → final) | Build gate | Raster p95 (baseline → final) | Raster gate |
|---|---:|---|---:|---|
| `onboarding_to_estimate` | 402 → 381 µs | Pass | 3,483 → 3,955 µs | Pass |
| `home_and_all_modules` | 419 → 403 µs | Pass | 3,243 → 3,524 µs | Pass |
| `account` | 429 → 389 µs | Pass | 2,829 → 2,835 µs | Pass |
| `settings_and_privacy` | 422 → 394 µs | Pass | 3,497 → 3,282 µs | Pass |
| `secondary_destinations` | 404 → 380 µs | Pass | 2,644 → 2,644 µs | Pass |

All build and raster p95 values are below 16,670 µs. Some raster p95 values
increased versus baseline, but none regressed past the gate. No performance
fix is justified; no source changes or `motor` package are needed.
