# Phase 5H-2 — Online Count State Machine and QR Sharing Design

This document rethinks Speech Club / 演讲俱乐部 Online Count as a strict state machine.

Phase 5H-2 is design-only. It does not modify Flutter UI, Cloudflare Worker code, D1 migrations, Manual Count, or dependencies.

## 1. Problem Statement

Phase 5H introduced the one-device guided Online Count flow, but real testing still found a stuck state:

- the backend correctly enforces one active online club per owner token
- the app can still enter Setup Mode while the owner token already has an active cloud club
- trying to create another club then returns: "This device already has an active online club"
- this reveals a deeper flow problem, not just one missing recovery endpoint

We do not want to patch only one stuck case.

We need to redesign Online Count as a strict state machine.

## 2. Core Design Principle

Online Count must always show one clear next action.

The user should not need to understand:

- local state
- cloud state
- owner token
- session ID
- backend errors
- recovery logic

The app should guide the user through safe states. Each state should show only the actions that make sense now and hide actions that would create confusion.

## 3. Manual Count as Safety Net

Online Count is optional.

Manual Count remains the reliable offline fallback.

Therefore, Online Count can use stricter rules and a simpler emergency path. We do not need complicated recovery logic for every possible cloud/local mismatch, because club officers can still count votes offline with Manual Count after the app is installed.

## 4. Final MVP Rule

Final MVP rule:

```text
One app installation
-> one owner token
-> one online club
-> one current meeting
-> one open award voting round at a time
```

Rules:

- one app installation can own only one online club
- one online club can have only one current meeting
- one current meeting can have only one open award round
- to create a new meeting, delete the current meeting first
- to create a new club, delete the current online club first
- other phones cannot manage this club
- abandoned cloud data expires automatically

## 5. Strict State Machine

### State A: No Online Club

User sees:

- Create Online Club
- Start Fresh on This Device, hidden under Danger Zone or Advanced Reset if needed

User should not see:

- meeting controls
- QR code
- results
- candidate setup
- award voting controls

### State B: Online Club Ready, No Current Meeting

User sees:

- locked club summary
- permanent QR code
- Share QR Code Image
- Copy QR Link, optional fallback
- Create Current Meeting
- Delete Online Club

### State C: Current Meeting Draft

User sees:

- meeting title/date/status
- candidate setup
- Open Meeting
- Delete Current Meeting

User should not see:

- result sending
- create another meeting

### State D: Current Meeting Open

User sees:

- meeting status
- award voting controls
- open/close one award at a time
- voting QR/link
- Close Meeting
- Delete Current Meeting

User should not see:

- create another meeting
- edit closed/open award candidates

### State E: Current Meeting Closed

User sees:

- final results
- Copy Results
- Send Results to President
- Delete Current Meeting

User should not see:

- Create Current Meeting until the current meeting is deleted

## 6. Allowed Actions by State

| State | Allowed Actions | Hidden / Disabled Actions | What Happens Next |
| --- | --- | --- | --- |
| No Online Club | Create Online Club; Start Fresh | Create Meeting; QR; Results; Candidate Setup; Award Voting | Create Online Club moves to Online Club Ready. Start Fresh stays in No Online Club with a new owner token. |
| Online Club Ready | Create Current Meeting; Share QR Code Image; Copy QR Link; Delete Online Club | Edit Club Code; Create another club; Results; Award Voting | Create Current Meeting moves to Meeting Draft. Delete Online Club returns to No Online Club. |
| Meeting Draft | Save Candidates; Open Meeting; Delete Current Meeting | Send Results; Create another meeting; Award Voting before meeting opens | Open Meeting moves to Meeting Open. Delete Current Meeting returns to Online Club Ready. |
| Meeting Open | Open one award; Close current award; Close Meeting; Delete Current Meeting | Create another meeting; Edit closed/open award candidates | Close Meeting moves to Meeting Closed. Delete Current Meeting returns to Online Club Ready. |
| Meeting Closed | Refresh Results; Copy Results; Send Results to President; Delete Current Meeting | Create Current Meeting until current meeting is deleted; Open award voting; Edit candidates | Delete Current Meeting returns to Online Club Ready, where Create Current Meeting becomes available. |

## 7. Start Fresh on This Device

Button:

English:

```text
Start Fresh on This Device
```

Chinese:

```text
本机重新开始
```

Purpose:

A simple escape hatch when the user gets stuck during testing or wrong setup.

Behavior:

- clear local Online Count setup
- generate a new owner token
- return to No Online Club state
- do not call Cloudflare
- do not attempt to recover old cloud data
- do not delete Manual Count data
- do not delete president contact

Warning text:

English:

```text
Start fresh?
This will disconnect this phone from the previous online club.
Old online test data may remain in the cloud until it expires.
The old QR code should no longer be used.
Manual Count data will not be deleted.
```

Chinese:

```text
要重新开始吗？
这会让本机断开之前的在线俱乐部。
旧的在线测试资料可能会保留在云端，直到自动过期。
旧二维码不应继续使用。
本机手动计票资料不会被删除。
```

Require confirmation:

```text
Type FRESH to continue.
```

## 8. Difference Between Reset, Delete Meeting, Delete Club, Start Fresh

### A. Reset Online Count on This Device

Local-only.

Keeps owner token.

Does not delete cloud data.

Used for minor local cleanup.

### B. Delete Current Meeting

Cloud + local.

Deletes current meeting, candidates, votes, and results.

Keeps online club and QR code.

Allows next meeting to be created.

### C. Delete Online Club

Cloud + local.

Deletes online club and current meeting data.

Old QR becomes invalid.

Allows new online club to be created.

### D. Start Fresh on This Device

Local-only emergency.

Generates new owner token.

Abandons old cloud club until expiry.

Old QR should not be used.

Manual Count remains untouched.

## 9. QR Code Lifecycle

Core rule:

QR code belongs to the Online Club, not to the Meeting.

Therefore:

- Create Current Meeting does not change QR
- Delete Current Meeting does not change QR
- Create next meeting does not change QR
- Open/close award voting does not change QR
- Delete Online Club makes old QR invalid
- Start Fresh abandons old QR
- New Online Club creates a new QR

## 10. QR Sharing Scope

Define the QR sharing feature narrowly.

Main feature:

```text
Share QR Code Image
```

Do not add:

- PDF export
- print card
- schedule template
- complex print layout
- extra document generation

Existing Copy QR Link can remain as fallback, but the preferred workflow is:

```text
Online Club Ready
-> Permanent QR appears
-> User taps Share QR Code
-> iPhone share sheet opens
-> User sends QR image by WhatsApp, AirDrop, Email, or Messages
-> schedule designer inserts QR image into printed meeting schedule
```

## 11. QR Sharing Wording

Recommended app wording:

English:

```text
Share this QR code with the person preparing the meeting schedule.
This QR code belongs to the online club and can be reused for every meeting.
```

Chinese:

```text
可将此二维码分享给制作会议流程表的人。
此二维码属于在线俱乐部，可重复用于每次会议。
```

Start Fresh warning:

English:

```text
After Start Fresh, the old QR code should no longer be used.
```

Chinese:

```text
重新开始后，旧二维码不应继续使用。
```

## 12. Public QR Page Behavior

What voters see:

- No meeting: Voting is not open now.
- Meeting exists but no award open: Voting is not open now.
- Best Speaker open: Show Best Speaker only.
- Table Topics open: Show Best Table Topics Speaker only.
- Evaluator open: Show Best Evaluator only.
- Meeting deleted: Voting is not open now.
- Online club deleted: Voting is not open now, or club not found.

## 13. Cloud Expiry Role

Cloud expiry is the cleanup mechanism for abandoned Online Count data.

Meetings:

- expire/delete within 7 days

Inactive clubs:

- expire/delete after 3 months

This means Start Fresh can safely abandon old test data because:

- old meetings will disappear soon
- old inactive clubs will disappear later
- Manual Count remains available

## 14. No Recovery Endpoint for Now

Do not implement "recover existing online club" in MVP.

Reason:

Recovery adds more branches and increases complexity.

Online Count is optional.

Start Fresh plus cloud expiry is simpler.

Future optional improvement:

- recover existing club by owner token
- transfer ownership
- recovery code
- multi-officer sharing

These are out of MVP scope.

## 15. Backend Implications for Future Coding

Future backend changes may need:

- support for Start Fresh only on Flutter side, no backend call
- no need to recover old club
- delete current meeting remains important
- delete online club remains important
- cloud expiry already exists from Phase 5G
- owner-token one-club rule remains enforced

No new Cloudflare endpoint should be designed in this document unless strictly needed.

## 16. Flutter Implications for Future Coding

Future Flutter Phase should:

- implement strict state rendering
- hide irrelevant sections by state
- add Start Fresh on This Device
- generate new owner token when Start Fresh is confirmed
- make Share QR Code Image the only new QR sharing feature
- keep Copy QR Link as fallback
- keep Manual Count untouched

## 17. Edge Case Simulation

### 1. Fresh install

State shown:

- No Online Club

Allowed actions:

- Create Online Club
- Start Fresh under Danger Zone or Advanced Reset, if shown

How user continues:

- Enter club details and create the online club.

### 2. Create club succeeds

State shown:

- Online Club Ready, No Current Meeting

Allowed actions:

- Share QR Code Image
- Copy QR Link
- Create Current Meeting
- Delete Online Club

How user continues:

- Share QR if needed, then create the current meeting.

### 3. Create club fails because club code exists

State shown:

- No Online Club

Allowed actions:

- Edit club code
- Create Online Club again
- Start Fresh if the user suspects local test state is wrong

How user continues:

- Choose another club code.

### 4. Create club fails because owner token already has active club

State shown:

- No Online Club with a clear blocked message

Allowed actions:

- Start Fresh on This Device

How user continues:

- Use Start Fresh to generate a new owner token and abandon the old test club until expiry.

### 5. App closed and reopened

State shown:

- The state derived from local saved setup and cloud status.

Allowed actions:

- Only actions for that state.

How user continues:

- Continue the current workflow or Check Online Status if shown.

### 6. Local setup reset accidentally

State shown:

- No Online Club, but old owner token may remain if only reset was used.

Allowed actions:

- Create Online Club may fail if the owner token already owns a cloud club.
- Start Fresh on This Device.

How user continues:

- Use Start Fresh if the owner token is blocked by abandoned cloud state.

### 7. User uses Start Fresh

State shown:

- No Online Club

Allowed actions:

- Create Online Club

How user continues:

- Create a new online club with a new owner token.

### 8. Old QR after Start Fresh

State shown:

- Not applicable inside the new app state.

Allowed actions:

- Do not use old QR.

How user continues:

- Share the new online club QR after creating a new club.

### 9. Meeting draft exists

State shown:

- Current Meeting Draft

Allowed actions:

- Save Candidates
- Open Meeting
- Delete Current Meeting

How user continues:

- Add candidates and open the meeting, or delete the draft.

### 10. Meeting open

State shown:

- Current Meeting Open

Allowed actions:

- Open one award
- Close current award
- Close Meeting
- Delete Current Meeting

How user continues:

- Run award rounds one by one.

### 11. Award open

State shown:

- Current Meeting Open with active award

Allowed actions:

- Close current award
- Close Meeting if appropriate
- Delete Current Meeting

How user continues:

- Close the award before opening the next award.

### 12. Meeting closed

State shown:

- Current Meeting Closed

Allowed actions:

- Refresh Results
- Copy Results
- Send Results to President
- Delete Current Meeting

How user continues:

- Save/share results, then delete the current meeting before the next meeting.

### 13. User wants next meeting

State shown:

- If old meeting exists, current meeting state remains shown.

Allowed actions:

- Delete Current Meeting

How user continues:

- Delete current meeting, then create the next meeting.

### 14. User wants different club

State shown:

- Existing online club state if a club exists.

Allowed actions:

- Delete Online Club
- Start Fresh on This Device only as emergency

How user continues:

- Delete Online Club to invalidate old QR and create a new club.

### 15. No internet

State shown:

- Current local state with an offline/error message when cloud actions fail.

Allowed actions:

- Manual Count remains available.

How user continues:

- Use Manual Count or retry Online Count when internet is available.

### 16. Wrong admin PIN

State shown:

- Current state remains unchanged with an admin PIN error.

Allowed actions:

- Re-enter PIN where appropriate
- Start Fresh if this is test setup and the user cannot recover

How user continues:

- Correct the PIN or use Start Fresh for test data.

### 17. Meeting expired after 7 days

State shown:

- Online Club Ready, No Current Meeting after status refresh/cleanup.

Allowed actions:

- Create Current Meeting

How user continues:

- Create a new meeting.

### 18. Club expired after 3 months

State shown:

- No Online Club, or cloud error indicating club no longer exists.

Allowed actions:

- Create Online Club
- Start Fresh if local state remains confusing

How user continues:

- Create a new online club and QR.

### 19. User deletes app

State shown:

- Fresh install after reinstall.

Allowed actions:

- Create Online Club

How user continues:

- Create a new online club. Old cloud data expires automatically.

### 20. User uses Manual Count instead

State shown:

- Manual Count flow, outside Online Count.

Allowed actions:

- Normal Manual Count vote counting and result sharing.

How user continues:

- Count votes offline without depending on cloud state.

## 18. Acceptance Criteria

This design answers:

- What is the only next action in each state?
- When is QR visible?
- When does QR stay the same?
- When does QR become invalid?
- What does Start Fresh do?
- What does Start Fresh not do?
- Why are we not recovering old cloud clubs?
- How does Manual Count reduce risk?
- What actions are hidden in each state?
- What future coding changes are needed?

Answers:

- Each state has a small allowed-action set listed in the state table.
- QR is visible after Online Club Ready and remains visible through meeting states.
- QR stays the same across creating/deleting meetings and opening/closing award rounds.
- QR becomes invalid when the online club is deleted; Start Fresh abandons the old QR and it should no longer be used.
- Start Fresh clears local Online Count setup, generates a new owner token, and returns to No Online Club.
- Start Fresh does not call Cloudflare, recover old cloud data, delete Manual Count, or delete president contact.
- We are not recovering old cloud clubs because recovery adds more branches, Online Count is optional, and cloud expiry cleans abandoned data.
- Manual Count reduces risk because officers can always count offline if Online Count is blocked or confusing.
- Hidden actions are defined for each state in the strict state machine and allowed-actions table.
- Future coding needs strict state rendering, Start Fresh, new owner-token generation on Start Fresh, narrow QR image sharing, and no Manual Count changes.

## 19. Validation

Docs-only phase.

Run:

```text
dart format .
flutter analyze
flutter test
```

Do not run iOS build unless code files were unexpectedly changed.

## 20. Git Discipline

Before commit:

```text
git status
git diff --stat
git diff -- docs/phase_5h_2_online_count_state_machine_design.md
git diff -- pubspec.yaml
git diff -- ios/Runner.xcodeproj/project.pbxproj
```

Expected:

Only `docs/phase_5h_2_online_count_state_machine_design.md` should be staged.

Do not commit:

- `pubspec.yaml` version bump
- `ios/Runner.xcodeproj/project.pbxproj` version bump
- Flutter code
- Cloudflare code
- D1 migrations
- local artifacts
