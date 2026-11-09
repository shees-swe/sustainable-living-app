# Foundation test data

This package contains fixture data only; it contains no application source code.
The regional pack and shared references are copies of the bundled JSON fixtures
used by the Foundation acceptance tests.

## Contents

- `regions/pakistan.json` — the cited Pakistan grid factor and regional average.
- `foundation-references.json` — the global reference and the methodology-
  qualified 2030 lifestyle target.

The Pakistan electricity factor is the 0.347 kg CO2/kWh value supplied for
Ember's 2025 release and 2025 validity period. The source record is retained in
the fixture. The IGES v11.6 grid-factor reconciliation remains an explicit v1
release gate; this package does not claim that reconciliation has passed.
Transport factors and recipe impact factors are absent because no cited factors
are bundled. Do not add estimated values to these fixtures.

The regional and global average values use consumption-based fossil CO2
boundaries; the estimate is an electricity/transport CO2e calculation. The
fixtures intentionally preserve their different periods, units, and accounting
boundaries. They are contextual references, not comparable rings.

## Validation

From the application repository root, run:

```powershell
dart run tool/validate_region_data.dart
```

The command validates the bundled regional fixture and shared references
against the Foundation JSON schemas and checks that source and factor IDs
resolve. The test-data directory itself contains no executable validator or
application code.

The bundle is for development and acceptance testing only. It is not a
production endorsement of the emission-factor reconciliation.
