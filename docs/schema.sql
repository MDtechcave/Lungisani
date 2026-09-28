-- Lungisani Database Schema
-- Run this in the Supabase SQL editor

-- TABLES

CREATE TABLE profiles (
  id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name    TEXT,
  ward         TEXT,
  suburb       TEXT,
  avatar_url   TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE issues (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  category        TEXT NOT NULL CHECK (category IN ('road_hazard','sewage_emergency','traffic_light_out','water_crisis','light_outage','waste_buildup')),
  title           TEXT NOT NULL,
  description     TEXT,
  photo_url       TEXT,
  lat             DOUBLE PRECISION NOT NULL,
  lng             DOUBLE PRECISION NOT NULL,
  suburb          TEXT,
  status          TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','escalated','in_progress','resolved')),
  vote_count      INT DEFAULT 0,
  escalated_at    TIMESTAMPTZ,
  resolved_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE votes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issue_id    UUID REFERENCES issues(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(issue_id, user_id)
);

CREATE TABLE comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issue_id    UUID REFERENCES issues(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  body        TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- TRIGGERS

CREATE OR REPLACE FUNCTION update_vote_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE issues
  SET vote_count = (
    SELECT COUNT(*) FROM votes WHERE issue_id = COALESCE(NEW.issue_id, OLD.issue_id)
  )
  WHERE id = COALESCE(NEW.issue_id, OLD.issue_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_vote_change
AFTER INSERT OR DELETE ON votes
FOR EACH ROW EXECUTE FUNCTION update_vote_count();

CREATE OR REPLACE FUNCTION check_escalation()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.vote_count >= 10 AND OLD.status = 'open' THEN
    NEW.status := 'escalated';
    NEW.escalated_at := NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_vote_threshold
BEFORE UPDATE ON issues
FOR EACH ROW EXECUTE FUNCTION check_escalation();

-- ROW LEVEL SECURITY

ALTER TABLE profiles  ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues    ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes     ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments  ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Issues policies
CREATE POLICY "Public read issues" ON issues FOR SELECT USING (true);
CREATE POLICY "Auth users insert issues" ON issues FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Owner updates issue" ON issues FOR UPDATE USING (auth.uid() = user_id);

-- Votes policies
CREATE POLICY "Public read votes" ON votes FOR SELECT USING (true);
CREATE POLICY "Auth users vote" ON votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users delete own vote" ON votes FOR DELETE USING (auth.uid() = user_id);

-- Comments policies
CREATE POLICY "Public read comments" ON comments FOR SELECT USING (true);
CREATE POLICY "Auth users comment" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users delete own comment" ON comments FOR DELETE USING (auth.uid() = user_id);

-- STORAGE
-- Create bucket named 'issue-photos' with public access in Supabase dashboard
-- Then run these policies:

CREATE POLICY "Auth users can upload" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'issue-photos' AND auth.role() = 'authenticated');
CREATE POLICY "Public can read" ON storage.objects FOR SELECT TO public USING (bucket_id = 'issue-photos');
CREATE POLICY "Users can delete own files" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'issue-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
