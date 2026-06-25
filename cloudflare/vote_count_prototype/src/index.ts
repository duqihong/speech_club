interface Env {
  DB: D1Database;
}

type AwardType = 'best_speaker' | 'best_table_topics' | 'best_evaluator';
type SessionStatus = 'draft' | 'open' | 'closed';

interface ClubRow {
  club_id: string;
  club_name: string;
  club_slug: string;
  admin_pin_hash: string;
  created_at: string;
  updated_at: string;
}

interface SessionRow {
  session_id: string;
  club_id: string;
  meeting_title: string;
  meeting_date: string;
  status: SessionStatus;
  opened_at: string | null;
  closed_at: string | null;
  created_at: string;
  updated_at: string;
}

interface AwardRow {
  award_id: string;
  session_id: string;
  award_type: AwardType;
  display_order: number;
}

interface CandidateRow {
  candidate_id: string;
  award_id: string;
  candidate_name: string;
  display_order: number;
  created_at: string;
}

interface VoteInput {
  awardId: string;
  candidateId: string;
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
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Pin',
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

  const activeSessionMatch = path.match(
    /^\/api\/public\/club\/([^/]+)\/active-session$/,
  );
  if (request.method === 'GET' && activeSessionMatch) {
    return getActiveSession(env, decodeURIComponent(activeSessionMatch[1]));
  }

  const voteMatch = path.match(/^\/api\/public\/session\/([^/]+)\/vote$/);
  if (request.method === 'POST' && voteMatch) {
    return submitVote(request, env, decodeURIComponent(voteMatch[1]));
  }

  if (request.method === 'POST' && path === '/api/admin/club') {
    return createClub(request, env);
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

async function createSession(
  request: Request,
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  const clubSlug = normalizeSlug(rawClubSlug);
  const club = await getClubBySlug(env, clubSlug);
  if (!club) {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const pinError = await verifyAdminPin(request, club);
  if (pinError) {
    return pinError;
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
       (session_id, club_id, meeting_title, meeting_date, status)
       VALUES (?, ?, ?, ?, 'draft')`,
    ).bind(sessionId, club.club_id, meetingTitle.trim(), meetingDate.trim()),
    ...defaultAwards.map((award) =>
      env.DB.prepare(
        `INSERT INTO awards
         (award_id, session_id, award_type, display_order)
         VALUES (?, ?, ?, ?)`,
      ).bind(
        crypto.randomUUID(),
        sessionId,
        award.awardType,
        award.displayOrder,
      ),
    ),
  ]);

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

  const missingAwards = await env.DB.prepare(
    `SELECT a.award_type
     FROM awards a
     LEFT JOIN candidates c ON c.award_id = a.award_id
     WHERE a.session_id = ?
     GROUP BY a.award_id
     HAVING COUNT(c.candidate_id) = 0`,
  )
    .bind(context.session.session_id)
    .all<{ award_type: AwardType }>();

  if (missingAwards.results.length > 0) {
    return errorResponse(
      'NO_CANDIDATES',
      'Every award must have at least one candidate before voting opens.',
      409,
    );
  }

  await env.DB.batch([
    env.DB.prepare(
      `UPDATE sessions
       SET status = 'closed', closed_at = COALESCE(closed_at, CURRENT_TIMESTAMP),
           updated_at = CURRENT_TIMESTAMP
       WHERE club_id = ? AND status = 'open' AND session_id <> ?`,
    ).bind(context.club.club_id, context.session.session_id),
    env.DB.prepare(
      `UPDATE sessions
       SET status = 'open', opened_at = COALESCE(opened_at, CURRENT_TIMESTAMP),
           closed_at = NULL, updated_at = CURRENT_TIMESTAMP
       WHERE session_id = ?`,
    ).bind(context.session.session_id),
  ]);

  const session = await getSessionById(env, context.session.session_id);
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

  await env.DB.prepare(
    `UPDATE sessions
     SET status = 'closed', closed_at = CURRENT_TIMESTAMP,
         updated_at = CURRENT_TIMESTAMP
     WHERE session_id = ?`,
  )
    .bind(context.session.session_id)
    .run();

  const session = await getSessionById(env, context.session.session_id);
  return jsonResponse({ ok: true, session });
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
        (candidate) => candidate.vote_count > 0 && candidate.vote_count === maxVotes,
      );

      return {
        awardId: award.award_id,
        awardType: award.award_type,
        label: awardLabels[award.award_type],
        candidates: candidates.results,
        winners,
        hasTie: winners.length > 1,
      };
    }),
  );

  return jsonResponse({
    ok: true,
    isFinal: context.session.status === 'closed',
    session: context.session,
    results,
  });
}

async function getActiveSession(
  env: Env,
  rawClubSlug: string,
): Promise<Response> {
  const clubSlug = normalizeSlug(rawClubSlug);
  const club = await getClubBySlug(env, clubSlug);
  if (!club) {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const session = await env.DB.prepare(
    `SELECT * FROM sessions
     WHERE club_id = ? AND status = 'open'
     ORDER BY opened_at DESC
     LIMIT 1`,
  )
    .bind(club.club_id)
    .first<SessionRow>();

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

async function submitVote(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response> {
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

  const voterTokenHash = await hashText(`${session.session_id}:${voterToken}`);
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

  return jsonResponse({ ok: true, recorded, duplicates });
}

async function getAdminSessionContext(
  request: Request,
  env: Env,
  sessionId: string,
): Promise<Response | { session: SessionRow; club: ClubRow }> {
  const session = await getSessionById(env, sessionId);
  if (!session) {
    return errorResponse('SESSION_NOT_FOUND', 'Session not found.', 404);
  }

  const club = await getClubById(env, session.club_id);
  if (!club) {
    return errorResponse('CLUB_NOT_FOUND', 'Club not found.', 404);
  }

  const pinError = await verifyAdminPin(request, club);
  if (pinError) {
    return pinError;
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
): Promise<Array<AwardRow & { label: { en: string; zh: string }; candidates: CandidateRow[] }>> {
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
  return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
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
  <title>Speech Club Voting / 演讲俱乐部投票</title>
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
      max-width: 760px;
      margin: 0 auto;
      padding: 24px 16px 40px;
    }
    h1 {
      margin: 0 0 8px;
      font-size: 30px;
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
      padding: 18px;
      margin: 14px 0;
      box-shadow: 0 2px 6px rgb(15 23 42 / 6%);
    }
    .award-title {
      margin: 0 0 12px;
      font-size: 22px;
    }
    label {
      display: block;
      padding: 14px;
      margin: 10px 0;
      border: 1px solid #cbd5e1;
      border-radius: 8px;
      font-size: 20px;
      background: #fbfcfe;
    }
    input[type="radio"] {
      width: 22px;
      height: 22px;
      margin-right: 10px;
      vertical-align: middle;
    }
    button {
      width: 100%;
      min-height: 58px;
      margin-top: 18px;
      border: 0;
      border-radius: 8px;
      background: #1769aa;
      color: white;
      font-size: 22px;
      font-weight: 700;
    }
    button:disabled {
      background: #8aa7bf;
    }
    .message {
      font-size: 20px;
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
    <h1>Speech Club Voting / 演讲俱乐部投票</h1>
    <p class="subtitle" id="meeting">Loading / 加载中...</p>
    <section id="content" class="card">
      <p class="message">Loading voting page... / 正在加载投票页面...</p>
    </section>
  </main>
  <script>
    const clubSlug = '${safeClubSlug}';
    const content = document.getElementById('content');
    const meeting = document.getElementById('meeting');

    function getVoterToken() {
      const key = 'speechClubVoteToken';
      let token = localStorage.getItem(key);
      if (!token) {
        token = crypto.randomUUID();
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

    async function loadSession() {
      const response = await fetch('/api/public/club/' + encodeURIComponent(clubSlug) + '/active-session');
      const data = await response.json();
      if (!data.ok) {
        meeting.textContent = 'Online Count / 在线计票';
        content.innerHTML = '<p class="message error">Voting is not open now.<br>当前没有开放的投票。</p>';
        return;
      }

      meeting.textContent = data.session.meeting_title + ' · ' + data.session.meeting_date;
      content.innerHTML = renderForm(data);
      document.getElementById('voteForm').addEventListener('submit', (event) => submitVote(event, data.session.session_id));
    }

    function renderForm(data) {
      const sections = data.awards.map((award) => {
        const options = award.candidates.map((candidate) => {
          return '<label><input type="radio" name="' + award.award_id + '" value="' + candidate.candidate_id + '"> ' + escapeHtml(candidate.candidate_name) + '</label>';
        }).join('');
        return '<section class="card"><h2 class="award-title">' + escapeHtml(award.label.en) + ' / ' + escapeHtml(award.label.zh) + '</h2>' + options + '</section>';
      }).join('');

      return '<form id="voteForm">' + sections + '<button type="submit">Submit Vote / 提交投票</button></form>';
    }

    async function submitVote(event, sessionId) {
      event.preventDefault();
      const form = event.target;
      const button = form.querySelector('button');
      button.disabled = true;
      const votes = Array.from(form.querySelectorAll('input[type="radio"]:checked')).map((input) => ({
        awardId: input.name,
        candidateId: input.value
      }));

      const response = await fetch('/api/public/session/' + encodeURIComponent(sessionId) + '/vote', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ voterToken: getVoterToken(), votes })
      });
      const data = await response.json();

      if (!data.ok) {
        content.innerHTML = '<p class="message error">' + escapeHtml(data.message) + '</p>';
        return;
      }

      const duplicateNote = data.duplicates > 0
        ? '<p class="message">Some votes were already recorded earlier.<br>部分奖项您已经投过票。</p>'
        : '';
      content.innerHTML = '<p class="message success">Thank you. Your vote has been recorded.<br>谢谢，您的投票已记录。</p>' + duplicateNote;
    }

    loadSession().catch(() => {
      meeting.textContent = 'Online Count / 在线计票';
      content.innerHTML = '<p class="message error">Voting is not open now.<br>当前没有开放的投票。</p>';
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
