# Phase 6D-3 — Production Backend Setup

## Purpose

Create and deploy the production Cloudflare Worker + D1 backend for Speech Club Online Count before switching the Flutter app to the production URL.

## Production Backend

- Production Worker name: `speech-club-vote`
- Production URL: `https://speech-club-vote.duduqihong.workers.dev`
- Production D1 database name: `speech-club-vote-production`
- Production D1 database ID: `e6d9db95-7f01-4d3f-bc75-55bf63d17f4f`
- D1 binding name: `DB`
- Wrangler config: `cloudflare/vote_count_prototype/wrangler.production.toml`

## Prototype Backend

- Prototype Worker name: `speech-club-vote-prototype`
- Prototype URL: `https://speech-club-vote-prototype.duduqihong.workers.dev`
- Prototype D1 database name: `speech_club_votes`
- Prototype D1 database ID: `d98a29cc-2288-41cf-93d6-b5121aa932df`
- Prototype config remains unchanged in `cloudflare/vote_count_prototype/wrangler.toml`.
- Prototype test data was not copied into production.

## Worker Code

Production uses the same stable Worker source as the tested prototype:

- `cloudflare/vote_count_prototype/src/index.ts`

The Worker source was not changed in this phase.

Note: because the Worker source was kept unchanged, the `/health` response still
reports the inherited service label `speech-club-vote-prototype`. The deployed
Worker name and URL are production-specific.

## Migration Command

```sh
cd cloudflare/vote_count_prototype
npx wrangler d1 migrations apply speech-club-vote-production --remote --config wrangler.production.toml
```

## Deployment Command

```sh
cd cloudflare/vote_count_prototype
npx wrangler deploy --config wrangler.production.toml
```

## Smoke Test Result

Production smoke testing used disposable test data only.

- Health endpoint passed.
- Disposable production test club was created.
- Disposable current meeting was created.
- Candidate setup passed.
- Meeting open passed.
- Award open passed.
- Public active vote endpoint passed.
- Disposable vote submission passed.
- Results endpoint passed.
- Disposable production test club was deleted after the smoke test.
- Production D1 table counts were confirmed as zero for `clubs`, `sessions`, `awards`, `candidates`, and `votes` after cleanup.

Smoke test slug:

```text
phase-6d-3-smoke-mr1uwyh3
```

## Known Next Step

Update the Flutter app backend URL from the prototype Worker to the production Worker in a later phase, then run full Online Count TestFlight validation before App Store submission.
