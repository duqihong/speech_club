# Phase 6D-6a — Privacy Policy Update Plan

## Purpose

Prepare privacy wording and App Store privacy review notes for Speech Club 1.0.3 with Speech Club Pro / Online Count.

## Privacy Model Summary

- Most Speech Club tools are local/offline.
- Manual Count is local/offline and remains free.
- Online Count uses cloud voting service through Cloudflare Worker + D1.
- Online Count is optional and only used when a club chooses Pro online voting.

## Local/Offline Features

These do not require cloud storage:

- Timer
- Flashcards
- Topic Selection
- Table Topics
- Role Assistants
- Committees
- Pathways
- Manual Count

## Online Count Cloud Data

Online Count may store:

- club name
- club code
- meeting title
- meeting date
- candidate names
- vote records
- voter token/hash
- meeting or award state

## Data Use

- Used only to operate Online Count.
- Used for live voting, vote counting, QR sharing, and result display/sharing.
- Not sold.
- Not used for advertising.
- Not used for third-party tracking.
- Not used for analytics profiling.

## Draft English Privacy Policy Section

Speech Club can be used offline for most tools, including Timer, Flashcards, Topic Selection, Table Topics, Role Assistants, Committees, Pathways, and Manual Count. These features do not require cloud storage.

If you use Online Count, voting-related data may be sent to and stored by our cloud voting service. This may include club name, club code, meeting title, meeting date, candidate names, vote records, voter token/hash, and meeting or award state.

Online Count is used only to support live club voting, vote counting, QR sharing, result display, and result sharing. We do not sell voting data. We do not use voting data for advertising, third-party tracking, or analytics profiling.

Manual Count remains available as a local/offline alternative.

## Draft Chinese Privacy Policy Section

Speech Club 的大多数工具可以离线使用，包括计时器、演讲卡片、题目抽选、即兴演讲、角色助手、委员会、Pathways 和手动计票。这些功能不需要云端存储。

如果您使用在线计票，投票相关数据可能会发送并存储在我们的云端投票服务中。这些数据可能包括俱乐部名称、俱乐部代码、会议标题、会议日期、候选人姓名、投票记录、投票者令牌/哈希值，以及会议或奖项状态。

在线计票仅用于支持俱乐部现场投票、计票、二维码分享、结果显示和结果分享。我们不会出售投票数据。我们不会将投票数据用于广告、第三方跟踪或分析画像。

手动计票仍然作为本地/离线替代方式提供。

## App Store Connect App Privacy Review Checklist

This is a manual checklist, not final legal answers:

- Review Data Collection section.
- Review whether candidate names / club names / meeting names should be treated as User Content or Other Data.
- Review whether voter token/hash should be treated as Identifier or Other Data.
- Confirm data is not used for tracking.
- Confirm data is not linked to advertising.
- Confirm no third-party analytics or ads are used.
- Confirm purchases/subscriptions are handled by Apple StoreKit.
- Confirm Privacy Policy URL points to the updated public policy.

## Public Page Update Plan

- Identify existing Speech Club support/privacy page URL if already available.
- If no public page exists, create or update a GitHub Pages support/privacy page in a later phase.
- Include both English and Chinese privacy wording.
- Update App Store Connect Privacy Policy URL after the page is live.

## Remaining Release Dependency

The app should not be submitted until:

- Public privacy policy is updated.
- App Store Connect App Privacy answers are reviewed.
- Privacy Policy URL is confirmed working.

## Next Recommended Phase

Phase 6D-6b — Update public privacy/support page
