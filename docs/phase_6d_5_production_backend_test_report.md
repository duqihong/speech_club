# Phase 6D-5 — Production Backend TestFlight Test Report

## Purpose

Record that the app was updated to the production Cloudflare Worker backend and successfully tested through TestFlight on physical iPhone 11.

## Build Tested

- Version: 1.0.3
- Build: 7
- Base tag: phase-6d-4-production-backend-url
- Device: physical iPhone 11
- Distribution: TestFlight

## Backend Tested

- Production Worker: speech-club-vote
- Production URL: https://speech-club-vote.duduqihong.workers.dev
- Production D1 database: speech-club-vote-production
- D1 ID: e6d9db95-7f01-4d3f-bc75-55bf63d17f4f
- Binding: DB

## Test Results

| Test area | Result |
| --- | --- |
| App launch | Passed |
| Speech Club Pro active state | Passed |
| Manual Count free path | Passed |
| Online Count Pro access | Passed |
| Production backend connection | Passed |
| Permanent QR flow | Passed |
| Vote submission | Passed |
| Live vote counter | Passed |
| Result flow | Passed |
| WhatsApp result sending | Passed, if confirmed |
| Prototype backend not required | Passed |

## Important Confirmation

- The app now uses the production backend URL.
- Old prototype backend URL is no longer used by Flutter app code.
- Prototype backend remains unchanged for reference/testing only.
- Manual Count remains free and offline.
- Online Count remains soft-gated behind Speech Club Pro.
- Product ID speech_club_pro_annual is unchanged.

## Known Remaining Release Tasks

- Update privacy policy for Online Count cloud voting data.
- Update App Store Connect App Privacy answers if needed.
- Refresh App Store screenshots/metadata if needed.
- Add Speech Club Pro subscription to the app version before submission.
- Submit app version 1.0.3 and Speech Club Pro subscription together.
- Prepare final App Review notes.

## Next Recommended Phase

Phase 6D-6 — Privacy Policy and App Store Privacy Update
