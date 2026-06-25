# Phase 5A Online Count Design

This document defines the official Phase 5 direction for Speech Club / 演讲俱乐部 online voting for Vote Bests.

## Phase 5A-2 Refinement Decisions

Phase 5A-2 makes two official refinements to the Online Count design:

1. The public voting page should show one language at a time.
2. Voting should be conducted one award round at a time.

### Public Voting Page Language

The current prototype shows English and Chinese together, for example:

```text
Speech Club Voting / 演讲俱乐部投票
```

The future public voting page should show only one language at a time.

Recommended language priority:

1. URL query parameter: `?lang=zh` or `?lang=en`
2. Browser-saved language choice: `localStorage speechClubVoteLang`
3. Browser/device language: `navigator.language` or `navigator.languages`
4. Default: English

Chinese detection:

Any browser language starting with `zh` should use Chinese.

Examples:

- `zh`
- `zh-CN`
- `zh-SG`
- `zh-Hans`
- `zh-Hant`
- `zh-TW`
- `zh-HK`

The page should still show a small language switch:

```text
English | 中文
```

When the user taps the switch:

- update `localStorage`
- reload or re-render the page in the selected language
- optionally update the URL query parameter

QR code options:

- Default permanent club QR: `https://worker-url/c/{clubSlug}`
- Chinese-specific QR: `https://worker-url/c/{clubSlug}?lang=zh`
- English-specific QR: `https://worker-url/c/{clubSlug}?lang=en`

Recommendation for Chinese-speaking clubs:

Use `?lang=zh` in the printed QR code.

### One Award Round At A Time

The current prototype shows all three awards together:

- Best Speaker
- Best Table Topics Speaker
- Best Evaluator

Toastmasters award voting is normally conducted independently. Therefore, the future public page should show only the currently open award round.

The same permanent club QR remains unchanged.

Example meeting flow:

1. Officer opens Best Speaker voting.
2. Voters scan the permanent QR and vote only for Best Speaker.
3. Officer closes Best Speaker voting.
4. Officer opens Best Table Topics Speaker voting.
5. Voters scan the same QR and vote only for Best Table Topics Speaker.
6. Officer closes Best Table Topics Speaker voting.
7. Officer opens Best Evaluator voting.
8. Voters scan the same QR and vote only for Best Evaluator.
9. Officer closes Best Evaluator voting.
10. Officer closes the meeting session and views final results.

Chinese page example:

```text
演讲俱乐部投票

当前投票：
最佳演讲者

请选择一位候选人：

○ Alice
○ Bob
○ Charlie

提交投票
```

After submission:

```text
谢谢，您的投票已记录。
```

English page example:

```text
Speech Club Voting

Current Vote:
Best Speaker

Please choose one candidate:

○ Alice
○ Bob
○ Charlie

Submit Vote
```

After submission:

```text
Thank you. Your vote has been recorded.
```

No open award round:

- English: Voting is not open now.
- Chinese: 当前没有开放的投票。

Already voted for this award:

- English: You have already voted for this award.
- Chinese: 您已经为这个奖项投过票。

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
- The club voting page routes voters to the current active award round in the current meeting session.

Example flow:

```text
Permanent Club QR
-> Club Voting Page
-> Current Open Award Round
-> Vote for one award
```

## 3. Why Temporary Meeting Session

Each meeting needs a temporary session because votes must belong to one meeting only.

Reasons:

- Votes must belong to one meeting only.
- Each meeting has its own candidates and result.
- Sessions can be Draft / Open / Closed.
- Award rounds inside a session can also be Draft / Open / Closed.
- Closed sessions reject new votes and prevent new award rounds from opening.
- Results are only final after closing.

Session status meanings:

- Draft: officer is preparing candidates; voters cannot vote.
- Open: the meeting voting system is active, but there may or may not be one open award round.
- Closed: voting is finished; new votes are rejected and results can be finalized.

Award status meanings:

- Draft: candidates can still be edited.
- Open: the public voting page shows this award and voters can submit one vote.
- Closed: votes are locked for this award.

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
- vote for the currently open award
- submit
- see thank-you message

### Guest

Can vote the same way as a member if the club allows it. No app installation is required.

## 5. Recommended Voter Flow

1. Voter scans permanent club QR.
2. Web page opens.
3. Page chooses one display language from URL, saved choice, browser language, or English default.
4. Page shows the current open award round.
5. Voter chooses one candidate for that award.
6. Voter taps Submit.
7. Page shows:
   - English: Thank you. Your vote has been recorded.
   - Chinese: 谢谢，您的投票已记录。

Edge cases:

- No active meeting or no open award round:
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
-> Open Best Speaker Voting / 开放最佳演讲者投票
-> Close Best Speaker Voting / 结束最佳演讲者投票
-> Open Table Topics Voting / 开放最佳即席演讲者投票
-> Close Table Topics Voting / 结束最佳即席演讲者投票
-> Open Evaluator Voting / 开放最佳点评者投票
-> Close Evaluator Voting / 结束最佳点评者投票
-> Close Meeting / 结束会议
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
- status: draft / open / closed
- opened_at
- closed_at

award_type values:

- best_speaker
- best_table_topics
- best_evaluator

Award status meanings:

- draft: award round is prepared but not yet open.
- open: voters can vote for this award round.
- closed: voting for this award round is finished.

Important rule:

Only one award can be open within one meeting session at a time.

The meeting session still has its own status:

- session status: draft / open / closed

The award round also has its own status:

- award status: draft / open / closed

Recommended combined meaning:

- Session draft: meeting is being prepared.
- Session open: meeting voting system is active, but there may or may not be one open award round.
- Session closed: meeting voting is finished. No award can be opened or voted on.
- Award draft: candidates can still be edited.
- Award open: public voting page shows this award.
- Award closed: votes are locked for this award.

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

Under the award-round model, a voter may vote once for Best Speaker, once for Best Table Topics Speaker, and once for Best Evaluator. Each award round is independent. Duplicate detection applies to the currently open award only.

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
- A voter can vote once for Best Speaker, once for Best Table Topics Speaker, and once for Best Evaluator.
- Each award round is independent.
- Duplicate detection applies to the currently open award only.
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
GET /api/public/club/{clubSlug}/active-vote
POST /api/public/session/{sessionId}/award/{awardId}/vote
```

`GET /api/public/club/{clubSlug}/active-vote` returns:

- club
- session
- active award
- candidates for active award only
- localized labels or `award_type` for frontend localization

If no session or no award round is open:

```json
{
  "ok": false,
  "code": "NO_ACTIVE_VOTE",
  "message": "Voting is not open now."
}
```

Voting endpoint:

```text
POST /api/public/session/{sessionId}/award/{awardId}/vote
```

Body:

```json
{
  "voterToken": "browser-generated-token",
  "candidateId": "..."
}
```

Behavior:

- session must be open
- award must be open
- candidate must belong to award
- voter token hash can vote only once for this award
- return recorded or duplicate result

Planned admin API changes:

```text
POST /api/admin/session/{sessionId}/award/{awardId}/open
POST /api/admin/session/{sessionId}/award/{awardId}/close
GET /api/admin/session/{sessionId}/results
```

`POST /api/admin/session/{sessionId}/award/{awardId}/open` behavior:

- verify admin PIN
- session must be open
- award must have candidates
- no other award in the same session may remain open
- either close other open award automatically or reject with error
- recommended MVP behavior: reject if another award is already open

`POST /api/admin/session/{sessionId}/award/{awardId}/close` behavior:

- verify admin PIN
- award must be open
- set award status to closed
- set `closed_at`

`GET /api/admin/session/{sessionId}/results` behavior:

- return results for all awards
- each award has its own status
- meeting result is final only when session is closed

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

- Phase 5A: Initial Online Count product design.
- Phase 5A-2: Refine design for device-language public page and one-award-at-a-time voting rounds.
- Phase 5B: Cloudflare Workers + D1 prototype outside Flutter.
- Phase 5B-2: Remote Cloudflare deployment test.
- Phase 5B-3: Update Cloudflare prototype to support:
  - one language at a time
  - device/browser language detection
  - URL `?lang=zh` / `?lang=en`
  - one active award round at a time
  - award-level draft/open/closed status
  - active-vote public page
- Phase 5C: Flutter Online Count admin screens connect to Cloudflare backend.
- Phase 5D: QR code display, copy voting link, print-friendly voting instructions.
- Phase 5E: Testing with a real club meeting.

## 14. Senior-Friendly Design Principles

- Voters should not install the app.
- Voters should not create accounts.
- Officers should see large buttons and simple status labels.
- Use Draft / Open / Closed, not technical terms.
- Show one language at a time, with a small English / 中文 switch.
- Keep Manual Count visible as offline backup.
- Avoid forcing QR regeneration every meeting.

## 15. Risks and Open Questions

Open questions and recommended default answers:

| Question | Recommended default |
| --- | --- |
| Should clubs use a shared Speech Club backend or each officer create their own Cloudflare deployment? | Shared backend later, single test deployment first. |
| How should admin PIN reset work? | No PIN reset in prototype. |
| Should guests be allowed to vote? | Guests allowed. |
| Should voters vote for all awards on one page or one award at a time? | One award at a time, because club meetings usually conduct these votes separately. |
| Should the voting page show both languages? | No. It should follow device/browser language and show one language at a time, with a manual language switch. |
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
