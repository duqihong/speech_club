ALTER TABLE awards ADD COLUMN status TEXT NOT NULL DEFAULT 'draft';
ALTER TABLE awards ADD COLUMN opened_at TEXT;
ALTER TABLE awards ADD COLUMN closed_at TEXT;

CREATE INDEX IF NOT EXISTS idx_awards_session_status
ON awards(session_id, status);

CREATE UNIQUE INDEX IF NOT EXISTS idx_one_open_award_per_session
ON awards(session_id)
WHERE status = 'open';
