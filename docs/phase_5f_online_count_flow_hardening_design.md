# Phase 5F — Online Count Flow Hardening Design

This document defines the next official product direction for Speech Club / 演讲俱乐部 Online Count flow hardening.

Phase 5F is design-only. It does not modify Flutter UI, Cloudflare Worker code, D1 migrations, Manual Count, or dependencies.

## 1. Problem Statement

Phase 5C, Phase 5D, and Phase 5E made Online Count functional: officers can create an online club, run meeting voting rounds, reuse a permanent QR code, view results, and send results to the president.

The current flow is still fragile because it behaves too much like a developer control panel. Normal club officers can change too many setup fields at the wrong time and can become stuck when local iPhone state no longer matches Cloudflare state.

Current problems:

- user can edit Club Setup too freely
- user can change Club Code after creating a club
- user can create multiple online clubs
- user can create multiple meetings
- app can point to one local draft while Cloudflare already has another open meeting
- backend may say "Another meeting session is already open"
- user cannot see, recover, or close the old open meeting
- local iPhone state and Cloudflare state can become inconsistent
- the screen behaves too much like a developer control panel

The cloud must become the source of truth for Online Count.

## 2. Core Product Rule

Online Count should follow this product rule:

```text
Set up online club once
-> Lock club setup
-> Manage one current meeting workflow
-> Close meeting
-> Start next meeting
```

It should not follow this pattern:

```text
Edit everything anytime
-> create many clubs
-> create many meetings
-> recover manually when stuck
```

The app should guide officers through one current meeting workflow and make unusual actions, such as switching clubs or resetting local setup, deliberate.

## 3. Two Main Modes

Online Count should have two main modes.

### A. Setup Mode

Setup Mode appears only when no online club is connected on this device.

User can choose:

- Create New Online Club
- Connect to Existing Online Club

After either action succeeds:

- club setup becomes locked
- app enters Meeting Mode

### B. Meeting Mode

Meeting Mode appears after a club is connected.

Main sections:

- Current Online Club
- Cloud Status
- Current Meeting
- Award Voting Rounds
- Permanent QR / Voting Link
- Results

Club Code, Backend URL, and Admin PIN should not be freely edited during normal meeting use.

## 4. Locked Club Setup

After an online club is created or connected, the normal screen should show read-only status:

```text
Online Club Ready
Club Name
Club Code
Permanent Voting Link
```

Editable setup fields should not be shown by default after connection.

Provide a separate action:

```text
Manage Club Setup
```

Inside Manage Club Setup:

- Switch to Another Club
- Reset This Device Setup
- Advanced Settings

Changing club must be deliberate, not simple text-field editing.

## 5. Switch Club Flow

User taps:

```text
Switch to Another Club
```

Warning text:

English:

```text
This will disconnect this phone from the current online club.
It will not delete cloud voting records.
Only continue if you know the club code and admin PIN for the club you want to use.
```

Chinese:

```text
这会让本机断开当前在线俱乐部。
不会删除云端投票记录。
请确认您知道要使用的俱乐部代号和管理员密码后再继续。
```

Require confirmation:

```text
Type SWITCH to continue.
```

After confirmation:

- clear local online club setup
- keep president contact
- keep Manual Count data
- return to Setup Mode

## 6. Reset This Device Setup

Button:

English:

```text
Reset Online Count on This Device
```

Chinese:

```text
重置本机在线计票资料
```

Meaning:

Clear only local Online Count setup saved on this phone.

Clear:

- backend URL if appropriate, or reset to default
- club name
- club code
- admin PIN
- current session ID
- current meeting title/date
- cached online setup/session state

Do not clear:

- Manual Count votes
- Manual Count president contact unless explicitly chosen
- cloud clubs
- cloud meetings
- cloud candidates
- cloud votes
- cloud results

Warning text:

English:

```text
This clears online voting setup saved on this phone.
It does not delete online club, meeting, or voting records from the cloud.
```

Chinese:

```text
这会清除本机保存的在线投票设置。
不会删除云端的俱乐部、会议或投票记录。
```

Require confirmation:

```text
Type RESET to continue.
```

## 7. Cloud Data Handling

Wrong online clubs and meetings should be handled differently depending on whether the data is test/prototype data or real production data.

### A. Test/prototype data

During development, wrong test data can be:

- closed
- archived
- deleted manually from D1 if safe
- wiped if the whole database is only test data

### B. Real production data

Do not casually delete real club voting records.

For real use:

- close meetings
- archive old records
- avoid hard-delete by default
- deletion should require strong confirmation and admin authority

Recommended MVP behavior:

Close wrong open meetings first. Do not delete cloud records from the app yet.

## 8. Meeting Model

One club may have many meetings over time.

Only one meeting can be open per club at the same time.

Meeting states:

- No current meeting
- Draft current meeting
- Open current meeting
- Closed current meeting

The app should not encourage many draft meetings. For MVP, the app should show one current meeting workflow at a time.

## 9. Meeting State Rules

### A. Draft

Meaning:

Meeting is prepared but not open to voters.

Allowed:

- edit meeting title/date
- add/edit candidates
- open meeting
- cancel draft meeting, optional later

Not allowed:

- voting
- final results

### B. Open

Meaning:

Meeting is active. Award voting rounds can be opened one by one.

Allowed:

- open one award voting round
- close current award round
- refresh results
- close meeting

Not allowed:

- create another open meeting
- edit candidates for open/closed awards
- change club setup

### C. Closed

Meaning:

Meeting is finished. Results are final.

Allowed:

- view results
- copy results
- send results to president
- start new meeting

Not allowed:

- reopen meeting
- open award voting
- edit candidates
- vote

## 10. Award Round Rules

Inside one open meeting, each award has status:

```text
draft / open / closed
```

Awards:

- Best Speaker
- Best Table Topics Speaker
- Best Evaluator

Only one award can be open at a time.

Flow:

```text
Open Best Speaker Voting
-> voters vote
-> close Best Speaker Voting

Open Table Topics Voting
-> voters vote
-> close Table Topics Voting

Open Evaluator Voting
-> voters vote
-> close Evaluator Voting

Close Meeting
```

The same permanent QR/link always points to the currently open award.

## 11. Cloud as Source of Truth

Local iPhone storage is only convenience state.

Cloudflare is the source of truth for Online Count.

On opening Online Count, the app should eventually call Cloudflare to check:

- whether club exists
- whether admin PIN is valid
- whether an open meeting exists
- whether a draft/current meeting exists
- which award round is open
- latest results

The app should not rely only on saved local session ID.

## 12. Check Online Status Flow

Define a future action:

English:

```text
Check Online Status
```

Chinese:

```text
检查云端状态
```

Behavior:

The app asks the cloud what is currently active for this club.

Possible results:

### A. No open meeting

Show:

```text
No meeting is currently open.
You can start a new meeting.
```

Actions:

- Start New Meeting
- View Latest Closed Meeting, optional later

### B. Open meeting exists

Show:

```text
An open meeting already exists.
```

Display:

- meeting title
- meeting date
- session status
- open award if any

Actions:

- Use This Meeting
- Close This Meeting
- Cancel

### C. Local draft exists but another cloud meeting is open

Show:

```text
This phone has a draft meeting, but another meeting is already open online.
```

Actions:

- Use Open Meeting
- Close Open Meeting
- Delete Local Draft
- Cancel

### D. Closed latest meeting exists

Show:

```text
Last meeting is closed. Results are final.
```

Actions:

- View Results
- Start New Meeting

## 13. Use Existing Open Meeting Flow

If an open meeting exists in the cloud, the app should allow:

```text
Use This Meeting
```

Behavior:

- store that session ID locally
- load meeting title/date
- load award statuses
- load candidates/results
- continue from Meeting Mode

This solves the current problem where backend says:

```text
Another meeting session is already open.
```

## 14. Close Existing Meeting Flow

If an old open meeting exists, officer can tap:

```text
Close This Meeting
```

Requirements:

- admin PIN required
- if an award is open, backend may auto-close the award first
- then close meeting
- results become final

Confirmation:

English:

```text
Close this online meeting? Voting will stop and results will become final.
```

Chinese:

```text
要结束这个在线会议吗？投票将停止，结果将最终确认。
```

## 15. Start New Meeting Flow

Start New Meeting should be allowed only when:

- club is connected
- cloud has no open meeting
- current meeting is none or closed

If an open meeting exists:

- do not create another confusing draft
- show existing open meeting recovery options

Flow:

```text
Start New Meeting
-> enter title/date
-> create draft meeting
-> add candidates
-> open meeting
-> open award rounds
```

## 16. UI Direction

Future UI should replace many free buttons with guided next actions.

Example:

No current meeting:

- Start New Meeting

Draft meeting:

- Add Candidates
- Open Meeting
- Cancel Draft, optional

Open meeting:

- Current open award status
- Open/Close award buttons
- Close Meeting

Closed meeting:

- View Results
- Send Results to President
- Start New Meeting

Club setup should appear as a read-only summary once connected.

## 17. Backend API Gaps

Needed Cloudflare API improvements for later phases:

```text
GET /api/admin/club/{clubSlug}/status
```

Returns:

- club
- open session if any
- latest session if any
- active award if any
- summary statuses

```text
GET /api/admin/club/{clubSlug}/sessions?status=open
```

Find open meetings.

```text
GET /api/admin/session/{sessionId}
```

Read one session with awards/candidates/status.

```text
POST /api/admin/session/{sessionId}/use
```

Maybe not needed; Flutter can simply store the returned session.

```text
POST /api/admin/session/{sessionId}/close
```

Already exists, but ensure it can close open awards safely.

Optional later:

```text
POST /api/admin/session/{sessionId}/cancel-draft
DELETE /api/admin/session/{sessionId} for test data only
DELETE /api/admin/club/{clubSlug}/test-data for prototype cleanup only
```

No hard delete for real production MVP unless strongly confirmed.

## 18. Old Wrong Clubs and Meetings

Official handling:

- Wrong on iPhone: use Reset Online Count on This Device.
- Wrong open meeting in Cloudflare: use Check Online Status -> Close This Meeting.
- Wrong test club in Cloudflare: developer may clean with D1 manually during prototype phase.
- Wrong real club in production: do not delete by default; close/archive instead.

## 19. Recommended Future Phases

Phase 5F:

- Flow hardening design document. No code.

Phase 5G:

- Cloudflare current club/status APIs.
- Add endpoints to find existing open/current meetings and return cloud status.

Phase 5H:

- Flutter guided Online Count flow.
- Lock club setup, add Check Online Status, Use Existing Meeting, Close Existing Meeting, Reset This Device.

Phase 5I:

- Online Count cleanup tools for test data, optional and hidden.
- Only for prototype/admin use.

Phase 5J:

- Final usability polish after real club testing.

## 20. Acceptance Criteria

This design answers:

- What happens if user edits club setup after creation?
- How is club setup locked?
- How does user switch club safely?
- What is reset locally vs cloud?
- How many meetings can a club have?
- How many open meetings are allowed?
- What happens if an old open meeting blocks a new meeting?
- How does the app recover an existing open meeting?
- How should wrong test data be cleaned?
- Why cloud is source of truth?

Answers:

- After creation or connection, club setup is shown as read-only status in Meeting Mode.
- Club setup is locked by removing normal editable Club Code, Backend URL, and Admin PIN fields from the main workflow.
- Switching club happens through Manage Club Setup -> Switch to Another Club, warning text, and `SWITCH` confirmation.
- Reset This Device Setup clears only local Online Count setup and cached session state; it does not clear Manual Count data, president contact, or cloud records.
- One club may have many meetings over time.
- Only one meeting can be open per club at the same time.
- If an old open meeting blocks a new meeting, the app should show recovery options instead of creating another draft.
- The app recovers an existing open meeting through Check Online Status -> Use This Meeting.
- Wrong test data may be closed, archived, deleted manually from D1 if safe, or wiped if the whole database is test-only.
- Cloudflare is the source of truth because local iPhone storage can become stale, incomplete, or inconsistent with real online voting state.

## 21. Validation

Docs-only phase.

Run:

```text
dart format .
flutter analyze
flutter test
```

Do not run iOS build unless code files were unexpectedly changed.

## 22. Git Discipline

Before commit:

```text
git status
git diff --stat
git diff -- docs/phase_5f_online_count_flow_hardening_design.md
git diff -- pubspec.yaml
git diff -- ios/Runner.xcodeproj/project.pbxproj
```

Expected:

Only `docs/phase_5f_online_count_flow_hardening_design.md` should be staged.

Do not commit:

- `pubspec.yaml` version bump
- `ios/Runner.xcodeproj/project.pbxproj` version bump
- Flutter code
- Cloudflare code
