# Foundation User Interface Contract

This contract defines the app-shell routes and observable navigation behavior.
Module routes are foundation destinations only; their domain workflows are
specified in their own feature plans.

## Destinations

| Destination | Route key | Home placement | Contract |
|---|---|---|---|
| Guest onboarding and estimate | `onboarding` | First launch | Region is selected before regional comparison; estimate and three references display before any login wall. |
| Home | `home` | Root | All 11 required module destinations are visible and navigable; About Us is reachable. |
| Carbon Footprint Tracker | `carbon-footprint` | Primary | Reachable from Home; detailed tracker workflow deferred. |
| Eco-Friendly Product Suggestions | `product-suggestions` | Primary | Reachable from Home; detailed workflow deferred. |
| Sustainable Living Challenges | `challenges` | Primary | Reachable from Home; detailed workflow deferred. |
| Green Certifications & Labels Guide | `certifications` | Primary | Reachable from Home; detailed content deferred. |
| Waste Reduction Tracker | `waste-tracker` | Primary | Reachable from Home; detailed workflow deferred. |
| Sustainable Recipes & Meal Planning | `recipes` | Primary | Reachable from Home; detailed workflow deferred. |
| Energy Conservation Tips | `energy-tips` | Primary | Reachable from Home; detailed content deferred. |
| Eco-Travel Suggestions | `eco-travel` | Primary | Reachable from Home; detailed workflow deferred. |
| Community Journal | `community-journal` | Primary | Reachable from Home; local-first journal destination; detailed UGC safety behavior deferred to its plan. |
| Sustainability Progress Dashboard | `progress` | Primary | Reachable from Home; detailed dashboard deferred. |
| Educational Content | `education` | Primary | Reachable from Home; detailed content deferred. |
| Account registration/login | `account` | Optional | On-device only; never required for browsing. |
| Settings and privacy | `settings` | Secondary | Includes policy, export, delete, language, region, and accessibility preferences. |
| About Us | `about` | Home-accessible | Readable offline. |
| Image Gallery | `gallery` | Secondary | Reachable but not a primary Home destination. |
| Contact Us | `contact` | Secondary | Reachable but not a primary Home destination. |

## Observable Rules

1. On first launch, the app offers region selection and the brief estimate before
   any account wall. The user may skip onboarding and continue as a guest.
2. The selected data region is not inferred or changed merely because the display
   language changes. Language defaults to English.
3. If no valid regional pack/reference is available, the app states that the
   regional comparison is unavailable; it does not substitute another region's
   value without explicit scope labeling.
4. The three estimate comparisons use compatible units and periods. Each ring
   has an equivalent readable text value, source/date access, and semantic label;
   color alone does not distinguish the values. The 1.5°C target must use a
   documented allocation method and compatible accounting boundary. If no such
   target is verified, release is blocked; never draw an empty or zero-value ring
   as though it were a valid budget.
5. Router redirects wait for initial local-state hydration and preserve the
   requested destination across onboarding. A guest can always reach public
   content.
6. Reduced-motion mode retains the same information and task completion path.
   Motion never blocks input and is interruptible.
7. All visible interface copy resolves from generated localization resources;
   route titles and accessibility labels are localizable.
8. Gallery and Contact Us remain in secondary navigation. All 11 required
   module entries and About Us remain reachable from Home.

## Foundation Acceptance Coverage

- Fresh install, unselected/selected region, skipped/completed estimate, and
  login-free result.
- Home module route inventory and secondary destinations.
- Router cold-start hydration, onboarding redirect, and retained deep-link intent.
- Local account success/failure, export, confirmed deletion, and guest return.
- Language changes do not alter regional data; region changes update applicable
  values.
- Missing/invalid factor, source, pack, and comparison states remain explicit.
- The selected-region and global averages identify their accounting boundary;
  non-like-for-like values are labeled contextual rather than comparable.
- Ring labels and exact values are available to assistive technology.
- Reduced-motion and release-mode performance checks on both target platforms.
