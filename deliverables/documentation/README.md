# Sustainable Living Guide Foundation

## Overview

The Foundation is an offline-first Flutter app shell. Guests can choose a
region, use an explicitly marked demo estimate or a sourced regional factor
where available, browse the Home destinations, and open optional account and
privacy controls. Detailed tracker, recipe, challenge, journal, and education
workflows are not included in this Foundation package.

## Demonstration flows

See [demo-flows.md](../demo-flows.md) for short, account-optional flows for the
guest estimate, Home navigation, regional selection, and privacy controls.

## Data and privacy

The app's bundled data and source attribution are included in the separate
`deliverables/test-data/` package. Demo values are not production factors.
Transport and recipe impact factors remain unavailable without cited sources.
The IGES v11.6 grid-factor reconciliation is still a v1 release gate.

Accounts are optional and local to the device. Passwords are not stored in
plaintext. Exports omit credential verifiers; deletion requires confirmation.
Deletion cannot guarantee forensic erasure or remove copies exported by a user.
Platform backup exclusions protect the database and preferences as configured
for Android and iOS, but the iOS native path requires a macOS/device verification.

## Validation status

The final local checkpoint results and outstanding release gates are recorded
in `specs/001-app-foundation/quickstart.md`. A successful analysis, test suite,
or APK build does not close pending device profiling, iOS, user-study, or visual
review requirements.

This documentation package intentionally contains no application source code.
