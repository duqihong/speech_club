# Phase 6B — StoreKit / In-App Purchase Technical Plan

## Purpose

Plan how Speech Club Pro will be implemented using Apple In-App Purchase / StoreKit before any code changes.

Phase 6B is planning only. It does not change Dart app code, UI, dependencies, iOS project settings, backend code, Cloudflare Worker code, or D1 migrations.

## Recommended Implementation Approach

- Use the Flutter `in_app_purchase` package.
- iOS will use StoreKit through `in_app_purchase_storekit`.
- Do not add RevenueCat for the first implementation.
- Keep implementation simple because there is only one yearly Pro subscription.
- Consider server-side validation later if needed.

## App Store Connect Setup Checklist

- Ensure Paid Applications Agreement, banking, and tax information are complete.
- Create subscription group: `Speech Club Pro`.
- Create auto-renewable subscription: `Speech Club Pro Annual`.
- Product ID: `speech_club_pro_annual`.
- Duration: `1 year`.
- Price: closest App Store Connect price point to `S$14.98/year`.
- Introductory offer: `3 months free`.
- Add localized display name and description.
- Prepare subscription review screenshot when app UI is ready in a later phase.

## Entitlement Model

- Internal entitlement name: `speechClubPro`.
- User has Pro if StoreKit reports an active subscription for `speech_club_pro_annual`.
- Manual Count must never depend on this entitlement.
- Online Count will depend on this entitlement in Phase 6C.
- Store entitlement state locally only as cached convenience, not as final proof.

## Product Loading Flow

- App asks StoreKit for product ID `speech_club_pro_annual`.
- If product loads, show the real localized price from StoreKit.
- If product does not load, show safe fallback text and disable the purchase button or show `Subscription temporarily unavailable.`
- Do not hardcode the final Apple purchase price as the source of truth.

## Purchase Flow

- User opens Online Count.
- If not Pro, show the Speech Club Pro screen.
- User taps `Start 3-Month Free Trial`.
- App starts purchase for `speech_club_pro_annual`.
- On successful purchase, app updates the `speechClubPro` entitlement.
- User can continue to Online Count.
- If purchase is cancelled, app stays free and Manual Count remains available.
- If purchase fails, show a friendly error and keep Manual Count available.

## Restore Flow

- Add `Restore Purchases` action on the Pro screen or Settings.
- Restore checks previous purchases/subscriptions through StoreKit.
- If an active subscription is found, unlock `speechClubPro`.
- If none is found, show `No active Speech Club Pro subscription found.`

## Soft Paywall Flow

- Free users may view the Online Count explanation and Pro offer.
- Free users may not create an online club, share a permanent QR, start online voting, or use the live vote counter.
- Free users can always choose Manual Count for free.
- Existing Manual Count workflow must remain unchanged.

## Suggested App Architecture For Phase 6C

- Add a small Pro entitlement service.
- Add a Pro screen.
- Add restore purchase action.
- Add purchase state loading/error states.
- Gate Online Count entry only.
- Do not touch Manual Count logic except navigation fallback if needed.

## Suggested Files Likely To Change Later

Planning only. Do not modify these files in Phase 6B:

- `pubspec.yaml`
- `lib/src/services/pro_entitlement_service.dart` or similar
- `lib/src/screens/pro/pro_screen.dart` or similar
- Home / Online Count navigation files
- Settings screen for Restore Purchases
- Localization files if the project uses centralized strings

## Test Plan For Phase 6D

- Test product loading in sandbox/TestFlight.
- Test first-time free trial purchase.
- Test cancel purchase.
- Test restore purchase.
- Test expired subscription behavior if possible.
- Test app reinstall and restore.
- Test no-internet behavior.
- Test Online Count unavailable if not Pro.
- Test Manual Count remains usable without Pro.
- Test Chinese and English paywall wording.

## Risk Notes

- StoreKit products may not load if App Store Connect metadata is incomplete.
- First subscription review may require submitting app and subscription together.
- TestFlight subscription behavior can differ from production timing.
- Price/trial text should come from StoreKit when possible.
- Backend validation is not required for the first simple version, but may be useful later.

## Backend Validation Later

- Phase 6C can start with client-side entitlement.
- A future phase may use App Store Server API / App Store Server Notifications.
- Backend validation could protect Online Count API access more strongly.
- Do not implement backend validation in Phase 6B.

## Rollback Plan

- If StoreKit implementation causes issues later, disable the Pro gate and keep Online Count or Manual Count fallback safe.
- Manual Count must always remain independent.

## Final Recommendation

- Phase 6B is planning only.
- Phase 6C should implement the Pro screen and StoreKit integration in small steps.
- Do not gate existing Online Count until product loading, purchase, restore, and entitlement checks are stable.
