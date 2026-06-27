# Phase 6A — Monetization Design and Pro Plan

## Scope

Phase 6A is documentation only. It does not change app behavior, UI, StoreKit configuration, backend code, Cloudflare Worker code, or D1 migrations.

Current stable baseline:

- Stable commit: `b83192e`
- Stable tag: `phase-5u-final-stabilization-v1-0-2-stable`
- App version: `1.0.2+4`
- iOS `MARKETING_VERSION`: `1.0.2`

## Business Model

- Free app download.
- Speech Club Pro as an auto-renewable yearly subscription.
- 3-month free introductory trial.
- Then yearly subscription fee.
- Recommended launch price: closest App Store Connect price point to `S$14.98/year`.

## Free Features

- Timer
- Flashcards
- Topic Selection
- Table Topics
- Role Assistants
- Committees
- Pathways
- Manual Count

Manual Count remains fully free.

## Pro Features

- Online Count
- Permanent club QR
- QR sharing
- Live vote counter
- Send online results by WhatsApp
- Future online meeting history
- Future officer guide / meeting records

## Product Naming

- Subscription group name: `Speech Club Pro`
- Subscription display name: `Speech Club Pro Annual`
- Product ID: `speech_club_pro_annual`

## Paywall Decision

Use a soft paywall.

Free users may view the Online Count explanation and Pro screen. Free users may not create an online club, share a permanent QR, start online voting, or use the live vote counter.

Manual Count remains fully free.

## English Pro Screen Draft

Title:

> Speech Club Pro

Subtitle:

> Run live online voting with one permanent club QR.

Body:

> Speech Club Pro helps your club collect votes from members' phones, show a live vote count, and send final results to the meeting officer.

Included:

- Online Count
- Permanent club QR
- QR sharing
- Live vote counter
- Send results by WhatsApp
- Future online meeting tools

Price line:

> First 3 months free. Then S$14.98 per year. Cancel anytime.

Primary button:

> Start 3-Month Free Trial

Secondary button:

> Use Manual Count for Free

Small note:

> Manual Count and all offline tools remain free.

## Chinese Pro Screen Draft

Title:

> Speech Club Pro

Subtitle:

> 使用一个永久俱乐部二维码，进行现场在线投票。

Body:

> Speech Club Pro 可帮助俱乐部通过会员手机收集投票，显示实时票数，并将最终结果发送给会议负责人。

Included:

- 在线计票
- 永久俱乐部二维码
- 二维码分享
- 实时票数显示
- 通过 WhatsApp 发送结果
- 未来的在线会议工具

Price line:

> 前 3 个月免费。之后每年 S$14.98。可随时取消。

Primary button:

> 开始 3 个月免费试用

Secondary button:

> 免费使用手动计票

Small note:

> 手动计票和所有离线工具永久免费。

## Privacy Policy Impact

Local and offline features do not require cloud storage. These include Timer, Flashcards, Topic Selection, Table Topics, Role Assistants, Committees, Pathways, and Manual Count.

Online Count may store data needed to run online voting:

- club name
- club code
- meeting title
- meeting date
- candidate names
- vote records
- voter token/hash
- meeting or award state

Draft English privacy wording:

> Speech Club's offline tools can be used without cloud storage. If you use Online Count, the app may store information needed to run an online voting session, including your club name, club code, meeting title, meeting date, candidate names, vote records, voter token or hash, and meeting or award state. This information is used to support online voting, live vote counting, QR sharing, and result sharing.

Draft Chinese privacy wording:

> Speech Club 的离线工具无需云端存储即可使用。如果你使用在线计票，应用可能会存储运行在线投票所需的信息，包括俱乐部名称、俱乐部代码、会议标题、会议日期、候选人姓名、投票记录、投票者 token 或哈希值，以及会议或奖项状态。这些信息用于支持在线投票、实时计票、二维码分享和结果分享。

## Backend Note

Current backend:

> https://speech-club-vote-prototype.duduqihong.workers.dev

Recommendation:

Create a production backend before paid public release, for example:

> https://speech-club-vote.duduqihong.workers.dev

Do not change backend configuration in Phase 6A.

## App Store / Policy Notes

- Use Apple In-App Purchase / StoreKit for Pro unlock.
- Do not use external payment links inside the app to unlock Pro.
- Clearly show trial duration and yearly price.
- Avoid branding the app as an official Toastmasters product.

## Later Phase Sequence

- Phase 6B: StoreKit / In-App Purchase technical plan
- Phase 6C: Add Pro screen and soft paywall
- Phase 6D: TestFlight subscription testing
- Phase 6E: App Store release preparation
- Phase 6F: Real club pilot fixes
