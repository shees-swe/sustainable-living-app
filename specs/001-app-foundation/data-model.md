# Data Model: Sustainable Living Guide App Foundation

This model covers foundation-owned data only. Full carbon logs, waste logs,
challenges, community journal entries, and module-specific content are deferred
to their respective feature plans.

## Entities

### LocalAccount

Represents an optional account usable on the device where it was created.

| Field | Type | Rules |
|---|---|---|
| `accountId` | UUID | Primary identifier; generated locally. |
| `loginIdentifier` | String | Required, unique after normalization; do not assume email or require network verification. |
| `createdAt` | UTC timestamp | Required; set at account creation. |
| `credentialVerifier` | CredentialVerifier | One verifier per account; never stores the original password. |

**Relationships**: One account owns zero or more local user records and one
credential verifier. The guest profile is not required to have an account.

### CredentialVerifier

Stores data required to verify a local password without retaining the password.

| Field | Type | Rules |
|---|---|---|
| `accountId` | UUID | Foreign key to `LocalAccount`; cascade on account deletion. |
| `algorithm` | String | Required; `argon2id` for the planned credential scheme. |
| `algorithmVersion` | String | Required; records KDF version. |
| `salt` | Byte array | Unique cryptographically random salt; never shared between accounts. |
| `verifier` | Byte array | KDF output only; never plaintext or reversible ciphertext. |
| `memoryKiB` | Integer | Required; at least the OWASP Argon2id floor, device-benchmarked. |
| `iterations` | Integer | Required; at least the OWASP Argon2id floor. |
| `parallelism` | Integer | Required; at least the OWASP Argon2id floor. |
| `updatedAt` | UTC timestamp | Required; updated if verifier parameters are upgraded. |

Passwords are never fields in any persisted entity, export, log, or analytics
record. The verifier protects password verification; it does not imply SQLite
database encryption.

### UserPreferences

Stores user choices that persist across local app launches.

| Field | Type | Rules |
|---|---|---|
| `preferenceId` | Constant/local key | Single active preference record. |
| `displayLanguageTag` | BCP 47 language tag | Defaults to English; independent of selected data region. |
| `selectedRegionId` | String or null | Must match a verified bundled regional pack before regional data is used. |
| `reducedMotion` | Boolean or system-derived | Respect platform accessibility setting; explicit override, if offered, must not defeat system reduce-motion. |
| `updatedAt` | UTC timestamp | Updated when preferences change. |

### FootprintEstimate

Stores a guest or account-associated onboarding estimate and its inputs.

| Field | Type | Rules |
|---|---|---|
| `estimateId` | UUID | Primary identifier. |
| `ownerAccountId` | UUID or null | Null for a guest estimate; foreign key when account-associated. |
| `createdAt` | UTC timestamp | Required. |
| `periodStart` / `periodEnd` | Date or year | Required reference period; must match displayed comparisons. |
| `answers` | Versioned structured value | Contains only the estimate inputs; validate against the current questionnaire version. |
| `estimateValue` | Decimal | Nonnegative CO2e amount; do not round before comparison calculation. |
| `unit` | String | Explicit CO2e unit, normalized for comparisons. |
| `questionnaireVersion` | String | Required to interpret stored answers. |
| `completionState` | Enum | `complete` or `incomplete`; only complete estimates produce comparison rings. |
| `assumptions` | List of identifiers/text keys | Explain assumptions in localized presentation. |

### RegionalDataPack

Describes one bundled data pack selected by country or region.

| Field | Type | Rules |
|---|---|---|
| `packId` | String | Unique stable identifier. |
| `schemaVersion` | Integer | Required; selects the parser/validator contract. |
| `packVersion` | SemVer string | Required; changes when pack content changes. |
| `factorCatalogVersion` | SemVer string | Shared catalog version; all regional packs loaded in one app release MUST agree. |
| `regionId` | ISO region identifier | Required; independent of display language. |
| `regionNameKey` | Localization key | Required; labels are externalized. |
| `currencyCode` | ISO 4217 code | Required; currency symbol is formatted at presentation time. |
| `contentAsOf` | Date | Required; date the bundled pack was assembled/reviewed. |
| `regionalAverage` | ReferenceValue | Required for an estimate ring; source and accounting boundary must be compatible with the footprint estimate. |
| `sourceRecords` | List of DataSource | Every factor/content citation resolves to a record. |
| `emissionFactors` | List of EmissionFactor rows | One canonical schema/logical table across all regional packs. |
| `transportModes` | List of RegionalContentItem | Each displayed label resolves through localization; applicable factors are referenced by ID. |
| `recipes` | List of RegionalContentItem | Localized labels; any impact claim references a cited emission factor/method. |

### EmissionFactor

Represents a row in the app's single versioned logical factor table.

| Field | Type | Rules |
|---|---|---|
| `factorId` | String | Unique across the catalog; stable references from estimates/content. |
| `regionId` | String or global scope | Identifies applicable geography; no silent cross-region substitution. |
| `category` | Enum | Activity category such as electricity, transport, or food. |
| `activityId` | String | Stable activity key used by calculation logic. |
| `value` | Decimal | Finite, nonnegative factor value. |
| `numeratorUnit` | String | Explicit impact unit, normally CO2e. |
| `denominatorUnit` | String | Explicit activity denominator and scale. |
| `sourceId` | String | Must resolve to one `DataSource` record. |
| `sourceYear` | Integer | Publication/release year of the cited source. |
| `validFrom` / `validTo` | Date/year | Period represented by the factor; distinct from source publication year. |
| `methodologyKey` | Localization key or identifier | Describes boundaries, allocation, or relevant assumptions. |

All emitted results reference the exact factor ID and source metadata used. A
source year does not substitute for the factor's validity period.

### DataSource

Describes the provenance and attribution required for a factor or content item.

| Field | Type | Rules |
|---|---|---|
| `sourceId` | String | Unique within the pack/catalog. |
| `title` | String | Required citation title. |
| `publisher` | String | Required source organization or author. |
| `url` | URI string | Citation URL when the source provides one. |
| `publicationYear` | Integer | Required when known; distinguishes it from `validFrom`/`validTo`. |
| `accessedOrReleasedAt` | Date | Records access or pack release date as relevant. |
| `licenseAttribution` | String | Required attribution/license text when applicable. |

### RegionalContentItem

Represents regionally relevant content such as transport choices or recipes.

| Field | Type | Rules |
|---|---|---|
| `contentId` | String | Stable identifier within the pack. |
| `labelKey` | Localization key | Required; the visible name is not hard-coded in UI. |
| `sourceIds` | List of source identifiers | Each factual claim resolves to a cited source and date. |
| `factorId` | String or null | If content displays an impact value, it resolves to a valid factor with matching scope and methodology. |

### FoundationReferenceSet

Contains shared comparison references not tied to the selected regional pack.

| Field | Type | Rules |
|---|---|---|
| `referenceSetVersion` | SemVer string | Required. |
| `globalAverage` | ReferenceValue | Cited global value with period, unit, and accounting boundary. |
| `temperatureBudget` | ReferenceValue | A verified 1.5°C-aligned per-person value with target period, source, and allocation assumptions; release is blocked if no compatible value is available. |

### ReferenceValue

| Field | Type | Rules |
|---|---|---|
| `referenceId` | String | Stable identifier: regional average, global average, or 1.5°C-aligned budget. |
| `status` | Enum | `available` or `unavailable`; an unavailable value is never drawn as zero. |
| `value` | Decimal or null | Finite and nonnegative when available; required values cannot be null. |
| `unit` | String | Comparable with the estimate when available. |
| `periodStart` / `periodEnd` | Date/year | Must be displayed or explained when available. |
| `sourceId` | String or null | Must resolve to a cited source record when available. |
| `methodologyKey` | String or null | Required to explain calculation/allocation assumptions when available. |
| `accountingBoundary` | String or null | Describes gases/sectors and consumption or territorial basis; must match or be labeled contextual. |
| `uncertainty` | String or structured range | Explain when supplied by source or method. |
| `unavailableReason` | String or null | Required when status is unavailable. |

### UserDataExport

A transient, user-initiated logical snapshot, not an account credential backup.

| Field | Type | Rules |
|---|---|---|
| `exportSchemaVersion` | Integer | Required for forward compatibility. |
| `createdAt` | UTC timestamp | Required. |
| `userData` | Allowlisted records | Includes personal records and preferences; excludes credential verifiers and keys. |

The export is generated from a consistent database snapshot. User-selected
external copies are outside app deletion control.

### ModuleDestination

Static app-shell metadata, not user data.

| Field | Type | Rules |
|---|---|---|
| `moduleId` | String | Unique stable route key. |
| `titleKey` | Localization key | No inline user-facing title. |
| `route` | String | Unique registered destination. |
| `navigationGroup` | Enum | `homePrimary` or `secondary`. |
| `availability` | Enum | `foundationDestination` until the module's own plan supplies its workflow. |

## State and Validation Rules

- Cold start hydrates preferences and local data before route redirects are
  evaluated; loading is distinct from incomplete onboarding.
- A complete estimate requires a valid selected region, valid selected pack,
  complete answers, compatible units/periods, and valid reference sources.
- A missing or invalid source/factor yields an explicit unavailable state, never
  a numeric fallback from another region.
- All regional packs in one release must agree on `factorCatalogVersion`;
  factor, content, and reference source identifiers must resolve before use.
- The UI reserves three distinct comparison slots, but an unavailable reference
  never renders as a zero-value ring. A compatible sourced 1.5°C target is a
  release gate; an unavailable state prevents release until the source/value is
  verified.
- Region selection and display language are separate values and can change
  independently.
- Account creation and deletion, export snapshot reads, and multi-record writes
  use database transactions. Account deletion cascades to associated user data.
- Data deletion requires explicit confirmation, removes local account and
  associated user records, closes the database before file removal, and returns
  to guest state. Do not promise forensic erasure of flash media or externally
  exported copies.
- Migration tests cover schema creation, previous-version upgrades, data
  preservation, and foreign-key integrity.
- Exact factor values and the 1.5°C methodology are release data gates: no
  invented or unsourced value can satisfy the entity contract.
