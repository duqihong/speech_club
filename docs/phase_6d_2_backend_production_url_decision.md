# Phase 6D-2 — Backend Production URL Decision

## Purpose

Decide whether Speech Club Pro should continue using the prototype backend URL for public release or switch to a production backend URL before submission.

## Current Backend

`https://speech-club-vote-prototype.duduqihong.workers.dev`

## Current Backend Role

- Online Count cloud voting
- Permanent club QR
- Vote collection
- Live vote counter
- WhatsApp result sharing support
- D1 database storage

## Important Product Context

- Online Count is now a paid Pro feature.
- Manual Count remains free and offline.
- Pro subscription has passed TestFlight testing.
- Public paid users should ideally not depend on a URL named prototype.

## Option A — Keep Prototype Backend for 1.0.3

### Pros

- Already tested.
- No extra backend work.
- Lowest immediate release risk.
- No need to retest QR, live voting, and result sending.

### Cons

- Backend URL contains prototype.
- Not ideal for a paid Pro feature.
- May create confusion later when migrating real users.
- Permanent QR codes created against prototype backend may need migration later.

## Option B — Create Production Backend Before Release

Suggested URL:

`https://speech-club-vote.duduqihong.workers.dev`

### Pros

- Cleaner for public launch.
- Better for paid Pro positioning.
- Avoids later migration after real users create clubs and QR codes.
- Production name is easier to document and support.

### Cons

- Requires backend deployment work.
- Requires app URL update.
- Requires full Online Count retest.
- Requires new TestFlight build after app URL change.
- Requires confirming D1 production database setup.

## Production Backend Questions

- Should production use a new D1 database or the existing prototype D1 database?
- Should test data be copied or discarded?
- Should current TestFlight-created clubs be considered disposable?
- Should QR codes created before production release be considered test-only?
- Should the production worker use the same code as the tested prototype worker?

## Recommended Decision

Create a production backend before public release.

Recommended production plan:

- Create a new production Cloudflare Worker: `speech-club-vote`
- Use the same stable Worker code as the tested prototype.
- Create or bind a production D1 database.
- Treat existing prototype test data as disposable.
- Update the Flutter app backend URL in a later coding phase.
- Retest Online Count fully before App Store submission.

## Important Warning

Do not change backend URL without a full retest because QR sharing, live vote counter, voting submission, and WhatsApp result sending depend on it.

## Suggested Later Phases

- Phase 6D-3: Create production Cloudflare Worker/D1 backend
- Phase 6D-4: Update app backend URL to production
- Phase 6D-5: Full Online Count production backend TestFlight test
- Phase 6D-6: Privacy policy update
- Phase 6D-7: Final App Store submission package

## Decision Summary

Recommended release path:

Do not submit 1.0.3 publicly yet. First create production backend, update app URL, retest, then submit.
