# Phase 6C-8 — TestFlight Subscription Test Report

## Purpose

Record the subscription setup, TestFlight testing, and Online Count Pro gate validation before release-readiness work.

## Subscription Setup Summary

- Subscription group: Speech Club Pro
- Subscription name: Speech Club Pro Annual
- Product ID: `speech_club_pro_annual`
- Duration: 1 year
- Introductory offer: first 3 months free
- Price shown in TestFlight: $14.99/year
- Status in App Store Connect: Ready to Submit

## App Store Connect Metadata Completed

- Availability set
- Price set
- Introductory offer set
- English localization added
- Chinese localization added
- Subscription group localization added
- Review screenshot uploaded
- Review notes added
- Status changed from Missing Metadata to Ready to Submit

## Build/Test Summary

- Version: 1.0.3
- Build: 6
- Build uploaded to TestFlight successfully
- Previous upload failure caused by `objective_c.framework` reporting `IOSSIMULATOR`
- Fixed by lockfile update `objective_c` 9.3.0 -> 9.4.1
- Fresh archive verified `objective_c.framework` platform `IOS`
- External TestFlight review passed
- Internal tester installed build 6
- External tester installed build 6

## Test Results

| Test area | Result |
| --- | --- |
| StoreKit product loading | Passed |
| 3-month free trial display | Passed |
| Purchase flow | Passed |
| Pro active state | Passed |
| App restart Pro cache | Passed |
| Manual Count free path | Passed |
| Online Count Pro user path | Passed |
| Online Count non-Pro gate path | Passed |
| External tester install | Passed |
| Build upload validation after fix | Passed |

## Current Behavior

- Manual Count remains free.
- Online Count is soft-gated behind Speech Club Pro.
- Pro users can open Online Count normally.
- Non-Pro users are routed to the Speech Club Pro screen.
- Pro screen includes purchase, restore, and Manual Count fallback.
- Backend behavior is unchanged.

## Known Remaining Release Tasks

- Update privacy policy for Online Count cloud voting data.
- Decide whether to replace the prototype Cloudflare backend URL before public release.
- Update App Store screenshots/metadata if needed.
- Select build 1.0.3 (6) for the new app version.
- Add Speech Club Pro subscription to the app version's In-App Purchases and Subscriptions section.
- Submit app version 1.0.3 and first subscription together.
- Prepare App Review notes.

## Important App Store Note

- Do not submit the first subscription alone.
- Submit the app version and the first subscription together during release preparation.

## Next Recommended Phase

Phase 6D — App Store Release Readiness
