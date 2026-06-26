interface Env {
  DB: D1Database;
}

type AwardType = 'best_speaker' | 'best_table_topics' | 'best_evaluator';
type RoundStatus = 'draft' | 'open' | 'closed';

interface ClubRow {
  club_id: string;
  club_name: string;
  club_slug: string;
  admin_pin_hash: string;
  owner_token_hash: string | null;
  status: 'active' | 'deleted' | 'expired';
  last_active_at: string | null;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
}

interface SessionRow {
  session_id: string;
  club_id: string;
  meeting_title: string;
  meeting_date: string;
  status: RoundStatus;
  opened_at: string | null;
  closed_at: string | null;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
}

interface AwardRow {
  award_id: string;
  session_id: string;
  award_type: AwardType;
  display_order: number;
  status: RoundStatus;
  opened_at: string | null;
  closed_at: string | null;
}

interface CandidateRow {
  candidate_id: string;
  award_id: string;
  candidate_name: string;
  display_order: number;
  created_at: string;
}

const serviceName = 'speech-club-vote-prototype';

const defaultAwards: Array<{ awardType: AwardType; displayOrder: number }> = [
  { awardType: 'best_speaker', displayOrder: 1 },
  { awardType: 'best_table_topics', displayOrder: 2 },
  { awardType: 'best_evaluator', displayOrder: 3 },
];

const awardLabels: Record<AwardType, { en: string; zh: string }> = {
  best_speaker: { en: 'Best Speaker', zh: '最佳演讲者' },
  best_table_topics: {
    en: 'Best Table Topics Speaker',
    zh: '最佳即席演讲者',
  },
  best_evaluator: { en: 'Best Evaluator', zh: '最佳点评者' },
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Pin, X-Owner-Token',
};

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    try {
      return await handleRequest(request, env);
    } catch (error) {
      console.error(error);
      return errorResponse('INTERNAL_ERROR', 'Something went wrong.', 500);
    }
  },
  async scheduled(
    _event: ScheduledEvent,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<void> {
    ctx.waitUntil(cleanupExpiredData(env));
  },
};

async function handleRequest(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const path = trimTrailingSlash(url.pathname);

  if (request.method === 'GET' && path === '/health') {
    return jsonResponse({ ok: true, service: serviceName });
  }

  const clubPageMatch = path.match(/^\/c\/([^/]+)$/);
  if (request.method === 'GET' && clubPageMatch) {
    return htmlResponse(renderVotingPage(decodeURIComponent(clubPageMatch[1])));
  }

  const activeVoteMatch = path.match(
    /^\/api\/public\/club\/([^/]+)\/active-vote$/,
  );
  if (request.method === 'GET' && activeVoteMatch) {
    return getActiveVote(env, decodeURIComponent(activeVoteMatch[1]));
  }

  const activeSessionMatch = path.match(
    /^\/api\/public\/club\/([^/]+)\/active-session$/,
  );
  if (request.method === 'GET' && activeSessionMatch) {
    // Legacy route retained for Phase 5B curl flows while active-vote becomes official.
    return getActiveSession(env, decodeURIComponent(activeSessionMatch[1]));
  }

  const activeAwardVoteMatch = path.match(
    /^\/api\/public\/session\/([^/]+)\/award\/([^/]+)\/vote$/,
  );
  if (request.method === 'POST' && activeAwardVoteMatch) {
    return submitAwardVote(
      request,
      env,
      decodeURIComponent(activeAwardVoteMatch[1]),
      decodeURIComponent(activeAwardVoteMatch[2]),
    );
  }

  const legacyVoteMatch = path.match(/^\/api\/public\/session\/([^/]+)\/vote$/);
  if (request.method === 'POST' && legacyVoteMatch) {
    return submitVote(request, env, decodeURIComponent(legacyVoteMatch[1]));
  }

  if (request.method === 'POST' && path === '/api/admin/club') {
    return createClub(request, env);
  }

  if (request.method === 'POST' && path === '/api/owner/club') {
    return createOwnerClub(request, env);
  }

  const verifyOwnerClubMatch = path.match(
    /^\/api\/owner\/club\/([^/]+)\/verify$/,
  );
  if (request.method === 'POST' && verifyOwnerClubMatch) {
    return verifyOwnerClub(
      request,
      env,
      decodeURIComponent(verifyOwnerClubMatch[1]),
    );
  }

  const ownerClubStatusMatch = path.match(
    /^\/api\/owner\/club\/([^/]+)\/status$/,
  );
  if (request.method === 'GET' && ownerClubStatusMatch) {
    return getOwnerClubStatus(
      request,
      env,
      decodeURIComponent(ownerClubStatusMatch[1]),
    );
  }

  const createOwnerSessionMatch = path.match(
    /^\/api\/owner\/club\/([^/]+)\/session$/,
  );
  if (request.method === 'POST' && createOwnerSessionMatch) {
    return createOwnerSession(
      request,
      env,
      decodeURIComponent(createOwnerSessionMatch[1]),
    );
  }

  const deleteOwnerClubMatch = path.match(/^\/api\/owner\/club\/([^/]+)$/);
  if (request.method === 'DELETE' && deleteOwnerClubMatch) {
    return deleteOwnerClub(
      request,
      env,
      decodeURIComponent(deleteOwnerClubMatch[1]),
    );
  }

  const deleteOwnerSessionMatch = path.match(/^\/api\/owner\/session\/([^/]+)$/);
  if (request.method === 'DELETE' && deleteOwnerSessionMatch) {
    return deleteOwnerSession(
      request,
      env,
      decodeURIComponent(deleteOwnerSessionMatch[1]),
    );
  }

  const createSessionMatch = path.match(
    /^\/api\/admin\/club\/([^/]+)\/session$/,
  );
  if (request.method === 'POST' && createSessionMatch) {
    return createSession(
      request,
      env,
      decodeURIComponent(createSessionMatch[1]),
    );
  }

  const candidatesMatch = path.match(
    /^\/api\/admin\/session\/([^/]+)\/candidates$/,
  );
  if (request.method === 'POST' && candidatesMatch) {
    return setCandidates(request, env, decodeURIComponent(candidatesMatch[1]));
  }

  const openAwardMatch = path.match(
    /^\/api\/admin\/session\/([^/]+)\/award\/([^/]+)\/open$/,
  );
  if (request.method === 'POST' && openAwardMatch) {
    return openAward(
      request,
      env,
      decodeURIComponent(openAwardMatch[1]),
      decodeURIComponent(openAwardMatch[2]),
    );
  }

  const closeAwardMatch = path.match(
    /^\/api\/admin\/session\/([^/]+)\/award\/([^/]+)\/close$/,
  );
  if (request.method === 'POST' && closeAwardMatch) {
    return closeAward(
      request,
      env,
      decodeURIComponent(closeAwardMatch[1]),
      decodeURIComponent(closeAwardMatch[2]),
    );
  }

  const openMatch = path.match(/^\/api\/admin\/session\/([^/]+)\/open$/);
  if (request.method === 'POST' && openMatch) {
    return openSession(request, env, decodeURIComponent(openMatch[1]));
  }

  const closeMatch = path.match(/^\/api\/admin\/session\/([^/]+)\/close$/);
  if (request.method === 'POST' && closeMatch) {
    return closeSession(request, env, decodeURIComponent(closeMatch[1]));
  }

  const resultsMatch = path.match(/^\/api\/admin\/session\/([^/]+)\/results$/);
  if (request.method === 'GET' && resultsMatch) {
    return getResults(request, env, decodeURIComponent(resultsMatch[1]));
  }

  return errorResponse('NOT_FOUND', 'Route not found.', 404);
}

async function createClub(request: Request, env: Env): Promise<Response> {
  const body = await readJson(request);
  const clubName = getString(body, 'clubName');
  const rawSlug = getString(body, 'clubSlug');
  const adminPin = getString(body, 'adminPin');

  if (!clubName || !rawSlug || !adminPin) {
    return errorResponse(
      'MISSING_FIELD',
      'clubName, clubSlug, and adminPin are required.',
    );
  }

  const clubSlug = normalizeSlug(rawSlug);
  if (!clubSlug) {
    return errorResponse('MISSING_FIELD', 'clubSlug must be URL-safe text.');
  }

  const clubId = crypto.randomUUID();
  const adminPinHash = await hashText(`${clubId}:${adminPin}`);

  try {
    await env.DB.prepare(
      `INSERT INTO clubs (club_id, club_name, club_slug, admin_pin_hash)
       VALUES (?, ?, ?, ?)`,
    )
      .bind(clubId, clubName.trim(), clubSlug, adminPinHash)
      .run();
  } catch (error) {
    if (isConstraintError(error)) {
      return errorResponse(
        'DUPLICATE_CLUB',
        'A club with this slug already exists.',
        409,
      );
    }
    throw error;
  }

  return jsonResponse({
    ok: true,
    club_id: clubId,
    club_slug: clubSlug,
  });
}

async function createOwnerClub(
  request: Request,
  env: Env,
): Promise<Response> {
  await cleanupExpiredData(env);

  const ownerToken = getOwnerToken(request);
  if (!ownerToken) {
    return errorResponse('MISSING_OWNER_TOKEN', 'Owner token is required.', 401);
  }

  const body = await readJson(request);
  const clubName = getString(body, 'clubName');
  const rawSlug = getString(body, 'clubSlug');
  const adminPin = getString(body, 'adminPin');

  if (!clubName || !rawSlug || !adminPin) {
    return errorResponse(
      'MISSING_FIELD',
      'clubName, clubSlug, and adminPin are required.',
    );
  }

  const clubSlug = normalizeSlug(rawSlug);
  if (!clubSlug) {
    return errorResponse('MISSING_FIELD', 'clubSlug must be URL-safe text.');
  }

  const ownerTokenHash = await hashOwnerToken(ownerToken);
  const existingOwnerClub = await env.DB.prepare(
    `SELECT club_id FROM clubs
     WHERE owner_token_hash = ? AND status = 'active'
     LIMIT 1`,
  )
    .bind(ownerTokenHash)
    .first<{ club_id: string }>();
  if (existingOwnerClub) {
    return errorResponse(
      'OWNER_ALREADY_HAS_ACTIVE_CLUB',
      'This app installation already has an active online club.',
      409,
    );
  }

  const existingSlug = await env.DB.prepare(
    `SELECT club_id FROM clubs
     WHERE club_slug = ? AND status = 'active'
     LIMIT 1`,
  )
    .bind(clubSlug)
    .first<{ club_id: string }>();
  if (existingSlug) {
    return errorResponse(
      'CLUB_SLUG_EXISTS',
      'A club with this slug already exists.',
      409,
    );
  }

  const clubId = crypto.randomUUID();
  const adminPinHash = await hashText(`${clubId}:${adminPin}`);

  try {
    await env.DB.prepare(
      `INSERT INTO clubs
       (club_id, club_name, club_slug, admin_pin_hash, owner_token_hash,
        status, last_active_at, expires_at)
       VALUES (?, ?, ?, ?, ?, 'active', CURRENT_TIMESTAMP,
        datetime(CURRENT_TIMESTAMP, '+3 months'))`,
    )
      .bind(clubId, clubName.trim(), clubSlug, adminPinHash, ownerTokenHash)
      .run();
  } catch (error) {
    if (isConstraintError(error)) {
      return errorResponse(
        'CLUB_SLUG_EXISTS',
        'A club with this slug already exists.',
        409,
      );
    }
    throw error;
  }

  const club = await getClubById(env, clubId);
  return jsonResponse({ ok: true, club: ownerClubResponse(club) });
}

async function verifyOwnerClub(
  request: Request,
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const context = await verifyOwnerAndAdminForClub(env, rawClubSlug, request);
  if (context instanceof Response) {
    return context;
  }

  await touchClubActivity(env, context.club.club_id);
  return jsonResponse({
    ok: true,
    club: ownerClubResponse(await getClubById(env, context.club.club_id)),
  });
}

async function getOwnerClubStatus(
  request: Request,
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const context = await verifyOwnerAndAdminForClub(env, rawClubSlug, request);
  if (context instanceof Response) {
    return context;
  }

  const sessions = await getCurrentSessionsForClub(env, context.club.club_id);
  const currentSession = sessions[0] ?? null;
  const activeAward = currentSession
    ? await getOpenAwardForSession(env, currentSession.session_id)
    : null;
  const legacyMultipleSessions = sessions.length > 1;

  await touchClubActivity(env, context.club.club_id);
  return jsonResponse({
    ok: true,
    club: ownerClubResponse(await getClubById(env, context.club.club_id)),
    currentSession: currentSession ? ownerSessionResponse(currentSession) : null,
    activeAward: activeAward ? ownerAwardResponse(activeAward) : null,
    summary: {
      hasCurrentSession: currentSession !== null,
      hasActiveAward: activeAward !== null,
      canCreateMeeting: currentSession === null,
      canCreateClub: false,
      legacyMultipleSessions,
    },
  });
}

async function createOwnerSession(
  request: Request,
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const context = await verifyOwnerAndAdminForClub(env, rawClubSlug, request);
  if (context instanceof Response) {
    return context;
  }

  const currentSession = await env.DB.prepare(
    `SELECT session_id FROM sessions
     WHERE club_id = ?
     LIMIT 1`,
  )
    .bind(context.club.club_id)
    .first<{ session_id: string }>();
  if (currentSession) {
    return errorResponse(
      'CURRENT_MEETING_EXISTS',
      'Delete the current meeting before creating a new one.',
      409,
    );
  }

  const body = await readJson(request);
  const meetingTitle = getString(body, 'meetingTitle');
  const meetingDate = getString(body, 'meetingDate');
  if (!meetingTitle || !meetingDate) {
    return errorResponse(
      'MISSING_FIELD',
      'meetingTitle and meetingDate are required.',
    );
  }

  const sessionId = crypto.randomUUID();
  await env.DB.batch([
    env.DB.prepare(
      `INSERT INTO sessions
       (session_id, club_id, meeting_title, meeting_date, status, expires_at)
       VALUES (?, ?, ?, ?, 'draft', datetime(CURRENT_TIMESTAMP, '+7 days'))`,
    ).bind(
      sessionId,
      context.club.club_id,
      meetingTitle.trim(),
      meetingDate.trim(),
    ),
    ...defaultAwards.map((award) =>
      env.DB.prepare(
        `INSERT INTO awards
         (award_id, session_id, award_type, display_order, status)
         VALUES (?, ?, ?, ?, 'draft')`,
      ).bind(
        crypto.randomUUID(),
        sessionId,
        award.awardType,
        award.displayOrder,
      ),
    ),
  ]);

  await touchClubActivity(env, context.club.club_id);
  const session = await getSessionById(env, sessionId);
  const awards = await getAwardsForSession(env, sessionId);
  return jsonResponse({
    ok: true,
    session: ownerSessionResponse(session),
    awards: awards.map(ownerAwardResponse),
  });
}

async function deleteOwnerSession(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const session = await getSessionById(env, sessionId);
  if (!session) {
    return errorResponse('SESSION_NOT_FOUND', 'Session not found.', 404);
  }

  const club = await getClubById(env, session.club_id);
  if (!club) {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const verifyError = await verifyOwnerAndAdmin(request, club);
  if (verifyError) {
    return verifyError;
  }

  await deleteSessionTree(env, session.session_id);
  await touchClubActivity(env, club.club_id);
  return jsonResponse({ ok: true });
}

async function deleteOwnerClub(
  request: Request,
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const context = await verifyOwnerAndAdminForClub(env, rawClubSlug, request);
  if (context instanceof Response) {
    return context;
  }

  await deleteClubTree(env, context.club.club_id);
  return jsonResponse({ ok: true });
}

async function createSession(
  request: Request,
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const clubSlug = normalizeSlug(rawClubSlug);
  const club = await getClubBySlug(env, clubSlug);
  if (!club) {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }
  if (club.status !== 'active') {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const pinError = await verifyAdminPin(request, club);
  if (pinError) {
    return pinError;
  }
  const ownerError = await verifyOwnerForOwnedClub(request, club);
  if (ownerError) {
    return ownerError;
  }

  if (club.owner_token_hash) {
    const currentSession = await env.DB.prepare(
      `SELECT session_id FROM sessions
       WHERE club_id = ?
       LIMIT 1`,
    )
      .bind(club.club_id)
      .first<{ session_id: string }>();
    if (currentSession) {
      return errorResponse(
        'CURRENT_MEETING_EXISTS',
        'Delete the current meeting before creating a new one.',
        409,
      );
    }
  }

  const body = await readJson(request);
  const meetingTitle = getString(body, 'meetingTitle');
  const meetingDate = getString(body, 'meetingDate');
  if (!meetingTitle || !meetingDate) {
    return errorResponse(
      'MISSING_FIELD',
      'meetingTitle and meetingDate are required.',
    );
  }

  const sessionId = crypto.randomUUID();
  await env.DB.batch([
    env.DB.prepare(
      `INSERT INTO sessions
       (session_id, club_id, meeting_title, meeting_date, status, expires_at)
       VALUES (?, ?, ?, ?, 'draft', datetime(CURRENT_TIMESTAMP, '+7 days'))`,
    ).bind(sessionId, club.club_id, meetingTitle.trim(), meetingDate.trim()),
    ...defaultAwards.map((award) =>
      env.DB.prepare(
        `INSERT INTO awards
         (award_id, session_id, award_type, display_order, status)
         VALUES (?, ?, ?, ?, 'draft')`,
      ).bind(
        crypto.randomUUID(),
        sessionId,
        award.awardType,
        award.displayOrder,
      ),
    ),
  ]);

  await touchClubActivity(env, club.club_id);
  const session = await getSessionById(env, sessionId);
  const awards = await getAwardsForSession(env, sessionId);
  return jsonResponse({ ok: true, session, awards });
}

async function setCandidates(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response> {
  const context = await getAdminSessionContext(request, env, sessionId);
  if (context instanceof Response) {
    return context;
  }

  const body = await readJson(request);
  const awardType = getString(body, 'awardType') as AwardType | undefined;
  const candidateNames = getArray(body, 'candidates');

  if (!awardType || !isAwardType(awardType) || !candidateNames) {
    return errorResponse(
      'MISSING_FIELD',
      'awardType and candidates are required.',
    );
  }

  const names = candidateNames
    .filter((value): value is string => typeof value === 'string')
    .map((value) => value.trim())
    .filter((value) => value.length > 0);
  if (names.length === 0) {
    return errorResponse('MISSING_FIELD', 'At least one candidate is required.');
  }

  const award = await env.DB.prepare(
    `SELECT * FROM awards
     WHERE session_id = ? AND award_type = ?`,
  )
    .bind(context.session.session_id, awardType)
    .first<AwardRow>();
  if (!award) {
    return errorResponse('INVALID_AWARD', 'Award not found.', 404);
  }

  if (award.status !== 'draft') {
    return errorResponse(
      'AWARD_LOCKED',
      'Candidates can only be edited while the award is in draft.',
      409,
    );
  }

  const voteCount = await env.DB.prepare(
    `SELECT COUNT(*) AS count FROM votes WHERE award_id = ?`,
  )
    .bind(award.award_id)
    .first<{ count: number }>();
  if ((voteCount?.count ?? 0) > 0) {
    return errorResponse(
      'CANDIDATES_LOCKED',
      'Candidates cannot be changed after votes are recorded.',
      409,
    );
  }

  await env.DB.batch([
    env.DB.prepare(`DELETE FROM candidates WHERE award_id = ?`).bind(
      award.award_id,
    ),
    ...names.map((name, index) =>
      env.DB.prepare(
        `INSERT INTO candidates
         (candidate_id, award_id, candidate_name, display_order)
         VALUES (?, ?, ?, ?)`,
      ).bind(crypto.randomUUID(), award.award_id, name, index + 1),
    ),
  ]);

  await touchClubActivity(env, context.club.club_id);
  const candidates = await getCandidatesForAward(env, award.award_id);
  return jsonResponse({ ok: true, candidates });
}

async function openSession(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response> {
  const context = await getAdminSessionContext(request, env, sessionId);
  if (context instanceof Response) {
    return context;
  }

  const otherOpenSession = await env.DB.prepare(
    `SELECT session_id FROM sessions
     WHERE club_id = ? AND status = 'open' AND session_id <> ?
     LIMIT 1`,
  )
    .bind(context.club.club_id, context.session.session_id)
    .first<{ session_id: string }>();
  if (otherOpenSession) {
    return errorResponse(
      'OPEN_SESSION_EXISTS',
      'Another meeting session is already open.',
      409,
    );
  }

  await env.DB.prepare(
    `UPDATE sessions
     SET status = 'open', opened_at = COALESCE(opened_at, CURRENT_TIMESTAMP),
         closed_at = NULL, updated_at = CURRENT_TIMESTAMP
     WHERE session_id = ?`,
  )
    .bind(context.session.session_id)
    .run();

  const session = await getSessionById(env, context.session.session_id);
  await touchClubActivity(env, context.club.club_id);
  return jsonResponse({ ok: true, session });
}

async function closeSession(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response> {
  const context = await getAdminSessionContext(request, env, sessionId);
  if (context instanceof Response) {
    return context;
  }

  await env.DB.batch([
    env.DB.prepare(
      `UPDATE awards
       SET status = 'closed', closed_at = CURRENT_TIMESTAMP
       WHERE session_id = ? AND status = 'open'`,
    ).bind(context.session.session_id),
    env.DB.prepare(
      `UPDATE sessions
       SET status = 'closed', closed_at = CURRENT_TIMESTAMP,
           updated_at = CURRENT_TIMESTAMP
       WHERE session_id = ?`,
    ).bind(context.session.session_id),
  ]);

  const session = await getSessionById(env, context.session.session_id);
  await touchClubActivity(env, context.club.club_id);
  return jsonResponse({ ok: true, session });
}

async function openAward(
  request: Request,
  env: Env,
  sessionId: string,
  awardId: string,
): Promise<Response> {
  const context = await getAdminSessionContext(request, env, sessionId);
  if (context instanceof Response) {
    return context;
  }
  if (context.session.status !== 'open') {
    return errorResponse(
      'SESSION_NOT_OPEN',
      'Open the meeting session before opening an award round.',
      409,
    );
  }

  const award = await getAwardById(env, awardId);
  if (!award || award.session_id !== context.session.session_id) {
    return errorResponse('INVALID_AWARD', 'Award not found for this session.', 404);
  }

  const openAward = await env.DB.prepare(
    `SELECT award_id FROM awards
     WHERE session_id = ? AND status = 'open' AND award_id <> ?
     LIMIT 1`,
  )
    .bind(context.session.session_id, award.award_id)
    .first<{ award_id: string }>();
  if (openAward) {
    return errorResponse(
      'OPEN_AWARD_EXISTS',
      'Another award voting round is already open.',
      409,
    );
  }

  const candidateCount = await env.DB.prepare(
    `SELECT COUNT(*) AS count FROM candidates WHERE award_id = ?`,
  )
    .bind(award.award_id)
    .first<{ count: number }>();
  if ((candidateCount?.count ?? 0) === 0) {
    return errorResponse(
      'NO_CANDIDATES',
      'Award must have at least one candidate before voting opens.',
      409,
    );
  }

  await env.DB.prepare(
    `UPDATE awards
     SET status = 'open', opened_at = COALESCE(opened_at, CURRENT_TIMESTAMP),
         closed_at = NULL
     WHERE award_id = ?`,
  )
    .bind(award.award_id)
    .run();

  await touchClubActivity(env, context.club.club_id);
  return jsonResponse({ ok: true, award: await getAwardById(env, award.award_id) });
}

async function closeAward(
  request: Request,
  env: Env,
  sessionId: string,
  awardId: string,
): Promise<Response> {
  const context = await getAdminSessionContext(request, env, sessionId);
  if (context instanceof Response) {
    return context;
  }

  const award = await getAwardById(env, awardId);
  if (!award || award.session_id !== context.session.session_id) {
    return errorResponse('INVALID_AWARD', 'Award not found for this session.', 404);
  }
  if (award.status !== 'open') {
    return errorResponse(
      'AWARD_NOT_OPEN',
      'Award voting round is not open.',
      409,
    );
  }

  await env.DB.prepare(
    `UPDATE awards
     SET status = 'closed', closed_at = CURRENT_TIMESTAMP
     WHERE award_id = ?`,
  )
    .bind(award.award_id)
    .run();

  await touchClubActivity(env, context.club.club_id);
  return jsonResponse({ ok: true, award: await getAwardById(env, award.award_id) });
}

async function getResults(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response> {
  const context = await getAdminSessionContext(request, env, sessionId);
  if (context instanceof Response) {
    return context;
  }

  const awards = await getAwardsForSession(env, context.session.session_id);
  const results = await Promise.all(
    awards.map(async (award) => {
      const candidates = await env.DB.prepare(
        `SELECT c.candidate_id, c.candidate_name, c.display_order,
                COUNT(v.vote_id) AS vote_count
         FROM candidates c
         LEFT JOIN votes v ON v.candidate_id = c.candidate_id
         WHERE c.award_id = ?
         GROUP BY c.candidate_id
         ORDER BY c.display_order ASC`,
      )
        .bind(award.award_id)
        .all<{
          candidate_id: string;
          candidate_name: string;
          display_order: number;
          vote_count: number;
        }>();

      const maxVotes = Math.max(
        0,
        ...candidates.results.map((candidate) => candidate.vote_count),
      );
      const winners = candidates.results.filter(
        (candidate) =>
          candidate.vote_count > 0 && candidate.vote_count === maxVotes,
      );

      return {
        awardId: award.award_id,
        awardType: award.award_type,
        awardStatus: award.status,
        label: awardLabels[award.award_type],
        candidates: candidates.results,
        winners,
        hasTie: winners.length > 1,
      };
    }),
  );

  await touchClubActivity(env, context.club.club_id);
  return jsonResponse({
    ok: true,
    isFinal: context.session.status === 'closed',
    session: context.session,
    results,
  });
}

async function getActiveVote(
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const activeVote = await loadActiveVote(env, rawClubSlug);
  if (!activeVote) {
    return jsonResponse(
      {
        ok: false,
        code: 'NO_ACTIVE_VOTE',
        message: 'Voting is not open now.',
      },
      404,
    );
  }

  return jsonResponse({
    ok: true,
    club: publicClubCamel(activeVote.club),
    session: publicSessionCamel(activeVote.session),
    award: publicAwardCamel(activeVote.award),
    candidates: activeVote.candidates.map(publicCandidateCamel),
  });
}

async function getActiveSession(
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const clubSlug = normalizeSlug(rawClubSlug);
  const club = await getClubBySlug(env, clubSlug);
  if (!club || club.status !== 'active') {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const session = await getOpenSessionForClub(env, club.club_id);
  if (!session) {
    return jsonResponse(
      {
        ok: false,
        code: 'NO_ACTIVE_SESSION',
        message: 'Voting is not open now.',
      },
      404,
    );
  }

  const awards = await getAwardsWithCandidates(env, session.session_id);
  return jsonResponse({
    ok: true,
    club: publicClub(club),
    session,
    awards,
  });
}

async function submitAwardVote(
  request: Request,
  env: Env,
  sessionId: string,
  awardId: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const session = await getSessionById(env, sessionId);
  if (!session) {
    return errorResponse('SESSION_NOT_FOUND', 'Session not found.', 404);
  }
  if (session.status !== 'open') {
    return errorResponse(
      'SESSION_NOT_OPEN',
      'Voting is not open now.',
      409,
    );
  }

  const award = await getAwardById(env, awardId);
  if (!award || award.session_id !== session.session_id) {
    return errorResponse('INVALID_AWARD', 'Award not found for this session.', 404);
  }
  if (award.status !== 'open') {
    return errorResponse(
      'AWARD_NOT_OPEN',
      'Voting is not open now.',
      409,
    );
  }

  const body = await readJson(request);
  const voterToken = getString(body, 'voterToken');
  const candidateId = getString(body, 'candidateId');
  if (!voterToken || !candidateId) {
    return errorResponse(
      'MISSING_FIELD',
      'voterToken and candidateId are required.',
    );
  }

  const candidate = await env.DB.prepare(
    `SELECT * FROM candidates WHERE candidate_id = ? AND award_id = ?`,
  )
    .bind(candidateId, award.award_id)
    .first<CandidateRow>();
  if (!candidate) {
    return errorResponse(
      'INVALID_CANDIDATE',
      'Candidate does not belong to this award.',
      400,
    );
  }

  const voterTokenHash = await hashText(
    `${session.session_id}:${award.award_id}:${voterToken}`,
  );

  try {
    await env.DB.prepare(
      `INSERT INTO votes
       (vote_id, session_id, award_id, candidate_id, voter_token_hash)
       VALUES (?, ?, ?, ?, ?)`,
    )
      .bind(
        crypto.randomUUID(),
        session.session_id,
        award.award_id,
        candidate.candidate_id,
        voterTokenHash,
      )
      .run();
    await touchClubActivity(env, session.club_id);
    return jsonResponse({ ok: true, recorded: true, duplicate: false });
  } catch (error) {
    if (isConstraintError(error)) {
      return jsonResponse({
        ok: true,
        recorded: false,
        duplicate: true,
        code: 'ALREADY_VOTED',
      });
    }
    throw error;
  }
}

async function submitVote(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response> {
  await cleanupExpiredData(env);

  const session = await getSessionById(env, sessionId);
  if (!session) {
    return errorResponse('SESSION_NOT_FOUND', 'Session not found.', 404);
  }
  if (session.status !== 'open') {
    return errorResponse(
      'SESSION_NOT_OPEN',
      'Voting has closed for this meeting.',
      409,
    );
  }

  const body = await readJson(request);
  const voterToken = getString(body, 'voterToken');
  const votes = getArray(body, 'votes');
  if (!voterToken || !votes) {
    return errorResponse('MISSING_FIELD', 'voterToken and votes are required.');
  }

  let recorded = 0;
  let duplicates = 0;

  for (const vote of votes) {
    const voteRecord = getRecord(vote);
    const awardId = getString(voteRecord, 'awardId');
    const candidateId = getString(voteRecord, 'candidateId');
    if (!awardId || !candidateId) {
      return errorResponse('MISSING_FIELD', 'awardId and candidateId are required.');
    }

    const award = await env.DB.prepare(
      `SELECT * FROM awards WHERE award_id = ? AND session_id = ?`,
    )
      .bind(awardId, session.session_id)
      .first<AwardRow>();
    if (!award) {
      return errorResponse(
        'INVALID_AWARD',
        'Award does not belong to this session.',
        400,
      );
    }

    const candidate = await env.DB.prepare(
      `SELECT * FROM candidates WHERE candidate_id = ? AND award_id = ?`,
    )
      .bind(candidateId, award.award_id)
      .first<CandidateRow>();
    if (!candidate) {
      return errorResponse(
        'INVALID_CANDIDATE',
        'Candidate does not belong to this award.',
        400,
      );
    }

    const voterTokenHash = await hashText(
      `${session.session_id}:${award.award_id}:${voterToken}`,
    );
    try {
      await env.DB.prepare(
        `INSERT INTO votes
         (vote_id, session_id, award_id, candidate_id, voter_token_hash)
         VALUES (?, ?, ?, ?, ?)`,
      )
        .bind(
          crypto.randomUUID(),
          session.session_id,
          award.award_id,
          candidate.candidate_id,
          voterTokenHash,
        )
        .run();
      recorded += 1;
    } catch (error) {
      if (isConstraintError(error)) {
        duplicates += 1;
      } else {
        throw error;
      }
    }
  }

  if (recorded > 0) {
    await touchClubActivity(env, session.club_id);
  }
  return jsonResponse({ ok: true, recorded, duplicates });
}

async function getAdminSessionContext(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response | { session: SessionRow; club: ClubRow }> {
  await cleanupExpiredData(env);

  const session = await getSessionById(env, sessionId);
  if (!session) {
    return errorResponse('SESSION_NOT_FOUND', 'Session not found.', 404);
  }

  const club = await getClubById(env, session.club_id);
  if (!club || club.status !== 'active') {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const pinError = await verifyAdminPin(request, club);
  if (pinError) {
    return pinError;
  }
  const ownerError = await verifyOwnerForOwnedClub(request, club);
  if (ownerError) {
    return ownerError;
  }

  return { session, club };
}

async function verifyAdminPin(
  request: Request,
  club: ClubRow,
): Promise<Response | null> {
  const adminPin = request.headers.get('X-Admin-Pin')?.trim();
  if (!adminPin) {
    return errorResponse('INVALID_ADMIN_PIN', 'Admin PIN is required.', 401);
  }

  const hash = await hashText(`${club.club_id}:${adminPin}`);
  if (hash !== club.admin_pin_hash) {
    return errorResponse('INVALID_ADMIN_PIN', 'Admin PIN is invalid.', 403);
  }

  return null;
}

function getOwnerToken(request: Request): string | null {
  return request.headers.get('X-Owner-Token')?.trim() || null;
}

async function hashOwnerToken(ownerToken: string): Promise<string> {
  return hashText(`owner:${ownerToken}`);
}

async function verifyOwnerAndAdminForClub(
  env: Env,
  rawClubSlug: string,
  request: Request,
): Promise<Response | { club: ClubRow }> {
  const clubSlug = normalizeSlug(rawClubSlug);
  const club = await getClubBySlug(env, clubSlug);
  if (!club || club.status !== 'active') {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const verifyError = await verifyOwnerAndAdmin(request, club);
  if (verifyError) {
    return verifyError;
  }

  return { club };
}

async function verifyOwnerAndAdmin(
  request: Request,
  club: ClubRow,
): Promise<Response | null> {
  const ownerToken = getOwnerToken(request);
  if (!ownerToken) {
    return errorResponse('MISSING_OWNER_TOKEN', 'Owner token is required.', 401);
  }

  if (!club.owner_token_hash) {
    return errorResponse(
      'OWNER_NOT_CONFIGURED',
      'This club is not owned by an app installation.',
      409,
    );
  }

  const ownerTokenHash = await hashOwnerToken(ownerToken);
  if (ownerTokenHash !== club.owner_token_hash) {
    return errorResponse('INVALID_OWNER_TOKEN', 'Owner token is invalid.', 403);
  }

  return verifyAdminPin(request, club);
}

async function verifyOwnerForOwnedClub(
  request: Request,
  club: ClubRow,
): Promise<Response | null> {
  if (!club.owner_token_hash) {
    return null;
  }

  const ownerToken = getOwnerToken(request);
  if (!ownerToken) {
    return errorResponse('MISSING_OWNER_TOKEN', 'Owner token is required.', 401);
  }

  const ownerTokenHash = await hashOwnerToken(ownerToken);
  if (ownerTokenHash !== club.owner_token_hash) {
    return errorResponse('INVALID_OWNER_TOKEN', 'Owner token is invalid.', 403);
  }

  return null;
}

async function touchClubActivity(env: Env, clubId: string): Promise<void> {
  await env.DB.prepare(
    `UPDATE clubs
     SET last_active_at = CURRENT_TIMESTAMP,
         expires_at = datetime(CURRENT_TIMESTAMP, '+3 months'),
         updated_at = CURRENT_TIMESTAMP
     WHERE club_id = ? AND status = 'active'`,
  )
    .bind(clubId)
    .run();
}

async function cleanupExpiredData(env: Env): Promise<void> {
  const expiredSessions = await env.DB.prepare(
    `SELECT session_id FROM sessions
     WHERE expires_at IS NOT NULL AND expires_at <= CURRENT_TIMESTAMP`,
  ).all<{ session_id: string }>();

  for (const session of expiredSessions.results) {
    await deleteSessionTree(env, session.session_id);
  }

  const expiredClubs = await env.DB.prepare(
    `SELECT club_id FROM clubs
     WHERE (status IS NOT NULL AND status <> 'active')
        OR (expires_at IS NOT NULL AND expires_at <= CURRENT_TIMESTAMP)`,
  ).all<{ club_id: string }>();

  for (const club of expiredClubs.results) {
    await deleteClubTree(env, club.club_id);
  }
}

async function deleteSessionTree(env: Env, sessionId: string): Promise<void> {
  await env.DB.batch([
    env.DB.prepare(`DELETE FROM votes WHERE session_id = ?`).bind(sessionId),
    env.DB.prepare(
      `DELETE FROM candidates
       WHERE award_id IN (
         SELECT award_id FROM awards WHERE session_id = ?
       )`,
    ).bind(sessionId),
    env.DB.prepare(`DELETE FROM awards WHERE session_id = ?`).bind(sessionId),
    env.DB.prepare(`DELETE FROM sessions WHERE session_id = ?`).bind(sessionId),
  ]);
}

async function deleteClubTree(env: Env, clubId: string): Promise<void> {
  const sessions = await env.DB.prepare(
    `SELECT session_id FROM sessions WHERE club_id = ?`,
  )
    .bind(clubId)
    .all<{ session_id: string }>();

  for (const session of sessions.results) {
    await deleteSessionTree(env, session.session_id);
  }

  await env.DB.prepare(`DELETE FROM clubs WHERE club_id = ?`).bind(clubId).run();
}

async function loadActiveVote(
  env: Env,
  rawClubSlug: string,
): Promise<
  | {
      club: ClubRow;
      session: SessionRow;
      award: AwardRow;
      candidates: CandidateRow[];
    }
  | null
> {
  const clubSlug = normalizeSlug(rawClubSlug);
  const club = await getClubBySlug(env, clubSlug);
  if (!club || club.status !== 'active') {
    return null;
  }

  const session = await getOpenSessionForClub(env, club.club_id);
  if (!session) {
    return null;
  }

  const award = await env.DB.prepare(
    `SELECT * FROM awards
     WHERE session_id = ? AND status = 'open'
     ORDER BY opened_at DESC
     LIMIT 1`,
  )
    .bind(session.session_id)
    .first<AwardRow>();
  if (!award) {
    return null;
  }

  return {
    club,
    session,
    award,
    candidates: await getCandidatesForAward(env, award.award_id),
  };
}

async function getOpenSessionForClub(
  env: Env,
  clubId: string,
): Promise<SessionRow | null> {
  return env.DB.prepare(
    `SELECT * FROM sessions
     WHERE club_id = ? AND status = 'open'
     ORDER BY opened_at DESC
     LIMIT 1`,
  )
    .bind(clubId)
    .first<SessionRow>();
}

async function getCurrentSessionsForClub(
  env: Env,
  clubId: string,
): Promise<SessionRow[]> {
  const sessions = await env.DB.prepare(
    `SELECT * FROM sessions
     WHERE club_id = ?
     ORDER BY datetime(updated_at) DESC, datetime(created_at) DESC
     LIMIT 20`,
  )
    .bind(clubId)
    .all<SessionRow>();
  return sessions.results;
}

async function getOpenAwardForSession(
  env: Env,
  sessionId: string,
): Promise<AwardRow | null> {
  return env.DB.prepare(
    `SELECT * FROM awards
     WHERE session_id = ? AND status = 'open'
     ORDER BY opened_at DESC
     LIMIT 1`,
  )
    .bind(sessionId)
    .first<AwardRow>();
}

async function getClubBySlug(
  env: Env,
  clubSlug: string,
): Promise<ClubRow | null> {
  return env.DB.prepare(`SELECT * FROM clubs WHERE club_slug = ?`)
    .bind(clubSlug)
    .first<ClubRow>();
}

async function getClubById(env: Env, clubId: string): Promise<ClubRow | null> {
  return env.DB.prepare(`SELECT * FROM clubs WHERE club_id = ?`)
    .bind(clubId)
    .first<ClubRow>();
}

async function getSessionById(
  env: Env,
  sessionId: string,
): Promise<SessionRow | null> {
  return env.DB.prepare(`SELECT * FROM sessions WHERE session_id = ?`)
    .bind(sessionId)
    .first<SessionRow>();
}

async function getAwardById(env: Env, awardId: string): Promise<AwardRow | null> {
  return env.DB.prepare(`SELECT * FROM awards WHERE award_id = ?`)
    .bind(awardId)
    .first<AwardRow>();
}

async function getAwardsForSession(
  env: Env,
  sessionId: string,
): Promise<AwardRow[]> {
  const awards = await env.DB.prepare(
    `SELECT * FROM awards WHERE session_id = ? ORDER BY display_order ASC`,
  )
    .bind(sessionId)
    .all<AwardRow>();
  return awards.results;
}

async function getCandidatesForAward(
  env: Env,
  awardId: string,
): Promise<CandidateRow[]> {
  const candidates = await env.DB.prepare(
    `SELECT * FROM candidates
     WHERE award_id = ?
     ORDER BY display_order ASC`,
  )
    .bind(awardId)
    .all<CandidateRow>();
  return candidates.results;
}

async function getAwardsWithCandidates(
  env: Env,
  sessionId: string,
): Promise<
  Array<AwardRow & { label: { en: string; zh: string }; candidates: CandidateRow[] }>
> {
  const awards = await getAwardsForSession(env, sessionId);
  return Promise.all(
    awards.map(async (award) => ({
      ...award,
      label: awardLabels[award.award_type],
      candidates: await getCandidatesForAward(env, award.award_id),
    })),
  );
}

function publicClub(club: ClubRow) {
  return {
    club_id: club.club_id,
    club_name: club.club_name,
    club_slug: club.club_slug,
  };
}

function publicClubCamel(club: ClubRow) {
  return {
    clubId: club.club_id,
    clubName: club.club_name,
    clubSlug: club.club_slug,
  };
}

function publicSessionCamel(session: SessionRow) {
  return {
    sessionId: session.session_id,
    meetingTitle: session.meeting_title,
    meetingDate: session.meeting_date,
    status: session.status,
  };
}

function publicAwardCamel(award: AwardRow) {
  return {
    awardId: award.award_id,
    awardType: award.award_type,
    status: award.status,
  };
}

function publicCandidateCamel(candidate: CandidateRow) {
  return {
    candidateId: candidate.candidate_id,
    candidateName: candidate.candidate_name,
    displayOrder: candidate.display_order,
  };
}

function ownerClubResponse(club: ClubRow | null) {
  if (!club) {
    return null;
  }
  return {
    clubId: club.club_id,
    clubName: club.club_name,
    clubSlug: club.club_slug,
    status: club.status,
    lastActiveAt: club.last_active_at,
    expiresAt: club.expires_at,
    createdAt: club.created_at,
    updatedAt: club.updated_at,
  };
}

function ownerSessionResponse(session: SessionRow | null) {
  if (!session) {
    return null;
  }
  return {
    sessionId: session.session_id,
    clubId: session.club_id,
    meetingTitle: session.meeting_title,
    meetingDate: session.meeting_date,
    status: session.status,
    openedAt: session.opened_at,
    closedAt: session.closed_at,
    expiresAt: session.expires_at,
    createdAt: session.created_at,
    updatedAt: session.updated_at,
  };
}

function ownerAwardResponse(award: AwardRow) {
  return {
    awardId: award.award_id,
    sessionId: award.session_id,
    awardType: award.award_type,
    displayOrder: award.display_order,
    status: award.status,
    openedAt: award.opened_at,
    closedAt: award.closed_at,
    label: awardLabels[award.award_type],
  };
}

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json; charset=utf-8',
    },
  });
}

function errorResponse(code: string, message: string, status = 400): Response {
  return jsonResponse({ ok: false, code, message }, status);
}

function htmlResponse(html: string): Response {
  return new Response(html, {
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
  });
}

async function readJson(request: Request): Promise<unknown> {
  try {
    return await request.json();
  } catch {
    return {};
  }
}

async function hashText(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

function normalizeSlug(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function trimTrailingSlash(path: string): string {
  if (path.length > 1 && path.endsWith('/')) {
    return path.slice(0, -1);
  }
  return path;
}

function getRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object'
    ? (value as Record<string, unknown>)
    : {};
}

function getString(value: unknown, key: string): string | undefined {
  const field = getRecord(value)[key];
  return typeof field === 'string' && field.trim() ? field : undefined;
}

function getArray(value: unknown, key: string): unknown[] | undefined {
  const field = getRecord(value)[key];
  return Array.isArray(field) ? field : undefined;
}

function isAwardType(value: string): value is AwardType {
  return ['best_speaker', 'best_table_topics', 'best_evaluator'].includes(value);
}

function isConstraintError(error: unknown): boolean {
  return error instanceof Error && /constraint|unique/i.test(error.message);
}

function renderVotingPage(clubSlug: string): string {
  const safeClubSlug = escapeHtml(normalizeSlug(clubSlug));
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Speech Club Voting</title>
  <style>
    :root {
      color-scheme: light;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      line-height: 1.45;
    }
    body {
      margin: 0;
      background: #f6f7f9;
      color: #17202a;
    }
    main {
      max-width: 680px;
      margin: 0 auto;
      padding: 24px 16px 40px;
    }
    .language-switch {
      display: flex;
      justify-content: flex-end;
      gap: 8px;
      margin-bottom: 16px;
      font-size: 16px;
    }
    .language-switch button {
      width: auto;
      min-height: 0;
      margin: 0;
      padding: 6px 8px;
      border: 0;
      background: transparent;
      color: #1769aa;
      font-size: 16px;
      font-weight: 700;
    }
    .language-switch button[aria-current="true"] {
      color: #17202a;
      text-decoration: underline;
    }
    h1 {
      margin: 0 0 8px;
      font-size: 32px;
    }
    .subtitle {
      margin: 0 0 20px;
      color: #52606d;
      font-size: 18px;
    }
    .card {
      background: #fff;
      border: 1px solid #d7dde5;
      border-radius: 8px;
      padding: 20px;
      margin: 14px 0;
      box-shadow: 0 2px 6px rgb(15 23 42 / 6%);
    }
    .eyebrow {
      margin: 0 0 8px;
      color: #52606d;
      font-size: 18px;
      font-weight: 700;
    }
    .award-title {
      margin: 0 0 18px;
      font-size: 26px;
    }
    .prompt {
      margin: 0 0 12px;
      font-size: 20px;
      font-weight: 650;
    }
    label {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 16px;
      margin: 12px 0;
      border: 1px solid #cbd5e1;
      border-radius: 8px;
      font-size: 22px;
      background: #fbfcfe;
    }
    input[type="radio"] {
      width: 24px;
      height: 24px;
      flex: 0 0 auto;
    }
    .submit {
      width: 100%;
      min-height: 60px;
      margin-top: 18px;
      border: 0;
      border-radius: 8px;
      background: #1769aa;
      color: white;
      font-size: 22px;
      font-weight: 700;
    }
    .submit:disabled {
      background: #8aa7bf;
    }
    .message {
      font-size: 22px;
      font-weight: 650;
    }
    .error {
      color: #9f1d1d;
    }
    .success {
      color: #17633a;
    }
  </style>
</head>
<body>
  <main>
    <nav class="language-switch" aria-label="Language">
      <button id="langEn" type="button">English</button>
      <span aria-hidden="true">|</span>
      <button id="langZh" type="button">中文</button>
    </nav>
    <h1 id="title"></h1>
    <p class="subtitle" id="meeting"></p>
    <section id="content" class="card"></section>
  </main>
  <script>
    const clubSlug = '${safeClubSlug}';
    const content = document.getElementById('content');
    const meeting = document.getElementById('meeting');
    const title = document.getElementById('title');
    const langEn = document.getElementById('langEn');
    const langZh = document.getElementById('langZh');
    let currentData = null;
    let currentLang = chooseInitialLanguage();

    const text = {
      en: {
        title: 'Speech Club Voting',
        loading: 'Loading voting page...',
        noActiveVote: 'Voting is not open now.',
        currentVote: 'Current Vote',
        chooseOne: 'Please choose one candidate',
        submit: 'Submit Vote',
        thankYou: 'Thank you. Your vote has been recorded.',
        alreadyVoted: 'You have already voted for this award.',
        chooseCandidate: 'Please choose one candidate.',
        genericError: 'Unable to submit vote. Please try again.'
      },
      zh: {
        title: '演讲俱乐部投票',
        loading: '正在加载投票页面...',
        noActiveVote: '当前没有开放的投票。',
        currentVote: '当前投票',
        chooseOne: '请选择一位候选人',
        submit: '提交投票',
        thankYou: '谢谢，您的投票已记录。',
        alreadyVoted: '您已经为这个奖项投过票。',
        chooseCandidate: '请选择一位候选人。',
        genericError: '无法提交投票，请再试一次。'
      }
    };

    const awardLabels = {
      best_speaker: { en: 'Best Speaker', zh: '最佳演讲者' },
      best_table_topics: { en: 'Best Table Topics Speaker', zh: '最佳即席演讲者' },
      best_evaluator: { en: 'Best Evaluator', zh: '最佳点评者' }
    };

    function chooseInitialLanguage() {
      const params = new URLSearchParams(window.location.search);
      const urlLang = normalizeLanguage(params.get('lang'));
      if (urlLang) {
        localStorage.setItem('speechClubVoteLang', urlLang);
        return urlLang;
      }

      const savedLang = normalizeLanguage(localStorage.getItem('speechClubVoteLang'));
      if (savedLang) {
        return savedLang;
      }

      const browserLanguages = navigator.languages && navigator.languages.length
        ? navigator.languages
        : [navigator.language];
      return browserLanguages.some((lang) => String(lang).toLowerCase().startsWith('zh'))
        ? 'zh'
        : 'en';
    }

    function normalizeLanguage(value) {
      if (!value) return null;
      const lang = String(value).toLowerCase();
      if (lang === 'en' || lang.startsWith('en-')) return 'en';
      if (lang === 'zh' || lang.startsWith('zh-')) return 'zh';
      return null;
    }

    function setLanguage(lang) {
      currentLang = lang;
      localStorage.setItem('speechClubVoteLang', lang);
      const url = new URL(window.location.href);
      url.searchParams.set('lang', lang);
      history.replaceState(null, '', url.toString());
      renderPage(currentData);
    }

    langEn.addEventListener('click', () => setLanguage('en'));
    langZh.addEventListener('click', () => setLanguage('zh'));

    function getVoterToken() {
      const key = 'speechClubVoterToken';
      let token = localStorage.getItem(key);
      if (!token) {
        token = crypto.randomUUID
          ? crypto.randomUUID()
          : Date.now().toString(36) + '-' + Math.random().toString(36).slice(2);
        localStorage.setItem(key, token);
      }
      return token;
    }

    function escapeHtml(value) {
      return String(value).replace(/[&<>"']/g, (char) => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
      }[char]));
    }

    function awardLabel(awardType) {
      return (awardLabels[awardType] && awardLabels[awardType][currentLang]) || awardType;
    }

    function renderShell() {
      document.documentElement.lang = currentLang;
      document.title = text[currentLang].title;
      title.textContent = text[currentLang].title;
      langEn.setAttribute('aria-current', currentLang === 'en' ? 'true' : 'false');
      langZh.setAttribute('aria-current', currentLang === 'zh' ? 'true' : 'false');
    }

    function renderPage(data) {
      renderShell();
      if (!data) {
        meeting.textContent = '';
        content.innerHTML = '<p class="message">' + escapeHtml(text[currentLang].loading) + '</p>';
        return;
      }
      if (!data.ok) {
        meeting.textContent = '';
        content.innerHTML = '<p class="message error">' + escapeHtml(text[currentLang].noActiveVote) + '</p>';
        return;
      }

      meeting.textContent = data.session.meetingTitle + ' · ' + data.session.meetingDate;
      const options = data.candidates.map((candidate) => {
        return '<label><input type="radio" name="candidate" value="' + candidate.candidateId + '"> <span>' + escapeHtml(candidate.candidateName) + '</span></label>';
      }).join('');
      content.innerHTML =
        '<form id="voteForm">' +
        '<p class="eyebrow">' + escapeHtml(text[currentLang].currentVote) + '</p>' +
        '<h2 class="award-title">' + escapeHtml(awardLabel(data.award.awardType)) + '</h2>' +
        '<p class="prompt">' + escapeHtml(text[currentLang].chooseOne) + '</p>' +
        options +
        '<button class="submit" type="submit">' + escapeHtml(text[currentLang].submit) + '</button>' +
        '</form>';
      document.getElementById('voteForm').addEventListener('submit', (event) => submitVote(event, data));
    }

    async function loadActiveVote() {
      renderPage(null);
      const response = await fetch('/api/public/club/' + encodeURIComponent(clubSlug) + '/active-vote');
      const data = await response.json();
      currentData = data;
      renderPage(data);
    }

    async function submitVote(event, data) {
      event.preventDefault();
      const form = event.target;
      const selected = form.querySelector('input[name="candidate"]:checked');
      if (!selected) {
        content.innerHTML = '<p class="message error">' + escapeHtml(text[currentLang].chooseCandidate) + '</p>';
        return;
      }

      const button = form.querySelector('button');
      button.disabled = true;
      const response = await fetch('/api/public/session/' + encodeURIComponent(data.session.sessionId) + '/award/' + encodeURIComponent(data.award.awardId) + '/vote', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          voterToken: getVoterToken(),
          candidateId: selected.value
        })
      });
      const result = await response.json();

      if (!result.ok) {
        content.innerHTML = '<p class="message error">' + escapeHtml(result.message || text[currentLang].genericError) + '</p>';
        return;
      }

      const message = result.duplicate
        ? text[currentLang].alreadyVoted
        : text[currentLang].thankYou;
      content.innerHTML = '<p class="message success">' + escapeHtml(message) + '</p>';
    }

    renderShell();
    loadActiveVote().catch(() => {
      currentData = { ok: false };
      renderPage(currentData);
    });
  </script>
</body>
</html>`;
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (char) => {
    const replacements: Record<string, string> = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
    };
    return replacements[char] ?? char;
  });
}
