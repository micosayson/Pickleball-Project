-- Consolidate tenants into courts table
-- This migration removes tenant_id references and makes courts the primary organizational unit

-- Step 1: Drop tenant_id columns from all tables (idempotent approach)
DO $$ 
BEGIN
  -- court_memberships
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'court_memberships' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.court_memberships DROP COLUMN tenant_id;
  END IF;
  
  -- events
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'events' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.events DROP COLUMN tenant_id;
  END IF;
  
  -- matches
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'matches' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.matches DROP COLUMN tenant_id;
  END IF;
  
  -- court_staff
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'court_staff' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.court_staff DROP COLUMN tenant_id;
  END IF;
  
  -- event_participants
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'event_participants' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.event_participants DROP COLUMN tenant_id;
  END IF;
  
  -- event_registrations
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'event_registrations' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.event_registrations DROP COLUMN tenant_id;
  END IF;
  
  -- match_participants
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'match_participants' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.match_participants DROP COLUMN tenant_id;
  END IF;
  
  -- player_ratings
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'player_ratings' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.player_ratings DROP COLUMN tenant_id;
  END IF;
  
  -- rankings
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'rankings' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.rankings DROP COLUMN tenant_id;
  END IF;
  
  -- rating_history
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'rating_history' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.rating_history DROP COLUMN tenant_id;
  END IF;
  
  -- score_submissions
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'score_submissions' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.score_submissions DROP COLUMN tenant_id;
  END IF;
  
  -- invitations
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invitations' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.invitations DROP COLUMN tenant_id;
  END IF;
  
  -- ratings
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ratings' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.ratings DROP COLUMN tenant_id;
  END IF;
END $$;

-- Step 2: Update courts table to remove tenant_id and add new fields
DO $$ 
BEGIN
  -- Drop old tenant_id constraint if exists
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'courts' AND constraint_name = 'uq_courts_tenant_slug') THEN
    ALTER TABLE public.courts DROP CONSTRAINT uq_courts_tenant_slug;
  END IF;
  
  -- Drop tenant_id column if it exists
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courts' AND column_name = 'tenant_id') THEN
    ALTER TABLE public.courts DROP COLUMN tenant_id;
  END IF;
END $$;

-- Step 3: Add new columns to courts if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courts' AND column_name = 'owner_user_id') THEN
    ALTER TABLE public.courts ADD COLUMN owner_user_id UUID REFERENCES public.users(id) ON DELETE RESTRICT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courts' AND column_name = 'address') THEN
    ALTER TABLE public.courts ADD COLUMN address TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courts' AND column_name = 'latitude') THEN
    ALTER TABLE public.courts ADD COLUMN latitude NUMERIC(10, 8);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courts' AND column_name = 'longitude') THEN
    ALTER TABLE public.courts ADD COLUMN longitude NUMERIC(11, 8);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'courts' AND column_name = 'contact_info') THEN
    ALTER TABLE public.courts ADD COLUMN contact_info TEXT;
  END IF;
END $$;

-- Step 4: Add new unique constraint for courts slug (if it doesn't exist)
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'courts' AND constraint_name = 'uq_courts_slug') THEN
    ALTER TABLE public.courts ADD CONSTRAINT uq_courts_slug UNIQUE(slug);
  END IF;
END $$;

-- Step 5: Drop tenants table if it exists
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tenants') THEN
    DROP TABLE IF EXISTS public.tenants;
  END IF;
END $$;
