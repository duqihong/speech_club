# Phase 5A Online Count Design

This document defines the official Phase 5 direction for Speech Club / 演讲俱乐部 online voting for Vote Bests.

## 1. Product Decision

Speech Club Online Count uses:

- one permanent QR code per club
- one temporary voting session per meeting
- a simple web voting page for voters
- the Speech Club app as the officer/admin tool
- Cloudflare Workers + D1 as the recommended backend
- Manual Count as the offline fallback

This phase is design-only. It does not implement Cloudflare Workers, D1 schema files, Flutter integration, or any changes to Manual Count behavior.

## 2. Why Permanent Club QR

A club should have one permanent QR code that can be printed, reused, and explained once.

Reasons:

- QR codes may be printed on meeting schedules in advance.
- Senior users should not need a new QR every meeting.
- A permanent club QR reduces operational burden for officers.
- The QR opens the club voting page.
- The club voting page routes voters to the current active meeting session.

Example flow:

```text
Permanent Club QR
-> Club Voting Page
-> Current Open Meeting Session
-> Vote for award categories
```

## 3. Why Temporary Meeting Session

Each meeting needs a temporary session because votes must belong to one meeting only.

Reasons:

- Votes must belong to one meeting only.
- Each meeting has its own candidates and result.
- Sessions can be Draft / Open / Closed.
- Closed sessions reject new votes.
- Results are only final after closing.

Session status meanings:

- Draft: officer is preparing candidates; voters cannot vote.
- Open: voters can submit votes.
- Closed: voting is finished; new votes are rejected and results can be finalized.

## 4. User Roles

### Club Officer / Admin

Uses the Speech Club app to:

- set up club
- create meeting session
- add candidates
- open voting
- close voting
- view results
- copy/send results

### Voter

Uses only a web page to:

- scan QR code
- see current meeting
- vote for awards
- submit
- see thank-you message

### Guest

Can vote the same way as a member if the club allows it. No app installation is required.

## 5. Recommended Voter Flow

1. Voter scans permanent club QR.
2. Web page opens.
3. Page detects language or offers 中文 / English.
4. Page shows current open meeting.
5. Voter chooses candidates for:
   - Best Speaker / 最佳演讲者
   - Best Table Topics Speaker / 最佳即席演讲者
   - Best Evaluator / 最佳点评者
6. Voter taps Submit.
7. Page shows:
   - English: Thank you. Your vote has been recorded.
   - Chinese: 谢谢，您的投票已记录。

Edge cases:

- No active meeting:
  - English: Voting is not open now.
  - Chinese: 当前没有开放的投票。
- Voting already closed:
  - English: Voting has closed for this meeting.
  - Chinese: 本次会议投票已结束。
- Already voted:
  - English: You have already voted for this award.
  - Chinese: 您已经为这个奖项投过票。

## 6. Recommended Admin Flow in App

```text
Online Count / 在线计票
-> Club Setup / 俱乐部设置
-> Current Meeting / 当前会议
-> Add Candidates / 添加候选人
-> Open Voting / 开放投票
-> Close Voting / 结束投票
-> View Results / 查看结果
-> Copy Results / 复制结果
-> Send Results to President / 发送结果给会长
```

The existing Manual Count result sharing behavior should be reused later where possible, especially localized result summary generation, Copy Results, and Send Results to President.

## 7. Data Model Draft

### clubs

- club_id
- club_name
- club_slug
- admin_pin_hash
- created_at
- updated_at

### sessions

- session_id
- club_id
- meeting_title
- meeting_date
- status: draft / open / closed
- opened_at
- closed_at
- created_at
- updated_at

### awards

- award_id
- session_id
- award_type
- display_order

award_type values:

- best_speaker
- best_table_topics
- best_evaluator

### candidates

- candidate_id
- award_id
- candidate_name
- display_order
- created_at

### votes

- vote_id
- session_id
- award_id
- candidate_id
- voter_token_hash
- created_at

Important unique rule:

One voter_token_hash can vote only once per award per session.

## 8. Privacy Model

Do not collect:

- voter name
- phone number
- email
- Toastmasters membership number
- personal identity

Store only:

- anonymous voter token hash
- session id
- award id
- candidate id
- created_at

Admin contact and president contact should remain local in the app unless a future design explicitly requires cloud sync.

## 9. Duplicate Vote Control

Recommended simple model:

- Browser creates an anonymous voter token.
- Server stores only the hashed token.
- One token can vote once per award per session.
- A voter can vote for multiple award categories, but only once per category.
- Clearing browser data may allow another vote; this is acceptable for a lightweight club tool.

Optional stronger control:

Meeting PIN:

- officer announces a 4-digit or 6-digit voting PIN during the meeting
- voter must enter the PIN before voting
- useful if the QR link is public or printed widely

Recommendation:

Do not require Meeting PIN in MVP. Design the schema and API so it can be added later.

## 10. Abuse Controls

Minimum controls:

- Only open sessions accept votes.
- Closed sessions reject votes.
- Draft sessions reject votes.
- Admin PIN required for admin actions.
- Basic rate limiting should be added at Worker level.
- Results should not be public while voting is open.
- Results should be visible to admin after closing.
- Public thank-you page should not show vote totals.

## 11. Cloud Architecture

Recommended architecture:

```text
Flutter Speech Club App
-> HTTPS API
-> Cloudflare Worker
-> Cloudflare D1

Voter Browser
-> Permanent Club QR URL
-> Cloudflare Worker web page
-> Cloudflare D1
```

Recommended URL examples:

Public voting page:

```text
https://speechclub-vote.example.workers.dev/c/{clubSlug}
```

Admin API:

```text
POST /api/admin/club
POST /api/admin/session
POST /api/admin/session/{sessionId}/open
POST /api/admin/session/{sessionId}/close
POST /api/admin/candidates
GET /api/admin/session/{sessionId}/results
```

Public voter API:

```text
GET /api/public/club/{clubSlug}/active-session
POST /api/public/session/{sessionId}/vote
```

## 12. MVP Scope

Phase 5B should build only a small Cloudflare prototype, not full Flutter integration.

Phase 5B MVP should include:

- one Worker
- one D1 database
- SQL schema
- simple public voting page
- simple admin endpoints
- ability to create one club
- ability to create/open/close one session
- ability to add candidates
- ability to vote
- ability to view results

Not included in Phase 5B:

- Flutter integration
- user accounts
- email login
- payment
- multi-club dashboard
- advanced security
- push notifications
- QR image generation inside Flutter

## 13. Future Phase Plan

- Phase 5A: Online Count product design document.
- Phase 5B: Cloudflare Workers + D1 prototype outside Flutter.
- Phase 5C: Flutter Online Count admin screens connect to Cloudflare backend.
- Phase 5D: QR code display, copy voting link, print-friendly voting instructions.
- Phase 5E: Testing with a real club meeting.

## 14. Senior-Friendly Design Principles

- Voters should not install the app.
- Voters should not create accounts.
- Officers should see large buttons and simple status labels.
- Use Draft / Open / Closed, not technical terms.
- Use bilingual English/Chinese text.
- Keep Manual Count visible as offline backup.
- Avoid forcing QR regeneration every meeting.

## 15. Risks and Open Questions

Open questions and recommended default answers:

| Question | Recommended default |
| --- | --- |
| Should clubs use a shared Speech Club backend or each officer create their own Cloudflare deployment? | Shared backend later, single test deployment first. |
| How should admin PIN reset work? | No PIN reset in prototype. |
| Should guests be allowed to vote? | Guests allowed. |
| Should voters vote for all awards on one page or one award at a time? | All awards on one page. |
| Should results be hidden until the meeting is closed? | Hide results until closed. |
| Should candidate names be typed manually or imported from meeting roles later? | Manually typed candidate names. |
| Should the app support multiple clubs on one device? | One club per device for MVP. |

## 16. Validation

Because Phase 5A is docs-only, validation is:

```text
dart format .
flutter analyze
flutter test
```

Do not run an iOS build unless code files were unexpectedly changed.

## 17. Git Discipline

Only this file should be staged for Phase 5A:

```text
docs/phase_5a_online_count_design.md
```

Do not commit the existing unrelated version bump in:

- pubspec.yaml
- ios/Runner.xcodeproj/project.pbxproj
