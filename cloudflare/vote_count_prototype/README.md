# Speech Club Vote Count Prototype

Cloudflare Workers + D1 prototype for Speech Club Online Count / 在线计票.

## What This Prototype Is

This is a small backend and web prototype for Vote Bests online counting. It provides:

- one Cloudflare Worker
- one D1 database binding
- a public voting page that shows one language at a time
- URL language override with `?lang=zh` and `?lang=en`
- browser/device language detection
- one active award voting round at a time
- basic admin endpoints
- anonymous voter-token duplicate control
- result aggregation for club officers

## What This Prototype Is Not

- Not Flutter integration yet
- Not production deployment yet
- Not a user account system
- Not a payment system
- Not a replacement for Manual Count

## Phase 5B-3 Behavior

The public page now shows only one language at a time. Language priority is:

1. URL query parameter: `?lang=zh` or `?lang=en`
2. saved browser choice: `localStorage speechClubVoteLang`
3. browser/device language
4. English default

Voting now works one award round at a time. The officer opens the meeting session first, then opens one award round such as Best Speaker. Voters using the permanent club URL see only the currently open award round. After that award is closed, the page shows no active vote until the officer opens the next award.

Public page examples:

```text
https://speech-club-vote-prototype.duduqihong.workers.dev/c/demo-round-club?lang=zh
https://speech-club-vote-prototype.duduqihong.workers.dev/c/demo-round-club?lang=en
```

## Local Setup

```sh
cd cloudflare/vote_count_prototype
npm install
npx wrangler d1 migrations apply speech_club_votes --local
npm run dev
```

The `database_id` in `wrangler.toml` points to the current remote prototype D1 database. For a new deployment, run `wrangler d1 create` and replace `database_id` with the value returned by Cloudflare.

## Local Test Flow With curl

Run the Worker locally first:

```sh
npm run dev
```

Use another terminal for the curl commands. Use a new club slug such as `demo-round-club-local` if local D1 already contains older test data.

### 1. Health Check

```sh
curl http://localhost:8787/health
```

### 2. Create Club

```sh
curl -X POST http://localhost:8787/api/admin/club \
  -H "Content-Type: application/json" \
  -d '{
    "clubName": "Demo Round Club",
    "clubSlug": "demo-round-club-local",
    "adminPin": "123456"
  }'
```

### 3. Create Meeting Session

```sh
curl -X POST http://localhost:8787/api/admin/club/demo-round-club-local/session \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "meetingTitle": "Regular Meeting",
    "meetingDate": "2026-06-25"
  }'
```

Save the returned `session_id` and award IDs for later commands.

### 4. Add Candidates For All Three Awards

Best Speaker:

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/candidates \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "awardType": "best_speaker",
    "candidates": ["Alice", "Bob", "Charlie"]
  }'
```

Best Table Topics:

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/candidates \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "awardType": "best_table_topics",
    "candidates": ["David", "Eva", "Frank"]
  }'
```

Best Evaluator:

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/candidates \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "awardType": "best_evaluator",
    "candidates": ["Grace", "Helen", "Ivan"]
  }'
```

### 5. Open Meeting Session

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/open \
  -H "X-Admin-Pin: 123456"
```

### 6. Fetch Results To Find Award IDs

```sh
curl http://localhost:8787/api/admin/session/SESSION_ID/results \
  -H "X-Admin-Pin: 123456"
```

### 7. Open Best Speaker Award Round

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/award/BEST_SPEAKER_AWARD_ID/open \
  -H "X-Admin-Pin: 123456"
```

### 8. Fetch Active Vote

```sh
curl http://localhost:8787/api/public/club/demo-round-club-local/active-vote
```

Only the open award and its candidates should be returned.

### 9. Submit Vote For Best Speaker

```sh
curl -X POST http://localhost:8787/api/public/session/SESSION_ID/award/BEST_SPEAKER_AWARD_ID/vote \
  -H "Content-Type: application/json" \
  -d '{
    "voterToken": "local-voter-1",
    "candidateId": "CANDIDATE_ID"
  }'
```

Running the same command again should return:

```json
{
  "ok": true,
  "recorded": false,
  "duplicate": true,
  "code": "ALREADY_VOTED"
}
```

### 10. Close Best Speaker Award Round

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/award/BEST_SPEAKER_AWARD_ID/close \
  -H "X-Admin-Pin: 123456"
```

After closing this award, active-vote should return `NO_ACTIVE_VOTE` until the next award round is opened.

### 11. Open Best Table Topics Award Round

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/award/BEST_TABLE_TOPICS_AWARD_ID/open \
  -H "X-Admin-Pin: 123456"
```

### 12. Fetch Active Vote

```sh
curl http://localhost:8787/api/public/club/demo-round-club-local/active-vote
```

### 13. Submit Vote For Best Table Topics

```sh
curl -X POST http://localhost:8787/api/public/session/SESSION_ID/award/BEST_TABLE_TOPICS_AWARD_ID/vote \
  -H "Content-Type: application/json" \
  -d '{
    "voterToken": "local-voter-1",
    "candidateId": "CANDIDATE_ID"
  }'
```

### 14. Close Best Table Topics Award Round

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/award/BEST_TABLE_TOPICS_AWARD_ID/close \
  -H "X-Admin-Pin: 123456"
```

### 15. Open Best Evaluator Award Round

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/award/BEST_EVALUATOR_AWARD_ID/open \
  -H "X-Admin-Pin: 123456"
```

### 16. Submit Vote For Best Evaluator

```sh
curl -X POST http://localhost:8787/api/public/session/SESSION_ID/award/BEST_EVALUATOR_AWARD_ID/vote \
  -H "Content-Type: application/json" \
  -d '{
    "voterToken": "local-voter-1",
    "candidateId": "CANDIDATE_ID"
  }'
```

### 17. Close Best Evaluator Award Round

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/award/BEST_EVALUATOR_AWARD_ID/close \
  -H "X-Admin-Pin: 123456"
```

### 18. Close Meeting Session

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/close \
  -H "X-Admin-Pin: 123456"
```

### 19. Get Final Results

```sh
curl http://localhost:8787/api/admin/session/SESSION_ID/results \
  -H "X-Admin-Pin: 123456"
```

### 20. Test Public Page

```text
http://localhost:8787/c/demo-round-club-local?lang=zh
http://localhost:8787/c/demo-round-club-local?lang=en
```

The Chinese link should show Chinese only. The English link should show English only.

## Phase 5G one-device owner APIs

Phase 5G adds backend support for the simplified one-device Online Count model:

- one app installation has one private owner token
- backend stores only `owner_token_hash`
- one owner token can have only one active online club
- one online club can have only one current meeting
- user must delete the current meeting before creating the next meeting
- user must delete the online club before creating another club
- meetings expire after 7 days
- inactive clubs expire after 3 months
- scheduled cleanup runs daily, with lazy cleanup on API activity as backup
- Manual Count remains the offline fallback in Flutter

New owner/admin APIs require both headers:

```text
X-Owner-Token: local-owner-token-5g
X-Admin-Pin: 123456
```

Public voter APIs still do not require owner token or admin PIN.

Use a fresh local owner token and club slug:

```sh
OWNER_TOKEN="local-owner-token-5g"
CLUB_SLUG="demo-owner-local-club"
ADMIN_PIN="123456"
BASE_URL="http://localhost:8787"
```

### A. Create owner club

```sh
curl -X POST "$BASE_URL/api/owner/club" \
  -H "Content-Type: application/json" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -d '{
    "clubName": "Demo Owner Local Club",
    "clubSlug": "demo-owner-local-club",
    "adminPin": "123456"
  }'
```

### B. Verify owner club

```sh
curl -X POST "$BASE_URL/api/owner/club/$CLUB_SLUG/verify" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN"
```

### C. Get owner club status

```sh
curl "$BASE_URL/api/owner/club/$CLUB_SLUG/status" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN"
```

Expected before creating a meeting:

```json
{
  "hasCurrentSession": false,
  "hasActiveAward": false,
  "canCreateMeeting": true,
  "canCreateClub": false,
  "legacyMultipleSessions": false
}
```

### D. Create current meeting

```sh
curl -X POST "$BASE_URL/api/owner/club/$CLUB_SLUG/session" \
  -H "Content-Type: application/json" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN" \
  -d '{
    "meetingTitle": "Regular Meeting",
    "meetingDate": "2026-06-26"
  }'
```

Save the returned `sessionId` and award IDs.

### E. Attempt to create second meeting and confirm CURRENT_MEETING_EXISTS

```sh
curl -X POST "$BASE_URL/api/owner/club/$CLUB_SLUG/session" \
  -H "Content-Type: application/json" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN" \
  -d '{
    "meetingTitle": "Second Meeting",
    "meetingDate": "2026-06-26"
  }'
```

Expected error code:

```text
CURRENT_MEETING_EXISTS
```

### F. Add candidates using owner token

```sh
curl -X POST "$BASE_URL/api/admin/session/SESSION_ID/candidates" \
  -H "Content-Type: application/json" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN" \
  -d '{
    "awardType": "best_speaker",
    "candidates": ["Alice", "Bob"]
  }'
```

### G. Open session using owner token

```sh
curl -X POST "$BASE_URL/api/admin/session/SESSION_ID/open" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN"
```

### H. Open award using owner token

```sh
curl -X POST "$BASE_URL/api/admin/session/SESSION_ID/award/BEST_SPEAKER_AWARD_ID/open" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN"
```

### I. Public vote

Fetch the active vote:

```sh
curl "$BASE_URL/api/public/club/$CLUB_SLUG/active-vote"
```

Submit a vote:

```sh
curl -X POST "$BASE_URL/api/public/session/SESSION_ID/award/BEST_SPEAKER_AWARD_ID/vote" \
  -H "Content-Type: application/json" \
  -d '{
    "voterToken": "local-voter-5g-1",
    "candidateId": "CANDIDATE_ID"
  }'
```

### J. Delete current meeting

```sh
curl -X DELETE "$BASE_URL/api/owner/session/SESSION_ID" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN"
```

### K. Confirm new meeting can be created

```sh
curl -X POST "$BASE_URL/api/owner/club/$CLUB_SLUG/session" \
  -H "Content-Type: application/json" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN" \
  -d '{
    "meetingTitle": "Next Meeting",
    "meetingDate": "2026-06-27"
  }'
```

### L. Delete online club

```sh
curl -X DELETE "$BASE_URL/api/owner/club/$CLUB_SLUG" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -H "X-Admin-Pin: $ADMIN_PIN"
```

### M. Confirm owner can create another club

```sh
curl -X POST "$BASE_URL/api/owner/club" \
  -H "Content-Type: application/json" \
  -H "X-Owner-Token: $OWNER_TOKEN" \
  -d '{
    "clubName": "Demo Owner Local Club 2",
    "clubSlug": "demo-owner-local-club-2",
    "adminPin": "123456"
  }'
```

## Remote Deployment Test

Current test Worker URL:

```text
https://speech-club-vote-prototype.duduqihong.workers.dev
```

This URL is for prototype testing only. Do not use real club data yet.

Remote setup commands:

```sh
npx wrangler whoami
npx wrangler d1 migrations apply speech_club_votes --remote
npx wrangler deploy
```

Use a fresh remote test club slug such as `demo-round-club` to avoid older test data. The demo admin PIN `123456` is only for prototype testing. Do not use it for real club meetings.

## Remote Deployment Later

Do not deploy this prototype to production yet. When ready for a new remote deployment:

```sh
npx wrangler d1 create speech_club_votes
```

Replace the `database_id` in `wrangler.toml` with the real ID returned by Cloudflare.

Then run:

```sh
npx wrangler d1 migrations apply speech_club_votes --remote
npx wrangler deploy
```

## Privacy Rules

- Do not collect voter name.
- Do not collect voter phone.
- Do not collect voter email.
- Do not collect Toastmasters membership number.
- Store only hashed voter token.
- Store only admin PIN hash.
- Public voting pages do not show vote totals.
- Public active-vote API does not return results.
