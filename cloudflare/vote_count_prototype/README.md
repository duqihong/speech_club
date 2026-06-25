# Speech Club Vote Count Prototype

Cloudflare Workers + D1 prototype for Speech Club Online Count / 在线计票.

## What This Prototype Is

This is a small backend and web prototype for Vote Bests online counting. It provides:

- one Cloudflare Worker
- one D1 database binding
- a simple bilingual public voting page
- basic admin endpoints
- anonymous voter-token duplicate control
- result aggregation for club officers

## What This Prototype Is Not

- Not Flutter integration yet
- Not production deployment yet
- Not a user account system
- Not a payment system
- Not a replacement for Manual Count

## Local Setup

```sh
cd cloudflare/vote_count_prototype
npm install
npx wrangler d1 migrations apply speech_club_votes --local
npm run dev
```

The `database_id` in `wrangler.toml` is a source-control placeholder. A real remote `database_id` will be generated later by Cloudflare when running `wrangler d1 create`.

## Local Test Flow With curl

Run the Worker locally first:

```sh
npm run dev
```

Use another terminal for the curl commands.

### 1. Health Check

```sh
curl http://localhost:8787/health
```

### 2. Create Club

```sh
curl -X POST http://localhost:8787/api/admin/club \
  -H "Content-Type: application/json" \
  -d '{
    "clubName": "Demo Speech Club",
    "clubSlug": "demo-speech-club",
    "adminPin": "123456"
  }'
```

### 3. Create Meeting Session

```sh
curl -X POST http://localhost:8787/api/admin/club/demo-speech-club/session \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "meetingTitle": "Regular Meeting",
    "meetingDate": "2026-06-25"
  }'
```

Save the returned `session_id` and award IDs for later commands.

### 4. Add Best Speaker Candidates

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/candidates \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "awardType": "best_speaker",
    "candidates": ["Alice", "Bob", "Charlie"]
  }'
```

### 5. Add Best Table Topics Candidates

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/candidates \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "awardType": "best_table_topics",
    "candidates": ["David", "Eva"]
  }'
```

### 6. Add Best Evaluator Candidates

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/candidates \
  -H "Content-Type: application/json" \
  -H "X-Admin-Pin: 123456" \
  -d '{
    "awardType": "best_evaluator",
    "candidates": ["Frank", "Grace"]
  }'
```

### 7. Open Session

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/open \
  -H "X-Admin-Pin: 123456"
```

### 8. Open Browser Voting Page

```text
http://localhost:8787/c/demo-speech-club
```

You can also inspect the public active session:

```sh
curl http://localhost:8787/api/public/club/demo-speech-club/active-session
```

### 9. Close Session

```sh
curl -X POST http://localhost:8787/api/admin/session/SESSION_ID/close \
  -H "X-Admin-Pin: 123456"
```

### 10. Get Results

```sh
curl http://localhost:8787/api/admin/session/SESSION_ID/results \
  -H "X-Admin-Pin: 123456"
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
npx wrangler d1 create speech_club_votes
npx wrangler d1 migrations apply speech_club_votes --remote
npx wrangler deploy
```

After `wrangler d1 create`, replace the placeholder `database_id` in `wrangler.toml` with the real Cloudflare database ID before applying remote migrations or deploying.

The demo admin PIN `123456` is only for prototype testing. Do not use it for real club meetings.

## Remote Deployment Later

Do not deploy this prototype to production yet. When ready for a remote test deployment:

```sh
npx wrangler d1 create speech_club_votes
```

Replace the placeholder `database_id` in `wrangler.toml` with the real ID returned by Cloudflare.

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
- Public active-session API does not return results.
