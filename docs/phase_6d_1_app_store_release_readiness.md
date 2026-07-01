# Phase 6D-1 — App Store Release Readiness Checklist

## Purpose

Prepare the app, subscription, privacy policy, App Review notes, and release steps before submitting Speech Club 1.0.3 with Speech Club Pro.

## Current Release Candidate

- Version: 1.0.3
- Build: 6
- Commit/tag base: `phase-6c-8-testflight-subscription-report`
- TestFlight status: passed internal and external testing
- Subscription status: Ready to Submit

## Features in This Release

- Free app download
- Manual Count remains free
- Offline tools remain free
- Online Count is Speech Club Pro
- Speech Club Pro supports product loading, purchase, restore, active state, and soft gate
- 3-month free trial then yearly subscription

## App Store Connect Tasks Before Submission

- Select build 1.0.3 (6) for app version 1.0.3.
- Add Speech Club Pro Annual to the app version's In-App Purchases and Subscriptions section.
- Confirm subscription status is Ready to Submit.
- Confirm subscription review screenshot is uploaded.
- Confirm App Review notes mention Online Count and Manual Count fallback.
- Confirm export compliance is complete.
- Confirm age rating still appropriate.
- Confirm screenshots are updated or acceptable.
- Confirm support URL and privacy policy URL are valid.
- Confirm privacy answers reflect Online Count cloud data.

## Privacy Policy Update Required

Most tools are local/offline:

- Timer
- Flashcards
- Topic Selection
- Table Topics
- Role Assistants
- Committees
- Pathways
- Manual Count

Online Count uses cloud voting data:

- Club name
- Club code
- Meeting title
- Meeting date
- Candidate names
- Vote records
- Voter token/hash
- Meeting or award state

### Draft English Privacy Wording

Speech Club can be used offline for most tools, including Timer, Flashcards, Topic Selection, Table Topics, Role Assistants, Committees, Pathways, and Manual Count. These features do not require cloud storage.

If you use Online Count, voting-related data may be sent to and stored by our cloud voting service. This may include club name, club code, meeting title, meeting date, candidate names, vote records, voter token/hash, and meeting or award state.

Online Count is used only to support live club voting and result sharing. We do not sell voting data.

### Draft Chinese Privacy Wording

Speech Club 的大多数工具可以离线使用，包括计时器、演讲卡片、题目抽选、即兴演讲、角色助手、委员会、Pathways 和手动计票。这些功能不需要云端存储。

如果您使用在线计票，投票相关数据可能会发送并存储在我们的云端投票服务中。这些数据可能包括俱乐部名称、俱乐部代码、会议标题、会议日期、候选人姓名、投票记录、投票者令牌/哈希值，以及会议或奖项状态。

在线计票仅用于支持俱乐部现场投票和结果分享。我们不会出售投票数据。

## App Store App Privacy Impact

- Review App Store Connect App Privacy answers before submission.
- Online Count may collect user-provided content or identifiers depending on Apple's category interpretation.
- Do not guess final App Privacy answers in code.
- Final answers should be reviewed manually in App Store Connect.

## Backend Decision

Current backend:

`https://speech-club-vote-prototype.duduqihong.workers.dev`

Risk:

A paid Pro feature should ideally not use a backend URL containing "prototype".

Options:

- Option A: Keep current backend for 1.0.3 release because it is already tested.
- Option B: Create production backend URL before release, for example: `https://speech-club-vote.duduqihong.workers.dev`

Recommendation:

Use a separate Phase 6D-2 decision before changing backend. Do not change backend in Phase 6D-1.

## App Review Notes Draft

Speech Club is a meeting toolkit for speech clubs. Most tools are free and offline, including Timer, Flashcards, Topic Selection, Table Topics, Role Assistants, Committees, Pathways, and Manual Count.

Speech Club Pro unlocks Online Count, which allows clubs to create online voting rounds, share a permanent QR code, collect live votes, and send results. Manual Count remains free as a fallback.

The subscription product is Speech Club Pro Annual, product ID `speech_club_pro_annual`. It offers a 3-month free trial followed by yearly subscription billing.

No login is required. To test the Pro flow, open Settings > Speech Club Pro, or open Vote Bests > Online Count.

## Release Risk Checklist

- Manual Count must remain free.
- Online Count must be blocked for non-Pro users.
- Pro users must reach Online Count.
- Restore Purchases must work.
- TestFlight subscription behavior passed.
- App Store Connect subscription must be selected with the app version.
- Privacy policy must be updated before submission.
- Backend URL decision must be made before public release.

## Recommended Next Phases

- Phase 6D-2: Backend production URL decision
- Phase 6D-3: Privacy policy and support page update
- Phase 6D-4: App Store metadata and screenshot refresh
- Phase 6D-5: Final submission package
