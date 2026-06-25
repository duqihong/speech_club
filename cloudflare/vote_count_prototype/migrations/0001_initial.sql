CREATE TABLE IF NOT EXISTS clubs (
  club_id TEXT PRIMARY KEY,
  club_name TEXT NOT NULL,
  club_slug TEXT NOT NULL UNIQUE,
  admin_pin_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sessions (
  session_id TEXT PRIMARY KEY,
  club_id TEXT NOT NULL,
  meeting_title TEXT NOT NULL,
  meeting_date TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('draft', 'open', 'closed')),
  opened_at TEXT,
  closed_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (club_id) REFERENCES clubs(club_id)
);

CREATE TABLE IF NOT EXISTS awards (
  award_id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  award_type TEXT NOT NULL CHECK (award_type IN ('best_speaker', 'best_table_topics', 'best_evaluator')),
  display_order INTEGER NOT NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

CREATE TABLE IF NOT EXISTS candidates (
  candidate_id TEXT PRIMARY KEY,
  award_id TEXT NOT NULL,
  candidate_name TEXT NOT NULL,
  display_order INTEGER NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (award_id) REFERENCES awards(award_id)
);

CREATE TABLE IF NOT EXISTS votes (
  vote_id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  award_id TEXT NOT NULL,
  candidate_id TEXT NOT NULL,
  voter_token_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(session_id, award_id, voter_token_hash),
  FOREIGN KEY (session_id) REFERENCES sessions(session_id),
  FOREIGN KEY (award_id) REFERENCES awards(award_id),
  FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id)
);

CREATE INDEX IF NOT EXISTS idx_sessions_club_status ON sessions(club_id, status);
CREATE INDEX IF NOT EXISTS idx_awards_session ON awards(session_id);
CREATE INDEX IF NOT EXISTS idx_candidates_award ON candidates(award_id);
CREATE INDEX IF NOT EXISTS idx_votes_session_award ON votes(session_id, award_id);
CREATE INDEX IF NOT EXISTS idx_votes_candidate ON votes(candidate_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_one_open_session_per_club
ON sessions(club_id)
WHERE status = 'open';
