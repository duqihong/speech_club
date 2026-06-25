# Phase 5F-2 — Simplified One-Device Online Count Design

This document revises the Online Count product direction for Speech Club / 演讲俱乐部.

Phase 5F-2 is design-only. It does not modify Flutter UI, Cloudflare Worker code, D1 migrations, Manual Count, or dependencies.

## 1. Design Decision

Online Count MVP will use a strict one-device model:

- one app installation can own only one online club
- one online club can have only one current online meeting
- one meeting can have only one open award voting round at a time
- the club and meeting are not designed to be shared with another phone/user/app installation
- to create a new online club, the current online club must be deleted first
- to create a new online meeting, the current online meeting must be deleted first
- Manual Count remains the safe offline fallback

Official simplified model:

```text
One Speech Club app installation / one phone
-> one online club
-> one current online meeting
-> one active award voting round at a time
```

Online voting is not a critical feature because Manual Count remains available offline after app installation. Therefore, Online Count can accept stricter limits in exchange for simpler behavior and fewer recovery problems.

## 2. Why This Direction

The previous recovery design was more flexible, but it was too complex for the Online Count MVP.

Problems with flexible design:

- user can create multiple clubs
- user can create multiple meetings
- user can change club setup and confuse local/cloud state
- user can get blocked by old open meetings
- the app becomes a developer control panel instead of a guided club tool

New direction:

- reduce freedom
- reduce edge cases
- reduce recovery complexity
- make app easier for senior club officers
- make Online Count optional, while Manual Count remains reliable

The goal is not to support every possible shared-admin workflow in the MVP. The goal is to make one officer's phone able to run one simple online voting workflow without confusing local/cloud state.

## 3. Product Rule

Official Online Count rule:

```text
Set up one online club
-> lock the club
-> create one current meeting
-> run award voting
-> send/copy results
-> delete current meeting
-> create next meeting
```

If user wants a different club:

```text
delete current online club
-> reset local online setup
-> create a new online club
```

Normal users should not freely switch between clubs or meetings. Switching between multiple active clubs or recovering arbitrary historical meetings is outside the MVP.

## 4. One App Installation Ownership

The app should create a private local installation owner token.

Example local key:

```text
speech_club_online_owner_token_v1
```

Rules:

- generated once when Online Count is first set up
- stored only on this app installation
- sent to backend for admin actions
- backend stores only `owner_token_hash`
- backend never stores raw owner token
- another phone cannot manage the same online club even if it knows club code and admin PIN

Admin actions should require:

- club code
- admin PIN
- owner token

This intentionally prevents sharing club management between devices in MVP.

The owner token is not a user-facing password. It is a local device ownership credential that allows the backend to distinguish the original app installation from another device.

## 5. Device Loss / App Deletion Risk

This design accepts a clear MVP limitation.

If user deletes the app, loses the phone, or clears app data:

- owner token may be lost
- old online club may no longer be manageable from another phone
- this is acceptable for MVP because Online Count is optional
- Manual Count remains available offline
- old cloud records will expire automatically

Future optional improvement:

- recovery code
- transfer ownership
- shared officer access

These recovery features are explicitly out of MVP scope.

## 6. Online Club Lifecycle

Online club states:

- none
- active
- deleted
- expired

Rules:

- one owner token can have only one active online club
- creating another club is blocked until current club is deleted or expired
- deleting online club deletes or marks inactive the current club and its current meeting data
- inactive clubs expire after 3 months

Recommended cloud fields later:

```text
clubs:
- club_id
- club_name
- club_slug
- admin_pin_hash
- owner_token_hash
- status: active / deleted / expired
- created_at
- updated_at
- last_active_at
- expires_at
```

Expiry rule:

If a club is inactive for 3 months, it is expired/deleted by scheduled cleanup.

## 7. Online Meeting Lifecycle

Online meeting states:

- none
- draft
- open
- closed
- deleted
- expired

Rules:

- one online club can have only one current meeting
- creating another meeting is blocked until current meeting is deleted or expired
- closing a meeting makes results final but does not automatically allow a new meeting
- user must delete current meeting before creating next meeting
- meeting expires and is deleted within 7 days regardless of status

Recommended cloud fields later:

```text
sessions:
- session_id
- club_id
- meeting_title
- meeting_date
- status: draft / open / closed / deleted / expired
- created_at
- updated_at
- opened_at
- closed_at
- expires_at
```

Expiry rule:

Any meeting older than 7 days is deleted/expired automatically.

## 8. Award Round Lifecycle

Inside current meeting:

Awards:

- Best Speaker
- Best Table Topics Speaker
- Best Evaluator

Award states:

- draft
- open
- closed

Rules:

- only one award can be open at a time
- same permanent QR/link always shows the currently open award
- if no award is open, voters see "Voting is not open now"
- deleting current meeting deletes all award rounds, candidates, votes, and results for that meeting

This keeps the public voting page simple: voters scan one permanent QR code and see only the award that is currently open.

## 9. Delete Current Meeting

User action:

English:

```text
Delete Current Meeting
```

Chinese:

```text
删除当前会议
```

Meaning:

Delete the current online meeting from cloud and local storage.

Warning:

English:

```text
Delete current online meeting?
This will delete candidates, votes, and results for this meeting.
Please copy or send results before deleting.
```

Chinese:

```text
要删除当前在线会议吗？
这会删除本次会议的候选人、投票和结果。
请先复制或发送结果。
```

Require confirmation:

```text
Type DELETE to continue.
```

After delete:

- cloud meeting removed or marked deleted
- local current session ID cleared
- club remains active
- user can create a new meeting

Delete Current Meeting is the normal way to prepare the online club for the next meeting.

## 10. Delete Online Club

User action:

English:

```text
Delete Online Club
```

Chinese:

```text
删除在线俱乐部
```

Meaning:

Delete the online club owned by this app installation.

Warning:

English:

```text
Delete online club?
This will delete the online club, current meeting, candidates, votes, and results.
This cannot be undone.
Manual Count data on this phone will not be deleted.
```

Chinese:

```text
要删除在线俱乐部吗？
这会删除云端俱乐部、当前会议、候选人、投票和结果。
此操作无法撤销。
本机手动计票资料不会被删除。
```

Require confirmation:

```text
Type DELETE to continue.
```

After delete:

- cloud club removed or marked deleted
- current meeting removed or marked deleted
- local online setup cleared
- owner token may be kept or regenerated later
- Manual Count data remains
- president contact remains unless separately reset

Delete Online Club is required before creating a different online club.

## 11. Reset This Device Setup

Separate local-only action:

English:

```text
Reset Online Count on This Device
```

Chinese:

```text
重置本机在线计票资料
```

Meaning:

Clear local Online Count setup only.

Does clear:

- local club name
- local club code
- local admin PIN
- local current session ID
- cached meeting title/date
- local backend URL reset to default if needed

Does not clear:

- cloud club
- cloud meeting
- cloud votes
- cloud results
- Manual Count
- president contact

Warning:

English:

```text
This clears online voting setup saved on this phone.
It does not delete cloud records.
```

Chinese:

```text
这会清除本机保存的在线投票设置。
不会删除云端记录。
```

Require confirmation:

```text
Type RESET to continue.
```

Reset This Device Setup should not be presented as a normal way to switch clubs. It is a local recovery action for this phone only.

## 12. Cloud Expiry and Cleanup

Cleanup rules:

Meeting cleanup:

- any meeting expires/deletes within 7 days
- this prevents old meetings blocking the user forever

Club cleanup:

- inactive clubs expire/delete after 3 months
- inactivity means no owner/admin activity
- updating, voting, opening/closing meeting, or refreshing status should update `last_active_at`

Recommended implementation later:

- Cloudflare scheduled Worker cleanup once per day
- lazy cleanup on API calls as backup

Expiry is part of the simplified model. It reduces the need for complex recovery when a phone is lost or a meeting is forgotten.

## 13. Backend Enforcement Rules

Future backend must enforce:

- owner token required for admin actions
- one owner token can have only one active club
- one club can have only one current meeting
- no second meeting if current meeting exists
- no second club if current active club exists
- deleting current meeting required before creating new meeting
- deleting online club required before creating new club
- expired meetings/clubs should not block new setup
- public voting does not require owner token or admin PIN

Backend enforcement is required because local UI rules alone are not enough. The cloud must reject invalid second club and second meeting creation attempts.

## 14. Flutter Flow Direction

Future Flutter Online Count should become guided.

If no online club:

- Create Online Club

If online club exists:

- show locked club summary
- show Permanent QR / Voting Link
- show Current Meeting section

If no current meeting:

- Create Current Meeting

If current meeting exists:

- show meeting status
- allow award voting actions
- allow results
- allow Delete Current Meeting

If user wants a new club:

- Delete Online Club first

Do not show free editable Club Code / Backend URL / Admin PIN during normal operation.

## 15. Difference Between Manual Count and Online Count

Manual Count:

- offline
- always available
- safest fallback
- not affected by phone loss/cloud expiry

Online Count:

- optional
- one-device ownership
- cloud-backed
- expires automatically
- designed for QR/web voting convenience only

Manual Count makes the stricter Online Count model acceptable. If Online Count ownership is lost, expired, or blocked, the club can still count votes manually on the installed app.

## 16. Updated Future Phase Plan

Phase 5F-2:

- Simplified one-device Online Count design. No code.

Phase 5G:

- Cloudflare owner-token, one-club, one-current-meeting API design/code.

Expected backend additions:

- owner token support
- create club with owner token
- verify owner
- delete current meeting
- delete online club
- current status endpoint
- daily cleanup logic
- 7-day meeting expiry
- 3-month inactive club expiry

Phase 5H:

- Flutter guided one-device Online Count flow.

Expected Flutter changes:

- generate/store owner token
- lock club setup after creation
- hide free club editing
- delete current meeting
- delete online club
- reset local setup
- show clearer guided next actions

Phase 5I:

- Real meeting test and usability polish.

## 17. Acceptance Criteria

This design answers:

- Can one app installation create multiple online clubs?
- Can one online club have multiple current meetings?
- What must happen before creating a new club?
- What must happen before creating a new meeting?
- Can another phone manage the same club?
- What happens if the phone/app is lost?
- What expires after 7 days?
- What expires after 3 months?
- What is deleted locally vs cloud?
- Why Manual Count makes this stricter model acceptable?

Answers:

- One app installation cannot create multiple active online clubs.
- One online club cannot have multiple current meetings.
- Before creating a new club, the current online club must be deleted or expired.
- Before creating a new meeting, the current meeting must be deleted or expired.
- Another phone cannot manage the same club in the MVP, even if it knows the club code and admin PIN.
- If the phone/app is lost, the owner token may be lost and the old cloud club may no longer be manageable; old records expire automatically.
- Any meeting expires/deletes within 7 days.
- Inactive clubs expire/delete after 3 months.
- Reset This Device Setup deletes only local Online Count setup; Delete Current Meeting and Delete Online Club affect cloud records and local current state as described.
- Manual Count makes the stricter model acceptable because it remains offline, reliable, and available even when Online Count is unavailable.

## 18. Validation

Docs-only phase.

Run:

```text
dart format .
flutter analyze
flutter test
```

Do not run iOS build unless code files were unexpectedly changed.

## 19. Git Discipline

Before commit:

```text
git status
git diff --stat
git diff -- docs/phase_5f_2_one_device_online_count_design.md
git diff -- pubspec.yaml
git diff -- ios/Runner.xcodeproj/project.pbxproj
```

Expected:

Only `docs/phase_5f_2_one_device_online_count_design.md` should be staged.

Do not commit:

- `pubspec.yaml` version bump
- `ios/Runner.xcodeproj/project.pbxproj` version bump
- Flutter code
- Cloudflare code
- D1 migrations
- local artifacts
