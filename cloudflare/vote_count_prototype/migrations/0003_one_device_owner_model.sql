ALTER TABLE clubs ADD COLUMN owner_token_hash TEXT;
ALTER TABLE clubs ADD COLUMN status TEXT NOT NULL DEFAULT 'active';
ALTER TABLE clubs ADD COLUMN last_active_at TEXT;
ALTER TABLE clubs ADD COLUMN expires_at TEXT;

ALTER TABLE sessions ADD COLUMN expires_at TEXT;

UPDATE clubs
SET last_active_at = COALESCE(updated_at, created_at, CURRENT_TIMESTAMP)
WHERE last_active_at IS NULL;

UPDATE clubs
SET expires_at = datetime(CURRENT_TIMESTAMP, '+3 months')
WHERE expires_at IS NULL;

UPDATE sessions
SET expires_at = datetime(CURRENT_TIMESTAMP, '+7 days')
WHERE expires_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_clubs_owner_status
ON clubs(owner_token_hash, status);

CREATE INDEX IF NOT EXISTS idx_clubs_status_expires
ON clubs(status, expires_at);

CREATE INDEX IF NOT EXISTS idx_sessions_club_expires
ON sessions(club_id, expires_at);

CREATE INDEX IF NOT EXISTS idx_sessions_expires
ON sessions(expires_at);

CREATE UNIQUE INDEX IF NOT EXISTS idx_one_active_club_per_owner
ON clubs(owner_token_hash)
WHERE owner_token_hash IS NOT NULL AND status = 'active';
